import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class QuestionStorage {
  static const String fileName = 'preguntas_descargadas.json';

  static Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = dir.path;
    return File('$path/$fileName');
  }

  static Future<List<Map<String, dynamic>>> readAll() async {
    try {
      final file = await _localFile();
      if (!await file.exists()) {
        await file.writeAsString('[]');
        return [];
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        await file.writeAsString('[]');
        return [];
      }

      final data = jsonDecode(content);
      if (data is! List) {
        await file.writeAsString('[]');
        return [];
      }

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      final file = await _localFile();
      await file.writeAsString('[]');
      return [];
    }
  }

  static Future<void> writeAll(List<Map<String, dynamic>> list) async {
    final file = await _localFile();
    await file.writeAsString(jsonEncode(list), flush: true);
  }

  static Future<void> clear() async {
    final file = await _localFile();
    if (await file.exists()) await file.writeAsString('[]', flush: true);
  }
}
