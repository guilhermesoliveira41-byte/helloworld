import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rota até o SESI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DistancePage(),
    );
  }
}

class DistancePage extends StatefulWidget {
  const DistancePage({super.key});

  @override
  State<DistancePage> createState() => _DistancePageState();
}

class _DistancePageState extends State<DistancePage> {
  static const LatLng casa = LatLng(
    -21.454640,
    -47.006020,
  );

  static const LatLng sesi = LatLng(
    -21.48434348,
    -47.00804448,
  );

  static const String googleApiKey = 'SUA_API_KEY_AQUI';

  GoogleMapController? mapaController;

  Set<Marker> marcadores = {};
  Set<Polyline> rotas = {};

  String distancia = 'Distância: --';
  String tempo = 'Tempo estimado: --';
  bool carregando = false;

  @override
  void initState() {
    super.initState();

    marcadores = {
      const Marker(
        markerId: MarkerId('casa'),
        position: casa,
        infoWindow: InfoWindow(
          title: 'Minha casa',
          snippet: 'Arceburgo - MG',
        ),
      ),
      const Marker(
        markerId: MarkerId('sesi'),
        position: sesi,
        infoWindow: InfoWindow(
          title: 'SESI 357',
          snippet: 'Mococa - SP',
        ),
      ),
    };
  }

  Future<void> calcularRota() async {
    if (googleApiKey == 'SUA_API_KEY_AQUI') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Coloque sua Google Maps API Key no código.',
          ),
        ),
      );
      return;
    }

    setState(() {
      carregando = true;
      distancia = 'Calculando...';
      tempo = 'Calculando...';
    });

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${casa.latitude},${casa.longitude}'
        '&destination=${sesi.latitude},${sesi.longitude}'
        '&mode=driving'
        '&language=pt-BR'
        '&key=$googleApiKey',
      );

      final resposta = await http.get(url);

      if (resposta.statusCode != 200) {
        throw Exception('Erro ao acessar o Google Directions.');
      }

      final dados = jsonDecode(resposta.body);

      if (dados['status'] != 'OK') {
        throw Exception(
          'Google Directions: ${dados['status']}',
        );
      }

      final rota = dados['routes'][0];
      final perna = rota['legs'][0];

      final distanciaTexto = perna['distance']['text'];
      final tempoTexto = perna['duration']['text'];

      final pontosCodificados =
          rota['overview_polyline']['points'];

      final pontos = _decodificarPolyline(
        pontosCodificados,
      );

      setState(() {
        distancia = 'Distância: $distanciaTexto';
        tempo = 'Tempo estimado: $tempoTexto';

        rotas = {
          Polyline(
            polylineId: const PolylineId('rota'),
            points: pontos,
            color: Colors.blue,
            width: 6,
          ),
        };

        carregando = false;
      });

      _mostrarRotaNoMapa(pontos);
    } catch (e) {
      setState(() {
        carregando = false;
        distancia = 'Não foi possível calcular';
        tempo = 'Verifique sua conexão/API';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
        ),
      );
    }
  }

  List<LatLng> _decodificarPolyline(String encoded) {
    final List<LatLng> pontos = [];

    int index = 0;
    int latitude = 0;
    int longitude = 0;

    while (index < encoded.length) {
      int shift = 0;
      int resultado = 0;

      while (true) {
        final byte = encoded.codeUnitAt(index++) - 63;

        resultado |= (byte & 0x1f) << shift;
        shift += 5;

        if (byte < 0x20) {
          break;
        }
      }

      final deltaLatitude =
          (resultado & 1) != 0
              ? ~(resultado >> 1)
              : (resultado >> 1);

      latitude += deltaLatitude;

      shift = 0;
      resultado = 0;

      while (true) {
        final byte = encoded.codeUnitAt(index++) - 63;

        resultado |= (byte & 0x1f) << shift;
        shift += 5;

        if (byte < 0x20) {
          break;
        }
      }

      final deltaLongitude =
          (resultado & 1) != 0
              ? ~(resultado >> 1)
              : (resultado >> 1);

      longitude += deltaLongitude;

      pontos.add(
        LatLng(
          latitude / 100000.0,
          longitude / 100000.0,
        ),
      );
    }

    return pontos;
  }

  Future<void> _mostrarRotaNoMapa(
    List<LatLng> pontos,
  ) async {
    if (pontos.isEmpty || mapaController == null) {
      return;
    }

    double minLat = pontos.first.latitude;
    double maxLat = pontos.first.latitude;
    double minLng = pontos.first.longitude;
    double maxLng = pontos.first.longitude;

    for (final ponto in pontos) {
      if (ponto.latitude < minLat) {
        minLat = ponto.latitude;
      }

      if (ponto.latitude > maxLat) {
        maxLat = ponto.latitude;
      }

      if (ponto.longitude < minLng) {
        minLng = ponto.longitude;
      }

      if (ponto.longitude > maxLng) {
        maxLng = ponto.longitude;
      }
    }

    final limites = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await mapaController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        limites,
        60,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rota até o SESI 357'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-21.469, -47.007),
                zoom: 11,
              ),
              markers: marcadores,
              polylines: rotas,
              myLocationEnabled: false,
              zoomControlsEnabled: true,
              onMapCreated: (controller) {
                mapaController = controller;
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car,
                      color: Colors.blue,
                      size: 32,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Rota de carro',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  distancia,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  tempo,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed:
                        carregando ? null : calcularRota,
                    icon: carregando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.directions_car,
                          ),
                    label: Text(
                      carregando
                          ? 'Calculando...'
                          : 'Calcular rota',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}