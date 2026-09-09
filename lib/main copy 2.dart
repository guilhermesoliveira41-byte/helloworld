import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Distância até minha casa',
      home: LocalizacaoPage(),
    );
  }
}

class LocalizacaoPage extends StatefulWidget {
  const LocalizacaoPage({super.key});

  @override
  State<LocalizacaoPage> createState() => _LocalizacaoPageState();
}

class _LocalizacaoPageState extends State<LocalizacaoPage> {
  double distancia = 0;

  final double latitudeCasa = -21.37133544477965;
  final double longitudeCasa = -46.944259133191;


  Future<void> calcularDistancia() async {
    bool servicoAtivo = await Geolocator.isLocationServiceEnabled();

    if (!servicoAtivo) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permissao = await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      return;
    }

    // Localização atual, que será a escola
    Position posicaoAtual = await Geolocator.getCurrentPosition();

    // O Geolocator retorna a distância em metros
    double distanciaEmMetros = Geolocator.distanceBetween(
      posicaoAtual.latitude,
      posicaoAtual.longitude,
      latitudeCasa,
      longitudeCasa,
    );

    setState(() {
      // Converte metros para quilômetros
      distancia = distanciaEmMetros / 1000;
    });

    print('Distância: $distancia km');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Distância até minha casa')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.home, size: 80, color: Colors.blue),

              const SizedBox(height: 20),

              const Text(
                'Distância entre a escola e minha casa',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              Text(
                distancia == 0
                    ? 'Clique no botão para calcular'
                    : 'Distância: ${distancia.toStringAsFixed(2)} km',
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: calcularDistancia,
                child: const Text('Calcular distância'),
                
               position novaPosicao = awalt geolocator.getCurrentPosition();  

                mapaController crow( 

                  @override 
                  widget initState() {
                    super.initState();

                    body: FlutterMap:
                    mapController: mapController,


                  

                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}