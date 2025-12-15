import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ApiTestApp());
}

class ApiTestApp extends StatelessWidget {
  const ApiTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Pruebas API",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TestMenu(),
    );
  }
}

// Pantalla de menú
class TestMenu extends StatelessWidget {
  const TestMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Panel de Pruebas API")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Probar obtener preguntas"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TestObtenerPreguntas()),
                );
              },
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              child: const Text("Probar subir respuestas"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TestSubirRespuestas()),
                );
              },
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              child: const Text("Probar conexión simple"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TestConexionSimple()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


// --------------------------------------
// 1) PROBAR obtener_preguntas.php
// --------------------------------------
class TestObtenerPreguntas extends StatefulWidget {
  const TestObtenerPreguntas({super.key});

  @override
  State<TestObtenerPreguntas> createState() => _TestObtenerPreguntasState();
}

class _TestObtenerPreguntasState extends State<TestObtenerPreguntas> {
  String status = "Presiona el botón para iniciar.";
  List<dynamic> preguntas = [];

  final String url = "http://192.168.6.71/encuestas/obtener_preguntas.php";

  Future<void> probar() async {
    setState(() {
      status = "Conectando...";
      preguntas = [];
    });

    try {
      final r = await http.get(Uri.parse(url));

      if (r.statusCode == 200) {
        final data = json.decode(r.body);

        setState(() {
          preguntas = data;
          status = "Éxito: ${preguntas.length} preguntas recibidas.";
        });
      } else {
        setState(() {
          status = "Error HTTP: ${r.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        status = "ERROR: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prueba obtener_preguntas.php")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(status),
          ),
          ElevatedButton(
            onPressed: probar,
            child: const Text("Probar servicio"),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: preguntas.length,
              itemBuilder: (_, i) {
                final p = preguntas[i];
                return ListTile(
                  title: Text(p["texto"] ?? "Sin texto"),
                  subtitle: Text("${p["tipo"]} - ${p["dimension"]}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// --------------------------------------
// 2) PROBAR subir_respuestas.php
// --------------------------------------
class TestSubirRespuestas extends StatefulWidget {
  const TestSubirRespuestas({super.key});

  @override
  State<TestSubirRespuestas> createState() => _TestSubirRespuestasState();
}

class _TestSubirRespuestasState extends State<TestSubirRespuestas> {
  String status = "Presiona el botón para enviar una respuesta.";

  final String url = "http://192.168.6.71/encuestas/subir_respuestas.php";

  Future<void> probarEnvio() async {
    setState(() => status = "Enviando...");

    final List<Map<String, dynamic>> respuestaPrueba = [
      {
        "id_pregunta": 1,
        "nombre_productor": "PRUEBA DESDE APP",
        "respuesta": "Mi respuesta de prueba",
        "fecha": "2025-01-01"
      }
    ];

    try {
      final r = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(respuestaPrueba),
      );

      if (r.statusCode == 200) {
        setState(() => status = "Éxito: ${r.body}");
      } else {
        setState(() => status = "Error HTTP: ${r.statusCode}");
      }
    } catch (e) {
      setState(() => status = "ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prueba subir_respuestas.php")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(status),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: probarEnvio,
              child: const Text("Enviar respuesta de prueba"),
            )
          ],
        ),
      ),
    );
  }
}


// --------------------------------------
// 3) PROBAR CONEXIÓN SIMPLE
// --------------------------------------
class TestConexionSimple extends StatefulWidget {
  const TestConexionSimple({super.key});

  @override
  State<TestConexionSimple> createState() => _TestConexionSimpleState();
}

class _TestConexionSimpleState extends State<TestConexionSimple> {
  String resultado = "Esperando prueba.";

  Future<void> probarPing() async {
    setState(() => resultado = "Conectando...");

    try {
      final r = await http.get(
        Uri.parse("http://192.168.6.71/encuestas/obtener_preguntas.php"),
      );

      setState(() => resultado = "Respuesta HTTP: ${r.statusCode}");
    } catch (e) {
      setState(() => resultado = "ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prueba rápida de conexión")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(resultado),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: probarPing,
              child: const Text("Probar conexión"),
            )
          ],
        ),
      ),
    );
  }
}
