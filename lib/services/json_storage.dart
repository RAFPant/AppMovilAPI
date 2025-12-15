import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class JsonStorage {
  static const String fileName = 'encuestas_pendientes.json';

  static Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = dir.path;
    return File('$path/$fileName');
  }

  /// Lee todas las encuestas pendientes (solo JSON válido)
  static Future<List<Map<String, dynamic>>> readAll() async {
    try {
      final file = await _localFile();

      if (!await file.exists()) {
        await file.writeAsString("[]");
        return [];
      }

      String content = await file.readAsString();

      // Si está vacío → corregir automáticamente
      if (content.trim().isEmpty) {
        await file.writeAsString("[]");
        return [];
      }

      // Intentar decodificar
      dynamic data = jsonDecode(content);

      if (data is! List) {
        // archivo corrupto → se resetea
        await file.writeAsString("[]");
        return [];
      }

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      // Si está corrupto → lo repara
      final file = await _localFile();
      await file.writeAsString("[]");
      return [];
    }
  }

  /// Añade una encuesta al final
  static Future<void> append(Map<String, dynamic> encuesta) async {
    final all = await readAll();
    all.add(encuesta);
    await _write(all);
  }

  /// Reescribir todo
  static Future<void> _write(List<Map<String, dynamic>> list) async {
    final file = await _localFile();
    await file.writeAsString(jsonEncode(list), flush: true);
  }

  /// Elimina una encuesta
  static Future<void> removeAt(int index) async {
    final all = await readAll();
    if (index < 0 || index >= all.length) return;
    all.removeAt(index);
    await _write(all);
  }

  /// Reemplaza todas
  static Future<void> replaceAll(List<Map<String, dynamic>> list) async {
    await _write(list);
  }
}
