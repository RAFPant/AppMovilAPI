// lib/pages/home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/json_storage.dart';
import '../services/question_storage.dart';
import '../models/pregunta.dart';
import 'responder_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Pregunta> preguntas = [];
  bool cargando = false;
  int pendientesCount = 0;

  @override
  void initState() {
    super.initState();
    _actualizarPendientesCount();
    _loadCachedQuestions();
  }

  Future<void> _loadCachedQuestions() async {
    try {
      final all = await QuestionStorage.readAll();
      if (all.isEmpty) return;
      final list = all.map((m) => Pregunta.fromJson(m)).toList();
      setState(() => preguntas = list);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preguntas cargadas desde caché (${preguntas.length})')),
      );
    } catch (_) {}
  }

  Future<void> _actualizarPendientesCount() async {
    final all = await JsonStorage.readAll();
    setState(() => pendientesCount = all.length);
  }

  Future<void> _descargarFormulario() async {
    setState(() => cargando = true);
    try {
      final list = await ApiService.descargarPreguntas();
      setState(() => preguntas = list);
      // Guardar en caché como JSON para lectura en reinicios
      try {
        await QuestionStorage.writeAll(list.map((p) => p.toMap()).toList());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Formulario descargado y guardado (${preguntas.length} preguntas)')),
        );
      } catch (_) {
        // ignore file write errors
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar preguntas: $e')),
      );
    } finally {
      setState(() => cargando = false);
    }
  }

  void _irResponder() {
    if (preguntas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero descarga el formulario')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResponderPage(preguntasAll: preguntas)),
    ).then((_) => _actualizarPendientesCount());
  }

  Future<void> _subirPendientes() async {
    setState(() => cargando = true);
    try {
      final pendientes = await JsonStorage.readAll();
      if (pendientes.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No hay encuestas pendientes')));
        return;
      }

      int subidas = 0;

      for (int i = 0; i < pendientes.length; i++) {
        final payload = pendientes.first;
        final ok = await ApiService.subirEncuesta(payload);
        if (ok) {
          await JsonStorage.removeAt(0);
          subidas++;
        } else {
          break; 
        }
      }

      await _actualizarPendientesCount();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Encuestas subidas: $subidas')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al subir pendientes: $e')));
    } finally {
      setState(() => cargando = false);
    }
  }

  // =====================================================
  //   NUEVA FUNCIÓN: PROBAR CONEXIÓN
  // =====================================================
  Future<void> _probarConexion() async {
    setState(() => cargando = true);

    final result = await ApiService.probarConexion();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result["error"])),
    );

    setState(() => cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Encuestas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Encuestas pendientes'),
                subtitle: const Text('Encuestas sin subir en dispositivo'),
                trailing: CircleAvatar(child: Text(pendientesCount.toString())),
              ),
            ),
            const SizedBox(height: 12),

            // NUEVO BOTÓN DE PROBAR CONEXIÓN
            ElevatedButton.icon(
              onPressed: cargando ? null : _probarConexion,
              icon: const Icon(Icons.wifi_tethering),
              label: const Text("Probar conexión con servidor"),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: cargando ? null : _descargarFormulario,
              icon: const Icon(Icons.cloud_download),
              label: Text(cargando ? 'Descargando...' : 'Descargar / Actualizar formulario'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _irResponder,
              icon: const Icon(Icons.edit),
              label: const Text('Responder formulario'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: cargando ? null : _subirPendientes,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Subir encuestas pendientes'),
            ),
            const SizedBox(height: 20),


          ],
        ),
      ),
    );
  }
}
