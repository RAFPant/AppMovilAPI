// lib/services/db_service.dart
//
// Este archivo queda como "servicio vacío" para mantener compatibilidad
// con el código antiguo, pero YA NO usa SQLite.

import '../models/pregunta.dart';

class DBService {
  /// Ya no se usa SQLite.
  /// Las preguntas vienen desde la API y se guardan en memoria o se pasan como parámetro.
  static Future<void> guardarPreguntas(List<Pregunta> preguntas) async {
    // Esta función queda vacía para compatibilidad.
    return;
  }

  /// Ya no se usa. Las preguntas se cargan desde la API.
  static Future<List<Pregunta>> obtenerPreguntas() async {
    return [];
  }

  /// Ya no se usan respuestas en SQLite.
  static Future<void> guardarRespuesta(Map<String, dynamic> r) async {
    return;
  }

  /// No se usa (json_storage.dart maneja las encuestas reales).
  static Future<List<Map<String, dynamic>>> obtenerRespuestasPendientes() async {
    return [];
  }

  /// Vacío por compatibilidad.
  static Future<void> limpiarRespuestas() async {
    return;
  }
}
