// lib/services/api_service.dart
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/pregunta.dart';

class ApiService {
  // Usa SIEMPRE la IP del WiFi real
  static const String baseUrl = "http://192.168.6.205/encuestas/encuestas_api";

  // -------------------------------------------------------
  // 1. Descargar preguntas
  // -------------------------------------------------------
  static Future<List<Pregunta>> descargarPreguntas() async {
    final uri = Uri.parse('$baseUrl/obtener_preguntas.php');

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data
            .map((e) => Pregunta.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        throw Exception(
            "HTTP ${res.statusCode} al descargar preguntas");
      }
    } catch (e) {
      throw Exception("Error al descargar preguntas: $e");
    }
  }

  // Alias
  static Future<bool> subirRespuestas(Map<String, dynamic> payload) async {
    return subirEncuesta(payload);
  }

  // -------------------------------------------------------
  // 2. Subir encuesta completa
  // -------------------------------------------------------
  static Future<bool> subirEncuesta(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/subir_encuesta.php');

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return false;

      final body = res.body.trim();

      if (body.isEmpty) return false;

      try {
        final decoded = jsonDecode(body);
        if (decoded is Map &&
            (decoded['success'] == true || decoded['ok'] == true)) {
          return true;
        }
      } catch (_) {
        if (body.toLowerCase().contains("ok")) return true;
      }
    } catch (_) {}

    return false;
  }

  // -------------------------------------------------------
  // 3. Probar conexión
  // -------------------------------------------------------
  static Future<Map<String, dynamic>> probarConexion() async {
    final uri = Uri.parse('$baseUrl/obtener_preguntas.php');

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        return {"ok": true, "error": "Conexión exitosa ✔"};
      }
      return {
        "ok": false,
        "error": "El servidor respondió HTTP ${res.statusCode}"
      };
    } on SocketException catch (e) {
      return {
        "ok": false,
        "error": "No se pudo conectar: ${e.message}\n"
            "- Verifica red WiFi\n"
            "- Verifica firewall\n"
            "- Verifica carpeta /encuestas"
      };
    } on TimeoutException {
      return {"ok": false, "error": "Tiempo de espera agotado (timeout)."};
    } catch (e) {
      return {"ok": false, "error": "Error desconocido: $e"};
    }
  }
}
