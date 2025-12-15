// lib/pages/responder_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pregunta.dart';
import '../models/productor.dart';
import '../services/json_storage.dart';
import '../services/api_service.dart';

class ResponderPage extends StatefulWidget {
  final List<Pregunta> preguntasAll;
  const ResponderPage({super.key, required this.preguntasAll});

  @override
  State<ResponderPage> createState() => _ResponderPageState();
}

class _ResponderPageState extends State<ResponderPage> {
  Map<String, List<Pregunta>> preguntasPorDimension = {};
  Map<int, String> respuestas = {};
  Map<int, int?> respuestasIdOpcion = {};
  Productor? productor;
  int paginaActual = 0;
  final Map<String, TextEditingController> _ctrls = {};

  @override
  void initState() {
    super.initState();
    _groupPreguntas(widget.preguntasAll);
    _crearProductorVacio();
    sincronizarPendientes(); // intenta sincronizar al abrir
  }

  void _groupPreguntas(List<Pregunta> list) {
    final Map<String, List<Pregunta>> agrupadas = {};
    for (var p in list) {
      final key = p.idDimension.toString();
      agrupadas.putIfAbsent(key, () => []);
      agrupadas[key]!.add(p);
    }
    setState(() => preguntasPorDimension = agrupadas);
  }

  void _crearProductorVacio() {
    final now = DateTime.now();
    final fecha = DateFormat('yyyy-MM-dd').format(now);
    final hora = DateFormat('HH:mm').format(now);
    productor = Productor(
      estado: '',
      municipio: '',
      localidad: '',
      fechaAplicacion: fecha,
      horaAplicacion: hora,
      nombreEncuestador: '',
      nombreProductor: '',
      sexo: '',
      edad: 0,
      escolaridad: '',
      tiempoDedicadoAnios: 0,
      numPersonasHogar: 0,
      hombresAdultos: 0,
      mujeresAdultas: 0,
      ninos: 0,
      ninas: 0,
      tieneTelefono: false,
      tieneRadio: false,
      recibioApoyo: false,
      apoyoCual: '',
    );
  }

  Widget _textField(String label, String key, {bool isNumber = false, int maxLines = 1}) {
    _ctrls.putIfAbsent(key, () => TextEditingController());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: _ctrls[key],
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        onChanged: (v) => _setProductorField(key, v),
      ),
    );
  }

  Widget _dropdownSexo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<String>(
        initialValue: productor!.sexo.isEmpty ? null : productor!.sexo,
        decoration: const InputDecoration(labelText: 'Sexo', border: OutlineInputBorder()),
        items: ['Masculino', 'Femenino', 'Otro'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => setState(() => productor!.sexo = v ?? ''),
      ),
    );
  }

  Widget _switch(String label, String key) {
    bool value = false;
    switch (key) {
      case 'tiene_telefono':
        value = productor!.tieneTelefono;
        break;
      case 'tiene_radio':
        value = productor!.tieneRadio;
        break;
      case 'recibio_apoyo':
        value = productor!.recibioApoyo;
        break;
    }
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: (v) {
        setState(() {
          if (key == 'tiene_telefono') productor!.tieneTelefono = v;
          if (key == 'tiene_radio') productor!.tieneRadio = v;
          if (key == 'recibio_apoyo') productor!.recibioApoyo = v;
        });
      },
    );
  }

  void _setProductorField(String key, String v) {
    setState(() {
      switch (key) {
        case 'estado':
          productor!.estado = v;
          break;
        case 'municipio':
          productor!.municipio = v;
          break;
        case 'localidad':
          productor!.localidad = v;
          break;
        case 'nombre_encuestador':
          productor!.nombreEncuestador = v;
          break;
        case 'nombre_productor':
          productor!.nombreProductor = v;
          break;
        case 'edad':
          productor!.edad = int.tryParse(v) ?? 0;
          break;
        case 'escolaridad':
          productor!.escolaridad = v;
          break;
        case 'tiempo_dedicado_anios':
          productor!.tiempoDedicadoAnios = int.tryParse(v) ?? 0;
          break;
        case 'num_personas_hogar':
          productor!.numPersonasHogar = int.tryParse(v) ?? 0;
          break;
        case 'hombres_adultos':
          productor!.hombresAdultos = int.tryParse(v) ?? 0;
          break;
        case 'mujeres_adultas':
          productor!.mujeresAdultas = int.tryParse(v) ?? 0;
          break;
        case 'ninos':
          productor!.ninos = int.tryParse(v) ?? 0;
          break;
        case 'ninas':
          productor!.ninas = int.tryParse(v) ?? 0;
          break;
        case 'apoyo_cual':
          productor!.apoyoCual = v;
          break;
      }
    });
  }

  Future<void> guardarEncuestaLocal() async {
    if ((productor!.nombreProductor.trim()).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes ingresar el nombre del productor')));
      return;
    }

    final preguntasPayload = <Map<String, dynamic>>[];
    preguntasPorDimension.forEach((key, lista) {
      for (var p in lista) {
        final respText = respuestas[p.id] ?? '';
        final idOp = respuestasIdOpcion[p.id];
        preguntasPayload.add({
          "id_pregunta": p.id,
          "id_dimension": p.idDimension,
          "tipo": p.tipo,
          "texto_pregunta": p.texto,
          "respuesta_texto": p.tipo == 'abierta' ? respText : null,
          "id_opcion": p.tipo == 'cerrada' ? idOp : null,
        });
      }
    });

    final payload = {
      "productor": productor!.toJson(),
      "preguntas": preguntasPayload,
    };

    bool ok = false;
    try {
      ok = await ApiService.subirEncuesta(payload);
    } catch (_) {
      ok = false;
    }

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Encuesta subida correctamente')));
    } else {
      await JsonStorage.append(payload);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sin internet: encuesta guardada localmente')));
    }

    Navigator.pop(context);
  }

  Future<void> sincronizarPendientes() async {
    final pendientes = await JsonStorage.readAll();
    if (pendientes.isEmpty) return;
    for (int i = 0; i < pendientes.length; i++) {
      final p = pendientes[i];
      try {
        final ok = await ApiService.subirEncuesta(p);
        if (ok) {
          await JsonStorage.removeAt(0);
        } else {
          break;
        }
      } catch (_) {
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (preguntasPorDimension.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Responder Encuesta')),
        body: const Center(child: Text('No hay preguntas cargadas')),
      );
    }

    final dimensiones = preguntasPorDimension.keys.toList();
    final totalPages = 1 + dimensiones.length; // page 0 = productor, following pages = dimensiones
    final bool isProductPage = paginaActual == 0;
    final lista = isProductPage
      ? <Pregunta>[]
      : preguntasPorDimension[dimensiones[paginaActual - 1]]!;
    final dimKey = isProductPage ? null : dimensiones[paginaActual - 1];

    return Scaffold(
      appBar: AppBar(title: const Text('Responder Encuesta')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            if (isProductPage) ...[
              const Text('Datos del Productor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _textField('Estado', 'estado'),
              _textField('Municipio', 'municipio'),
              _textField('Localidad', 'localidad'),
              Padding(padding: const EdgeInsets.symmetric(vertical: 6.0), child: Text('Fecha: ${productor!.fechaAplicacion}   Hora: ${productor!.horaAplicacion}')),
              _textField('Nombre del encuestador', 'nombre_encuestador'),
              _textField('Nombre del productor', 'nombre_productor'),
              _dropdownSexo(),
              _textField('Edad', 'edad', isNumber: true),
              _textField('Escolaridad', 'escolaridad'),
              _textField('Tiempo dedicado (años)', 'tiempo_dedicado_anios', isNumber: true),
              _textField('Personas en el hogar', 'num_personas_hogar', isNumber: true),
              _textField('Hombres adultos', 'hombres_adultos', isNumber: true),
              _textField('Mujeres adultas', 'mujeres_adultas', isNumber: true),
              _textField('Niños', 'ninos', isNumber: true),
              _textField('Niñas', 'ninas', isNumber: true),
              _switch('Tiene teléfono', 'tiene_telefono'),
              _switch('Tiene radio', 'tiene_radio'),
              _switch('Recibió apoyo', 'recibio_apoyo'),
              _textField('¿Cuál apoyo?', 'apoyo_cual'),
              const SizedBox(height: 12),
            ],
            if (!isProductPage) Text('Dimensión: $dimKey', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...lista.map((p) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.texto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  p.tipo == 'abierta'
                      ? TextField(
                          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Respuesta abierta'),
                          maxLines: 2,
                          onChanged: (v) => respuestas[p.id] = v,
                        )
                      : Column(
                          children: p.opciones.map((op) {
                            final opId = op['id'];
                            final opText = op['texto_opcion'] ?? op['texto'] ?? op['textoOption'] ?? op['text'] ?? op.toString();
                            return RadioListTile<int>(
                              title: Text(opText.toString()),
                              value: int.tryParse(opId.toString()) ?? 0,
                              groupValue: respuestasIdOpcion[p.id] ?? -1,
                              onChanged: (val) {
                                setState(() {
                                  respuestasIdOpcion[p.id] = val;
                                  respuestas[p.id] = val?.toString() ?? '';
                                });
                              },
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 12),
                ],
              );
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (paginaActual > 0)
                  ElevatedButton.icon(onPressed: () => setState(() => paginaActual--), icon: const Icon(Icons.arrow_back), label: const Text('Anterior')),
                if (paginaActual < totalPages - 1)
                  ElevatedButton.icon(onPressed: () => setState(() => paginaActual++), icon: const Icon(Icons.arrow_forward), label: const Text('Siguiente')),
                if (paginaActual == totalPages - 1)
                  ElevatedButton.icon(onPressed: guardarEncuestaLocal, icon: const Icon(Icons.save), label: const Text('Guardar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await sincronizarPendientes();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Intento de sincronización realizado')));
              },
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar pendientes'),
            ),
          ],
        ),
      ),
    );
  }
}
