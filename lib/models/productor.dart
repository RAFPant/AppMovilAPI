// lib/models/productor.dart
class Productor {
  String estado;
  String municipio;
  String localidad;

  String fechaAplicacion;
  String horaAplicacion;

  String nombreEncuestador;
  String nombreProductor;
  String sexo;
  int edad;
  String escolaridad;
  int tiempoDedicadoAnios;
  int numPersonasHogar;
  int hombresAdultos;
  int mujeresAdultas;
  int ninos;
  int ninas;
  bool tieneTelefono;
  bool tieneRadio;
  bool recibioApoyo;
  String apoyoCual;

  Productor({
    required this.estado,
    required this.municipio,
    required this.localidad,
    required this.fechaAplicacion,
    required this.horaAplicacion,
    required this.nombreEncuestador,
    required this.nombreProductor,
    required this.sexo,
    required this.edad,
    required this.escolaridad,
    required this.tiempoDedicadoAnios,
    required this.numPersonasHogar,
    required this.hombresAdultos,
    required this.mujeresAdultas,
    required this.ninos,
    required this.ninas,
    required this.tieneTelefono,
    required this.tieneRadio,
    required this.recibioApoyo,
    required this.apoyoCual,
  });

  Map<String, dynamic> toJson() => {
        "estado": estado,
        "municipio": municipio,
        "localidad": localidad,
        "fecha_aplicacion": fechaAplicacion,
        "hora_aplicacion": horaAplicacion,
        "nombre_encuestador": nombreEncuestador,
        "nombre_productor": nombreProductor,
        "sexo": sexo,
        "edad": edad,
        "escolaridad": escolaridad,
        "tiempo_dedicado_anios": tiempoDedicadoAnios,
        "num_personas_hogar": numPersonasHogar,
        "hombres_adultos": hombresAdultos,
        "mujeres_adultas": mujeresAdultas,
        "ninos": ninos,
        "ninas": ninas,
        "tiene_telefono": tieneTelefono ? 1 : 0,
        "tiene_radio": tieneRadio ? 1 : 0,
        "recibio_apoyo": recibioApoyo ? 1 : 0,
        "apoyo_cual": apoyoCual,
      };
}
