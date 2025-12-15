// lib/models/pregunta.dart
class Pregunta {
  final int id;
  final int idDimension;
  final String texto;
  final String tipo; // "abierta" o "cerrada"
  final String dimension; // nombre de la dimensión
  final List<Map<String, dynamic>> opciones; // si es cerrada

  Pregunta({
    required this.id,
    required this.idDimension,
    required this.texto,
    required this.tipo,
    required this.dimension,
    required this.opciones,
  });

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    final opts = <Map<String, dynamic>>[];
    if (json.containsKey('opciones') && json['opciones'] is List) {
      for (var o in json['opciones']) {
        if (o is Map) {
          opts.add(Map<String, dynamic>.from(o));
        } else if (o is Map<String, dynamic>) {
          opts.add(o);
        }
      }
    }
    return Pregunta(
      id: int.parse(json['id'].toString()),
      idDimension: json.containsKey('id_dimension')
          ? int.parse(json['id_dimension'].toString())
          : (json.containsKey('idDimension') ? int.parse(json['idDimension'].toString()) : 0),
      texto: json['texto']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? 'abierta',
      dimension: json['dimension']?.toString() ?? '',
      opciones: opts,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'id_dimension': idDimension,
        'texto': texto,
        'tipo': tipo,
        'dimension': dimension,
        'opciones': opciones,
      };
}
