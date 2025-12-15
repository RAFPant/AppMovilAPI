# flutter_application_2


## 1. Descripción general

La aplicación móvil fue desarrollada como una herramienta de levantamiento de encuestas en campo, diseñada para funcionar de manera **offline** y posteriormente sincronizar la información con una base de datos central mediante una **API**.

Su objetivo principal es permitir al encuestador:

- Descargar preguntas
- Aplicar encuestas sin conexión a internet (con json)
- Almacenar los datos localmente
- Subir la información cuando exista conectividad

---

## 2. Tecnologías utilizadas

- **Framework:** Flutter  
- **Lenguaje:** Dart    
- **Consumo de API:** HTTP REST  
- **Plataforma objetivo:** Android  

### Justificación de tecnologías

- **Flutter** permite desarrollo multiplataforma con buen rendimiento.
- **HTTP REST** facilita la comunicación con la base de datos central.
- **Dart** permite tipado fuerte y mejor control de errores.

---

## 3. Estructura funcional de la aplicación

### 3.1 Panel principal

La aplicación inicia directamente en un **panel principal**, ya que no cuenta con sistema de inicio de sesión ni manejo de roles.

El panel contiene las siguientes opciones:

- **Probar conexión con la API**
  - Verifica la conectividad con el servidor.
  - Confirma la disponibilidad del backend.

- **Descargar preguntas**
  - Consume la API.
  - Guarda preguntas y dimensiones
  - Permite trabajar sin conexión.

- **Abrir encuesta**
  - Muestra las preguntas descargadas.
  - Permite capturar respuestas abiertas y cerradas.

- **Guardar encuesta**
  - Almacena las respuestas localmente.
  - La encuesta queda pendiente de sincronización.

- **Subir encuestas**
  - Envía las encuestas pendientes al servidor.
  - Actualiza el estado local a **sincronizada**.

- **Indicador de encuestas pendientes**
  - Muestra cuántas encuestas están almacenadas en el dispositivo.

---

## 4. Flujo de funcionamiento

1. El usuario abre la aplicación.
2. Prueba la conexión con la API.
3. Descarga preguntas y dimensiones.
4. Aplica encuestas sin conexión a internet.
5. Guarda las respuestas en SQLite.
6. Cuando hay conectividad, sube las encuestas al servidor.

---

## 5. Base de datos local (SQLite)

La aplicación utiliza **json** para almacenar:

- Preguntas
- Dimensiones
- Opciones de respuesta
- Respuestas capturadas
- Estado de sincronización

Esto permite el uso completo de la aplicación sin conexión a internet.

---

## 6. Relación con la base de datos central

La aplicación **NO accede directamente a MySQL**.  
Toda la comunicación se realiza mediante servicios **API**, los cuales:

- Obtienen preguntas y dimensiones
- Envían las respuestas capturadas al servidor

---

## 7. Ventajas del diseño

- Funcionamiento offline (mediante la cache del json descargado anteriormente lo tenia en sqlite pero hubo complicasiones)
- Reducción de pérdida de datos
- Independencia de la conectividad
- Escalabilidad del sistema

## Detalles de uso y advertencias

- recordar cambiar la direccion ip que esta en api_service   static const String baseUrl = "http://192.168.1.65/encuestas/encuestas_api"; te preguntaras porque aqui hay una carpeta diferente a la ya subida en el arepositorio anterior y es por el hecho de que en si fueron 2 pero en cada uno se experimentaban cosas diferente dando como final el de paginaweb las apis son lo mismo solo cambia a   static const String baseUrl = "http://192.168.1.65/"paginaweb"/encuestas_api";
- si has leido en el repositorio anterior sabras que nos e a probado por completo la funcion de subir preguntas al 100 pero si las sube pero no de manera completa por lo que hay que arreglarlo
.nota adicional no soy bueno para el diseño 
- ademas falta agregar el uso de roles y hacer que el apartado del cuestioanrio del encuestador sea automatico

