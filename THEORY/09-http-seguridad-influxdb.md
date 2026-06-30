# Teoría Detallada — Bloque 09: HTTP/CORS, Seguridad Básica e InfluxDB con Node-RED

Este bloque cierra los huecos identificados como bloqueantes para que Denki escale más allá de un cliente piloto: comunicación HTTP a fondo (incluyendo el problema de CORS, que **sí o sí** aparecerá al conectar el panel Vue con la API de Node-RED), seguridad básica de aplicaciones web, y una base de datos real de series temporales (InfluxDB) en vez de archivos CSV sueltos. Se ubica conceptualmente entre el Bloque 08 (Node-RED) y el cierre del plan, ya que requiere ambos para tener sentido práctico completo.

---

## PARTE 1 — HTTP a fondo

### 1.1 ¿Qué es realmente una petición HTTP?

Cada vez que el navegador (o `fetch`, o un nodo `http request` de Node-RED) pide algo a un servidor, viaja una **petición HTTP** con esta estructura:

```
GET /api/lecturas HTTP/1.1
Host: api.denkipower.com
Content-Type: application/json
Authorization: Bearer eyJhbGc...

(cuerpo, si aplica)
```

- **Método**: la acción que se quiere realizar (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`).
- **Ruta**: el recurso solicitado (`/api/lecturas`).
- **Headers**: metadatos sobre la petición (qué tipo de contenido se envía, credenciales, etc.).
- **Cuerpo (body)**: los datos enviados, normalmente en `POST`/`PUT`.

Y el servidor responde con:
```
HTTP/1.1 200 OK
Content-Type: application/json

{ "sensor": "BMP280", "valor": 24.3 }
```

### 1.2 Métodos HTTP y su significado real

| Método | Uso típico | ¿Modifica datos? |
|---|---|---|
| `GET` | Obtener un recurso (lista de sensores, una lectura) | No |
| `POST` | Crear un recurso nuevo (registrar un dispositivo) | Sí |
| `PUT` | Reemplazar un recurso completo (actualizar configuración completa de un sensor) | Sí |
| `PATCH` | Modificar parcialmente un recurso (cambiar solo el umbral de alerta) | Sí |
| `DELETE` | Eliminar un recurso (dar de baja un dispositivo) | Sí |

Una API bien diseñada (llamada **API RESTful**) organiza sus rutas alrededor de **recursos** (sustantivos, no verbos):
```
GET    /api/dispositivos          → lista todos los dispositivos
GET    /api/dispositivos/5         → obtiene el dispositivo con id 5
POST   /api/dispositivos             → crea un dispositivo nuevo
PATCH  /api/dispositivos/5             → actualiza parcialmente el dispositivo 5
DELETE /api/dispositivos/5               → elimina el dispositivo 5
```
Nota que el **método** indica la acción, no la ruta (sería un anti-patrón tener `/api/crearDispositivo` o `/api/eliminarDispositivo/5`).

### 1.3 Códigos de estado HTTP

Cada respuesta incluye un código numérico de 3 dígitos que indica qué pasó:

- **2xx — Éxito**: `200 OK` (éxito general), `201 Created` (se creó un recurso nuevo), `204 No Content` (éxito, sin cuerpo de respuesta, común en `DELETE`).
- **3xx — Redirección**: `301 Moved Permanently`, `304 Not Modified` (el navegador puede usar su copia en caché).
- **4xx — Error del cliente** (quien hizo la petición se equivocó): `400 Bad Request` (datos mal formados), `401 Unauthorized` (no hay credenciales válidas), `403 Forbidden` (hay credenciales, pero no tiene permiso), `404 Not Found` (el recurso no existe).
- **5xx — Error del servidor** (el problema es del lado del servidor, no de quien preguntó): `500 Internal Server Error` (error genérico no manejado), `503 Service Unavailable` (el servidor está temporalmente caído o saturado).

**Por qué importa revisar el código de estado en el código**, no solo asumir que todo salió bien:
```js
const respuesta = await fetch("/api/dispositivos/5");
if (!respuesta.ok) { // .ok es true solo para códigos 2xx
  if (respuesta.status === 404) {
    console.error("El dispositivo no existe");
  } else if (respuesta.status === 401) {
    console.error("No tienes permiso, inicia sesión de nuevo");
  } else {
    console.error("Error inesperado del servidor");
  }
}
```
Esto conecta directamente con el manejo de los 3 estados de UI visto en el Bloque 02/3 (cargando/error/éxito): el código de estado es lo que te permite dar un mensaje de error **específico y útil**, en vez de un genérico "algo salió mal".

### 1.4 Headers importantes

```
Content-Type: application/json       → indica el formato del cuerpo (JSON, formularios, etc.)
Authorization: Bearer <token>          → credenciales de autenticación
Cache-Control: no-cache                 → instrucciones sobre cómo cachear la respuesta
```

### 1.5 CORS: el problema que SÍ te va a aparecer

**El escenario real de Denki**: tu panel Vue está desplegado en `https://app.denkipower.com`, y hace una petición `fetch` al endpoint de Node-RED corriendo en `https://api.denkipower.com` (o incluso en una IP/puerto distinto en la red local). Por defecto, **el navegador bloqueará esa petición**, y en la consola verás un error como:

```
Access to fetch at 'https://api.denkipower.com/lecturas' from origin 'https://app.denkipower.com'
has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present
```

**¿Por qué existe esta restricción?** CORS (Cross-Origin Resource Sharing) es una medida de seguridad del navegador que evita que un sitio web malicioso haga peticiones silenciosas a otros sitios usando las credenciales del usuario (por ejemplo, que una página falsa intente leer tu correo de Gmail aprovechando que ya tienes sesión iniciada). Por defecto, un sitio en un "origen" (combinación de protocolo + dominio + puerto) **no puede** leer la respuesta de una petición a un origen distinto, a menos que el servidor lo autorice explícitamente.

**La solución: el servidor debe responder con el header correcto.**

En el caso de Node-RED, dentro de un nodo `http response`, o configurando el `httpNodeCors` en `settings.js`:
```js
// settings.js
httpNodeCors: {
  origin: "https://app.denkipower.com", // o "*" para permitir cualquier origen (NO recomendado en producción)
  methods: "GET,POST,PATCH,DELETE"
}
```

**Regla de seguridad importante**: usar `origin: "*"` (permitir cualquier origen) es aceptable mientras se prueba localmente, pero en producción se debe restringir **exactamente** a los dominios que necesitan consumir la API (en este caso, solo `https://app.denkipower.com`), para no exponer el endpoint a que cualquier sitio en internet pueda leerlo desde el navegador de un usuario.

### 1.6 Idempotencia (concepto útil para entrevistas)

Un método HTTP es **idempotente** si llamarlo una vez o varias veces seguidas produce el mismo resultado final. `GET`, `PUT` y `DELETE` son idempotentes (eliminar el mismo dispositivo dos veces deja el mismo estado que eliminarlo una vez); `POST` normalmente **no** lo es (crear un dispositivo dos veces crea dos dispositivos distintos). Esto es relevante al diseñar reintentos automáticos ante fallas de red: reintentar un `GET` es seguro, reintentar un `POST` sin cuidado puede duplicar datos.

---

## PARTE 2 — Seguridad básica de aplicaciones web

### 2.1 XSS (Cross-Site Scripting)

Ocurre cuando una aplicación muestra contenido proporcionado por un usuario **sin sanitizarlo**, permitiendo que ese contenido incluya código JavaScript que se ejecute en el navegador de otros usuarios.

```js
// PELIGROSO si "comentario" viene de un usuario externo sin validar
elemento.innerHTML = comentario; // si comentario = "<img src=x onerror='robarDatos()'>", ese código se ejecuta
```

**Mitigación:**
- Usar `textContent` en vez de `innerHTML` siempre que el contenido sea texto plano (visto en el Bloque 02) — esto inserta el texto de forma literal, sin interpretarlo como HTML.
- Si se necesita insertar HTML controlado, usar librerías de sanitización (como `DOMPurify`) que eliminan código potencialmente peligroso antes de insertarlo.
- En Vue, la interpolación `{{ }}` **ya escapa automáticamente** el contenido (es segura por defecto); el riesgo aparece específicamente al usar `v-html`, que sí inserta HTML sin escapar — por eso `v-html` debe evitarse con contenido que provenga de un usuario o de una fuente no confiable.

### 2.2 Autenticación vs Autorización

- **Autenticación**: verificar **quién eres** (iniciar sesión con usuario/contraseña).
- **Autorización**: verificar **qué puedes hacer** una vez identificado (un cliente de Denki solo puede ver SUS dispositivos, no los de otro cliente).

> Esta es la base conceptual. La implementación robusta de "un cliente solo ve sus propios datos" cuando Denki tenga varios clientes (multi-tenancy) se desarrolla a fondo en el Bloque 11, sección 5, incluyendo por qué filtrar solo en el frontend es inseguro.

### 2.3 Tokens JWT (JSON Web Tokens) — concepto introductorio

Un patrón muy común para mantener una sesión sin necesidad de que el servidor "recuerde" cada usuario conectado: al iniciar sesión correctamente, el servidor genera un **token firmado** que contiene información del usuario (su id, por ejemplo), y el cliente lo guarda y lo envía en cada petición posterior:

```js
// El cliente envía el token en cada petición
fetch("/api/dispositivos", {
  headers: { Authorization: `Bearer ${token}` }
});
```

El servidor verifica que el token sea válido (no esté alterado ni expirado) sin necesidad de consultar una base de datos en cada petición, porque la firma del token garantiza su autenticidad. **Dónde guardar el token en el navegador** es una decisión de seguridad importante: `localStorage` es vulnerable a robo vía XSS (si hay una vulnerabilidad de la sección 2.1, el atacante puede leer el token); una cookie con flags `HttpOnly` y `Secure` es más segura porque JavaScript no puede leerla directamente, mitigando ese riesgo específico.

### 2.4 Variables de entorno y secretos (refuerzo del Bloque 07)

Nunca se debe escribir directamente en el código: contraseñas de bases de datos, claves de API, tokens de broker MQTT, secretos usados para firmar JWT. Todo esto va en variables de entorno (`.env`, excluido de Git), tanto en el frontend (Vite) como en Node-RED (usando el contexto global cargado desde un archivo no versionado, o variables de entorno del sistema operativo leídas con `process.env` dentro de un nodo `function`).

### 2.5 HTTPS y por qué no es opcional

Sin HTTPS, cualquier dato que viaje entre el navegador del cliente y el servidor de Denki (incluyendo credenciales y lecturas de sensores, que pueden ser información sensible de una instalación industrial) puede ser interceptado por cualquiera en la misma red. Como se vio en el Bloque 07, Vercel/Netlify lo activan automáticamente; para Node-RED corriendo en hardware propio, se debe configurar explícitamente (certificado SSL propio, o un reverse proxy como Nginx que termine el HTTPS antes de reenviar la petición a Node-RED internamente).

### 2.6 Validación de datos de entrada (defensa en profundidad)

Nunca confiar únicamente en la validación del frontend (formularios HTML, TypeScript): un atacante puede enviar peticiones directamente a la API sin pasar por el formulario. **Toda validación visible al usuario debe repetirse también en el servidor** (en este caso, dentro del nodo `function` de Node-RED que recibe la petición), rechazando datos mal formados antes de procesarlos o guardarlos.

```js
// dentro de un nodo function que recibe una nueva configuración de umbral
const umbral = msg.payload.umbral;

if (typeof umbral !== "number" || umbral < 0 || umbral > 200) {
  msg.statusCode = 400;
  msg.payload = { error: "Umbral inválido" };
  return msg; // se detiene aquí, nunca llega a guardarse un valor corrupto
}
```

---

## PARTE 3 — InfluxDB como base de datos de series temporales en Node-RED

### 3.1 ¿Por qué InfluxDB y no una base de datos relacional tradicional?

Las lecturas de sensores de Denki tienen una característica particular: son **datos con marca de tiempo, que llegan constantemente, y que casi siempre se consultan por rango de fechas** ("dame la temperatura de las últimas 24 horas", "el promedio de la última semana"). Una base de datos relacional tradicional (MySQL, PostgreSQL) puede almacenar esto, pero no está optimizada para ese patrón de uso a gran volumen.

**InfluxDB** es una base de datos diseñada específicamente para **series temporales** (time series): estructura sus datos pensando en el tiempo como eje principal, comprime eficientemente datos repetitivos a lo largo del tiempo, y ofrece un lenguaje de consulta optimizado para preguntas como "promedio por hora", "máximo de la última semana", que en SQL tradicional requerirían consultas más complejas y lentas a gran escala.

### 3.2 Conceptos fundamentales de InfluxDB

A diferencia de las tablas de una base relacional, InfluxDB organiza los datos así:

- **Measurement** (medición): el equivalente conceptual a una "tabla", agrupa datos del mismo tipo (ej. `lecturas_temperatura`).
- **Tags**: metadatos indexados, usados para **filtrar** (ej. `sensor_id=BMP280`, `ubicacion=planta1`). Los tags son ideales para valores que se repiten mucho y por los que filtras frecuentemente.
- **Fields**: los valores numéricos reales medidos (ej. `valor=24.3`, `presion=1013.2`). No están indexados de la misma forma que los tags.
- **Timestamp**: la marca de tiempo de cada punto, el eje central de toda la base de datos.

```
measurement: lecturas_temperatura
  tags: sensor_id=BMP280, ubicacion=planta1
  fields: valor=24.3, presion=1013.2
  timestamp: 2026-06-29T10:15:00Z
```

**Regla práctica para decidir tag vs field**: si vas a **filtrar o agrupar** por ese dato (por sensor, por ubicación, por estado), debe ser un `tag`. Si es el **valor medido** en sí (la temperatura, la presión), debe ser un `field`.

### 3.3 Instalación y conexión desde Node-RED

```bash
# InfluxDB puede correr en la misma Raspberry Pi/EDATEC, o en un servidor separado
docker run -p 8086:8086 influxdb:2.7
```

En Node-RED, se instala el paquete de nodos correspondiente:
```bash
npm install node-red-contrib-influxdb
```
Esto agrega nodos `influxdb out` (para escribir datos) e `influxdb in` (para consultar datos) a la paleta, configurables con la URL del servidor InfluxDB, el token de autenticación, la organización y el "bucket" (el contenedor de datos, conceptualmente similar a una "base de datos" dentro de InfluxDB).

### 3.4 Escribir lecturas de sensores (flujo de ingesta)

```
[sensor / simulación] → [function: dar formato] → [influxdb out]
```

```js
// dentro del nodo function, antes de influxdb out
msg.payload = [
  {
    measurement: "lecturas_temperatura",
    tags: { sensor_id: msg.payload.sensorId, ubicacion: "planta1" },
    fields: { valor: msg.payload.valor },
    timestamp: new Date()
  }
];
return msg;
```
El nodo `influxdb out` toma este objeto con la estructura measurement/tags/fields/timestamp y lo escribe directamente en la base de datos, sin necesidad de escribir consultas SQL manualmente.

### 3.5 Consultar datos históricos (lenguaje Flux, concepto)

InfluxDB usa un lenguaje de consulta llamado **Flux** (en versiones más nuevas) o el lenguaje tipo SQL **InfluxQL** (en versiones anteriores). Ejemplo de una consulta Flux típica, configurada dentro de un nodo `influxdb in`:

```flux
from(bucket: "denki")
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == "lecturas_temperatura")
  |> filter(fn: (r) => r.sensor_id == "BMP280")
  |> mean()
```

Explicación línea por línea: `from(bucket: "denki")` selecciona de dónde leer; `range(start: -24h)` limita la consulta a las últimas 24 horas (filtrado por tiempo, el caso de uso más común en series temporales); `filter(...)` aplica condiciones (equivalente a un `WHERE` en SQL); `mean()` calcula el promedio de los valores encontrados — todo esto en una sintaxis pensada específicamente para datos con tiempo como eje central, mucho más directa que el equivalente en SQL tradicional.

### 3.6 Alimentar el dashboard con datos históricos reales

```
[inject: cada vez que se abre el dashboard] → [influxdb in: consulta Flux] → [function: dar formato para chart] → [ui_chart]
```
En vez de que el `chart` del Dashboard acumule solo los datos que ha visto desde que se abrió la página (como en el Bloque 08 básico), ahora puede mostrar **histórico real almacenado**, incluso de antes de que el dashboard estuviera abierto — esto es indispensable para que un cliente de Denki pueda revisar, por ejemplo, "qué pasó con la temperatura mientras yo no estaba viendo el panel".

### 3.7 Retención de datos

InfluxDB permite configurar políticas de retención: por ejemplo, conservar datos "en crudo" (cada lectura individual) solo por 30 días, y datos agregados (promedios por hora) indefinidamente. Esto es relevante para el modelo de negocio de Denki: evita que el almacenamiento crezca sin control a medida que se conectan más sensores y pasa el tiempo, manteniendo solo el nivel de detalle histórico que realmente se necesita.

> La retención controla cuántos datos se guardan; **no sustituye** un backup. Ver Bloque 11, sección 3, para el plan de respaldo de InfluxDB (`influx backup`/`influx restore`) y la estrategia de recuperación ante desastres.

---

## Ejercicios del Bloque 09

### Ejercicio 7.1 — Diseño de rutas RESTful
Diseña las rutas HTTP (método + ruta) para un recurso `alertas` de Denki: listar todas, obtener una específica, crear una nueva, marcarla como resuelta (actualización parcial), eliminarla.

**Respuesta:**
```
GET    /api/alertas
GET    /api/alertas/:id
POST   /api/alertas
PATCH  /api/alertas/:id   (body: { resuelta: true })
DELETE /api/alertas/:id
```

### Ejercicio 7.2 — Manejo de códigos de estado
Escribe el manejo de errores de un `fetch` que distinga entre: éxito, dispositivo no encontrado (404), sin autorización (401), y cualquier otro error.

**Respuesta:**
```js
const respuesta = await fetch(`/api/dispositivos/${id}`);
if (respuesta.status === 404) {
  mensaje = "Este dispositivo no existe";
} else if (respuesta.status === 401) {
  mensaje = "Tu sesión expiró, inicia sesión de nuevo";
} else if (!respuesta.ok) {
  mensaje = "Ocurrió un error inesperado";
} else {
  const datos = await respuesta.json();
}
```

### Ejercicio 7.3 — Configurar CORS en Node-RED
Configura `httpNodeCors` en `settings.js` para que solo `https://app.denkipower.com` pueda consumir la API, y verifica (intentando desde otro origen, por ejemplo abriendo la consola del navegador desde un dominio distinto) que la petición sea efectivamente bloqueada.

### Ejercicio 7.4 — Sanitización en Vue
Identifica en el código del panel de Denki (Bloque 03) cualquier uso de `v-html`, y evalúa si el contenido insertado proviene de una fuente confiable. Si proviene de datos externos (por ejemplo, un comentario de un cliente), reemplázalo por interpolación normal `{{ }}` o por una librería de sanitización.

### Ejercicio 7.5 — Modelar tags vs fields en InfluxDB
Para una lectura que incluye: id de sensor, ubicación de la instalación, tipo de instalación (industrial/residencial/comercial), temperatura y presión — decide qué datos deberían ser `tags` y cuáles `fields`, justificando con la regla de la sección 3.2.

**Respuesta:** `tags`: `sensor_id`, `ubicacion`, `tipo_instalacion` (todos se usan para filtrar/agrupar consultas). `fields`: `temperatura`, `presion` (son los valores medidos en sí).

### Ejercicio 7.6 — Consulta Flux básica
Escribe una consulta Flux que devuelva el valor **máximo** de presión registrado en la última semana, para el sensor con id `"BMP280"`.

**Respuesta:**
```flux
from(bucket: "denki")
  |> range(start: -7d)
  |> filter(fn: (r) => r._measurement == "lecturas_temperatura")
  |> filter(fn: (r) => r.sensor_id == "BMP280")
  |> filter(fn: (r) => r._field == "presion")
  |> max()
```

### Ejercicio 7.7 — Flujo completo de ingesta a InfluxDB
Construye un flujo en Node-RED: `inject` (simulación cada 10s) → `function` (genera lectura con sensor_id, ubicación, valor) → `function` (da formato measurement/tags/fields) → `influxdb out`. Verifica en InfluxDB (vía su interfaz web) que los datos se están escribiendo correctamente.

---

## Cómo se conecta este bloque con el resto del plan

Este bloque completa el círculo de producción real para Denki: el Bloque 07 te dio el **cómo desplegar**, este bloque te da el **cómo comunicar de forma segura** (HTTP/CORS/seguridad) y el **dónde almacenar de forma escalable** (InfluxDB) en vez de archivos sueltos. Con los Bloques 1 a 7 completos, el stack de Denki deja de depender de soluciones "de práctica" (localStorage, CSV, CORS abierto a `*`) y pasa a usar las mismas piezas que usaría un producto de monitoreo IoT real en producción.
