import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meu Mapa',
      home: const MapaPage(),
    );
  }
}

// Página do mapa
class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  Position? posicao;

  final MapController mapaController = MapController();

  bool procurandoLocalizacao = false;

  // Procura a localização novamente
  Future<void> procurarLocalizacao() async {
    if (procurandoLocalizacao) return;

    setState(() {
      procurandoLocalizacao = true;
    });

    try {
      // Verifica se o serviço de localização está ligado
      bool servicoAtivo = await Geolocator.isLocationServiceEnabled();

      if (!servicoAtivo) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ative a localização do celular/computador.'),
          ),
        );

        return;
      }

      // Verifica a permissão
      LocationPermission permissao =
          await Geolocator.checkPermission();

      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied ||
          permissao == LocationPermission.deniedForever) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão de localização negada.'),
          ),
        );

        return;
      }

      // FORÇA uma nova busca da localização
      Position novaPosicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );

      setState(() {
        posicao = novaPosicao;
      });

      // Move o mapa para a nova localização
      mapaController.move(
        LatLng(
          novaPosicao.latitude,
          novaPosicao.longitude,
        ),
        16,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar localização: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          procurandoLocalizacao = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Mapa'),
      ),

      body: Stack(
        children: [
          // MAPA
          FlutterMap(
            mapController: mapaController,
            options: const MapOptions(
              initialCenter: LatLng(
                -21.458734302408228,
                -46.99401638348058,
              ),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mapa_flutter',
              ),

              // Marcador da localização atual
              if (posicao != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        posicao!.latitude,
                        posicao!.longitude,
                      ),
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.purple,
                        size: 45,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // BOTÃO DE LOCALIZAÇÃO
          Positioned(
            top: 15,
            right: 15,
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: procurarLocalizacao,
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: const BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: procurandoLocalizacao
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}