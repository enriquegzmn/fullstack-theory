# Teoría Detallada — Bloque 08: Node-RED / IoT (Semana 12 en el plan Denki)

## 1. ¿Qué es Node-RED y por qué es distinto a programar normalmente?

Node-RED es una herramienta de **programación visual basada en flujos** (flow-based programming), construida sobre Node.js. En vez de escribir todo el código línea por línea como en JavaScript puro, se conectan "nodos" visuales mediante cables en un lienzo (canvas), donde cada nodo realiza una tarea específica (recibir un dato, transformarlo, enviarlo a algún lado) y los cables representan el flujo de información entre ellos.

Es muy usado en proyectos de **IoT (Internet de las Cosas)**, automatización industrial y domótica, porque facilita conectar hardware (sensores, microcontroladores), protocolos de comunicación (MQTT, HTTP, Serial) y visualización de datos (dashboards), sin tener que programar cada integración desde cero.

**Analogía**: si JavaScript es como escribir una receta de cocina paso a paso en texto, Node-RED es como un diagrama de flujo donde cada caja es un paso y las flechas indican el orden — mismo resultado final, pero la representación visual hace más fácil entender de un vistazo cómo viaja la información por el sistema completo.

## 2. Instalación y arquitectura

```bash
npm install -g node-red
node-red
```
También puede instalarse vía Docker, o configurarse como servicio persistente en una Raspberry Pi o en el EDATEC ED-IPC1200.

Internamente, Node-RED corre un servidor Node.js con Express; el "editor" que ves en el navegador (normalmente en `http://localhost:1880`) es en sí mismo **una aplicación web** (con su propio HTML/CSS/JS), que se comunica con el servidor para desplegar y ejecutar los flujos que diseñas.

## 3. La interfaz del editor

- **Paleta de nodos** (izquierda): catálogo de todos los nodos disponibles, organizados por categoría (entrada, salida, función, redes, etc.).
- **Lienzo / Canvas** (centro): donde se arrastran y conectan los nodos para construir un flujo.
- **Panel de información/ayuda** (derecha): muestra documentación del nodo seleccionado.
- **Panel de depuración (debug)** (derecha, pestaña inferior): muestra los mensajes que pasan por los nodos `debug` que hayas colocado, equivalente a `console.log()` en JavaScript.

## 4. Conceptos fundamentales: nodo, flujo, mensaje

- **Nodo**: una unidad de procesamiento con una función específica (recibir datos, transformarlos, enviarlos a algún destino).
- **Flujo (flow)**: un conjunto de nodos conectados, organizado en una pestaña (tab) del editor.
- **Cable (wire)**: la conexión visual entre la salida de un nodo y la entrada de otro, representando que el mensaje viaja de uno a otro.
- **`msg` (mensaje)**: el objeto JavaScript que viaja entre nodos a través de los cables. Es el equivalente al "dato" que se va transformando en cada paso del flujo.

```js
// estructura típica de un mensaje
{
  payload: 23.5,        // el dato principal, prácticamente todos los nodos lo usan
  topic: "temperatura",  // metadato opcional, útil para identificar el origen del dato
  _msgid: "abc123"        // identificador interno generado por Node-RED
}
```
**`msg.payload`** es, por convención, donde va el dato principal que un nodo procesa o produce. La mayoría de los nodos, si no se les configura algo distinto, leen y escriben en `msg.payload`.

## 5. Nodos básicos para empezar

```
[inject] → [debug]
```
- **`inject`**: genera un mensaje manualmente (con un clic) o automáticamente (cada cierto intervalo de tiempo). Es el "punto de partida" típico de un flujo de prueba.
- **`debug`**: muestra el contenido del mensaje que recibe en el panel de depuración. Equivalente visual a `console.log(msg.payload)`.
- **`function`**: permite escribir **JavaScript real** para transformar el mensaje (se profundiza en la siguiente sección).

## 6. El nodo Function: JavaScript real dentro de Node-RED

Este es el nodo más importante para alguien que ya sabe JavaScript, porque conecta directamente todo lo aprendido en el Bloque 02.

```js
// dentro de un nodo function
const temperatura = msg.payload;

let estado;
if (temperatura > 30) {
  estado = "caliente";
} else if (temperatura < 10) {
  estado = "frío";
} else {
  estado = "normal";
}

msg.payload = {
  valor: temperatura,
  unidad: "°C",
  estado: estado
};

return msg; // IMPRESCINDIBLE: si no se retorna msg (o null), el flujo se detiene
```

**Reglas clave del nodo function:**
- Debe terminar con `return msg;` para que el mensaje continúe hacia el siguiente nodo conectado. Si se hace `return null;`, el flujo se detiene intencionalmente ahí (útil para filtrar mensajes que no deben continuar).
- Se puede usar **todo JavaScript estándar**: variables, condicionales, bucles, arrays, objetos, funciones, exactamente como en el Bloque 02.
- Para mostrar mensajes de depuración específicos del nodo (más allá del panel `debug`), se usan `node.warn(mensaje)`, `node.error(mensaje)`, `node.log(mensaje)`.

### Múltiples salidas
Un nodo `function` puede configurarse con más de una salida, permitiendo enrutar mensajes distintos a destinos distintos:
```js
if (msg.payload.estado === "caliente") {
  return [msg, null]; // envía por la salida 1, nada por la salida 2
} else {
  return [null, msg]; // envía por la salida 2
}
```

### Contexto: variables que persisten entre ejecuciones
A diferencia de una función JavaScript normal (que "olvida" todo al terminar), Node-RED ofrece tres niveles de "contexto" para guardar datos entre distintas ejecuciones del flujo:
```js
// Contexto de NODO: solo visible para este nodo específico
let contador = context.get('contador') || 0;
contador++;
context.set('contador', contador);

// Contexto de FLUJO: visible para todos los nodos de la misma pestaña
flow.set('ultimaLectura', msg.payload);

// Contexto GLOBAL: visible para TODOS los flujos de la instancia de Node-RED
global.set('configuracion', { umbral: 30 });
```
Esto es conceptualmente equivalente a los distintos "scopes" de variables vistos en JavaScript (Bloque 02), pero aplicado a través de todo el sistema de flujos, no solo dentro de una función.

## 7. Nodos de control de flujo y manipulación de mensajes

- **`switch`**: enruta el mensaje hacia distintas salidas según condiciones sobre `msg.payload` (equivalente visual a un `if/else`/`switch` de JavaScript).
- **`change`**: permite establecer, modificar, eliminar o mover propiedades del mensaje sin necesidad de escribir código (equivalente visual a manipular un objeto JS con `msg.algo = valor`).
- **`template`**: genera texto, HTML o JSON dinámico usando sintaxis Mustache (`{{payload}}`), similar conceptualmente a los template literals de JavaScript.
- **`split`/`join`**: `split` divide un array (o un objeto) en mensajes individuales, uno por cada elemento — similar a recorrer un array con `for...of`. `join` hace lo inverso: junta varios mensajes en un solo array u objeto — similar a construir un array con `push` en un bucle.
- **`delay`**: retrasa el paso de un mensaje, o limita la tasa de mensajes por segundo (rate limiting).
- **`json`**: convierte entre un string JSON y un objeto JavaScript (equivalente visual a `JSON.parse`/`JSON.stringify`).

## 8. Comunicación con hardware y protocolos

Estos nodos son los que hacen a Node-RED especialmente relevante para proyectos de hardware como los de Denki:

- **`mqtt in` / `mqtt out`**: MQTT es un protocolo de mensajería ligero, muy usado en IoT, basado en el patrón "publicar/suscribir" (publish/subscribe). Un dispositivo "publica" datos en un "tema" (topic, como un canal), y otros dispositivos "suscritos" a ese mismo tema reciben los datos automáticamente. Requiere un "broker" (servidor intermediario) MQTT.

> Esta es la introducción mínima. El diseño de topics, niveles de QoS, mensajes retenidos y Last Will and Testament (detección de desconexión a nivel de protocolo) se desarrollan a fondo en el **Bloque 10 — Comunicación en Tiempo Real (WebSockets) y MQTT a Profundidad**.
- **`serial in` / `serial out`**: lectura y escritura por puerto serie (UART), el protocolo de comunicación más básico y común entre microcontroladores y computadoras (Arduino, sensores conectados por cable serial).
- **`http request`**: hace peticiones HTTP salientes desde el flujo — el equivalente visual de `fetch()` en JavaScript. Permite que Node-RED consuma APIs externas.
- **`http in` / `http response`**: permiten crear **endpoints HTTP propios** dentro de Node-RED, convirtiéndolo en un mini-servidor/API. Por ejemplo, se puede crear una ruta `/api/temperatura` que devuelva la última lectura en formato JSON.
- **`rpi-gpio in` / `rpi-gpio out`**: nodos específicos para leer/escribir directamente en los pines GPIO de una Raspberry Pi, permitiendo conectar sensores físicos como el BMP280 sin necesidad de escribir un script Python aparte.

## 9. Almacenamiento de datos de sensores

- **`file` / `file in`**: leer y escribir archivos locales (CSV, JSON, logs de texto plano).
- Conexión a bases de datos mediante paquetes adicionales (contrib nodes): MySQL, PostgreSQL, SQLite, o especialmente **InfluxDB**, una base de datos optimizada para "series temporales" (datos con marca de tiempo, como lecturas periódicas de sensores), muy usada en proyectos de monitoreo industrial.

**Patrón típico de almacenamiento de una lectura de sensor**:
```js
msg.payload = {
  timestamp: new Date().toISOString(),
  sensor: "BMP280",
  temperatura: 24.3,
  presion: 1013.2
};
return msg;
```
Cada lectura se guarda con su marca de tiempo, el identificador del sensor de origen, y los valores medidos — un esquema simple pero suficiente para reconstruir históricos y graficarlos después.

## 10. Node-RED Dashboard: interfaz visual declarativa

El paquete `node-red-dashboard` (o su sucesor moderno `@flowfuse/node-red-dashboard`, basado en Vue 3/Vuetify) permite construir interfaces visuales sin escribir HTML/CSS manualmente, usando nodos especiales.

**Jerarquía del Dashboard**, conceptualmente similar a la estructura HTML que ya conoces:
```
Tab (pestaña del dashboard, equivalente a una "página")
  └── Group (grupo, equivalente a una <section> o <div> contenedor)
        └── Widget (gauge, chart, button, switch, slider — equivalente a un componente visual individual)
```

Configuración de layout: cada grupo tiene un ancho definido en una cuadrícula de **6 columnas** (similar conceptualmente a `grid-template-columns: repeat(6, 1fr)` en CSS Grid), y cada widget ocupa cierto número de esas columnas.

**Widgets más usados:**
- `text`: muestra un valor simple (equivalente a `{{ valor }}` en Vue).
- `gauge`: medidor visual tipo velocímetro, ideal para mostrar un valor dentro de un rango (temperatura, porcentaje de batería).
- `chart`: gráfica de línea/barra que acumula histórico de valores recibidos.
- `button`: dispara un mensaje al hacer clic (equivalente a `@click` en Vue).
- `switch`: interruptor on/off, envía `true`/`false` como `msg.payload`.
- `slider`: selector dentro de un rango, similar a `<input type="range">`.

**Actualización en tiempo real**: cuando un mensaje llega a un widget conectado, el widget se actualiza automáticamente en todos los navegadores que tengan el dashboard abierto en ese momento, sin necesidad de recargar la página — un comportamiento conceptualmente similar a la reactividad de Vue, pero a través de una conexión en tiempo real (WebSockets) entre el servidor Node-RED y los navegadores conectados.

## 11. El nodo ui_template: control total con HTML, CSS y JS

Cuando los widgets predefinidos del Dashboard no son suficientes, el nodo `ui_template` permite escribir **HTML, CSS y JavaScript directamente**, aplicando todo lo aprendido en los Bloques 1, 2 y 3 dentro de Node-RED.

```html
<div class="tarjeta-sensor" :class="estado">
  <h3>{{ msg.payload.sensor }}</h3>
  <p class="valor">{{ msg.payload.temperatura }}°C</p>
</div>

<style>
.tarjeta-sensor {
  padding: 16px;
  border-radius: 8px;
  background: #f5f5f5;
  transition: background-color 0.3s;
}
.tarjeta-sensor.alerta {
  background: #ffebee;
}
.valor {
  font-size: 24px;
  font-weight: bold;
  color: #B8720A;
}
</style>

<script>
(function(scope) {
  scope.estado = "normal";
  scope.$watch('msg', function (msg) {
    if (msg && msg.payload) {
      scope.estado = msg.payload.temperatura > 30 ? "alerta" : "normal";
    }
  });
})(scope);
</script>
```

**Conceptos clave de este nodo:**
- `msg`/`msg.payload` están disponibles directamente en el template, igual que cualquier dato reactivo.
- `scope.$watch('msg', callback)` (en la versión clásica basada en AngularJS) reacciona cada vez que llega un nuevo mensaje al nodo, de forma conceptualmente equivalente a un `watch` de Vue.
- `scope.send(msg)` permite enviar un mensaje **de vuelta hacia el flujo** desde el template — por ejemplo, cuando el usuario presiona un botón personalizado dentro del widget. Esto es el equivalente directo a `$emit` en componentes Vue: el "hijo" (el widget visual) le comunica algo al "padre" (el flujo de Node-RED).

## 12. Vue.js dentro de Node-RED (Dashboard 2.0)

La versión moderna del Dashboard (`@flowfuse/node-red-dashboard`) está construida internamente con **Vue 3 y Vuetify**, lo que significa que los conceptos de reactividad, `data`, `computed` y `v-for` que aprendiste en el Bloque 03 aplican de forma mucho más directa al personalizar templates dentro de esta versión, e incluso es posible cargar Vue explícitamente vía CDN dentro de un `ui_template` clásico para construir widgets más complejos (listas filtradas, formularios reactivos) reutilizando exactamente la misma sintaxis ya aprendida.

## 13. Subflows: el equivalente a "componentes" en Node-RED

Así como en Vue conviene dividir la interfaz en componentes reutilizables, en Node-RED conviene encapsular un conjunto de nodos que se repiten (por ejemplo, "procesar lectura de un sensor") en un **subflow**: un flujo reutilizable que se comporta como un solo nodo personalizado, con sus propias entradas/salidas y propiedades configurables — conceptualmente equivalente a un componente Vue con sus `props`.

## 14. Manejo de errores

- **`catch`**: captura errores que ocurren en cualquier nodo de la misma pestaña (o en un nodo específico si se configura), permitiendo reaccionar (reintentar, notificar, registrar el error) en vez de que el flujo simplemente falle en silencio.
- **`status`**: monitorea el estado de conexión de otros nodos (por ejemplo, si la conexión MQTT se cae), permitiendo construir lógica de reconexión o alertas de "sensor desconectado".

> Este manejo de errores es el nivel básico. Para un producto real que debe tolerar fallos de hardware/conectividad de forma sostenida (reintentos con backoff, colas de mensajes para no perder lecturas, detección de sensores "silenciosos", health checks) ver el **Bloque 11 — Resiliencia, Observabilidad y Escalabilidad**, que extiende directamente estos mismos nodos `catch`/`status`.

---

## Imágenes de referencia para el proyecto de este bloque

**Proyecto #6 — Panel de Monitoreo IoT**: dashboard con medidores tipo gauge para mostrar valores actuales (temperatura, humedad), gráficas de línea con el histórico de lecturas, tarjetas de estado por sensor con código de color (normal/alerta), y una vista general del estado del sistema completo.

(Ver las imágenes de referencia de "IoT sensor dashboard" y "Node-RED dashboard gauge chart" mostradas en la conversación para ejemplos visuales reales de paneles de monitoreo industrial.)

---

## Ejercicios consolidados del Bloque 08 (con respuesta/guía de solución)

### Ejercicio 4.1 — Nodo Function con clasificación de estado
Crea un nodo `function` que reciba `msg.payload` como un número de temperatura y devuelva un objeto `{ valor, estado }`, donde `estado` sea `"normal"`, `"advertencia"` o `"critico"` según rangos definidos (reutiliza el mismo union type del Bloque 06 para mantener consistencia entre frontend y backend).

**Respuesta (código del nodo function):**
```js
const temperatura = msg.payload;
let estado;

if (temperatura > 80) {
  estado = "critico";
} else if (temperatura > 50) {
  estado = "advertencia";
} else {
  estado = "normal";
}

msg.payload = { valor: temperatura, estado: estado, timestamp: new Date().toISOString() };
return msg;
```

### Ejercicio 4.2 — Flujo con switch para enrutar alertas
Usando el resultado del Ejercicio 4.1, agrega un nodo `switch` que envíe el mensaje por una salida distinta según `msg.payload.estado`, conectando la salida "critico" a un nodo `debug` que simule una notificación.

**Guía de solución:** configurar el `switch` con la propiedad `msg.payload.estado`, agregando una regla por cada valor exacto (`== "normal"`, `== "advertencia"`, `== "critico"`), cada una conectada a una rama distinta del flujo.

### Ejercicio 4.3 — Dashboard con gauge y chart
Construye un flujo `inject` (repitiendo cada 5 segundos) → `function` (genera un valor aleatorio entre 15 y 90) → conectado simultáneamente a un nodo `gauge` y a un nodo `chart` del Dashboard.

**Guía de solución:** el mismo `msg` puede conectarse a dos nodos distintos desde una sola salida (un cable se puede "ramificar" visualmente a varios nodos); el `gauge` mostrará el valor actual, el `chart` acumulará el histórico automáticamente.

### Ejercicio 4.4 — Endpoint HTTP propio
Crea un endpoint `GET /api/ultima-lectura` que devuelva, en formato JSON, la última lectura procesada por el flujo (usando contexto de flujo para "recordar" el último valor).

**Respuesta (código del nodo function conectado antes del http response):**
```js
flow.set('ultimaLectura', msg.payload); // se guarda cada vez que llega una nueva lectura
```
```js
// en un segundo flujo, conectado a [http in: GET /api/ultima-lectura] → [function] → [http response]
msg.payload = flow.get('ultimaLectura') || { mensaje: "Sin datos aún" };
return msg;
```

### Ejercicio 4.5 — ui_template con estilo de marca Denki
Construye un `ui_template` que muestre una tarjeta de sensor usando el color ámbar `#B8720A` de la identidad de Denki, cambiando a un color de alerta (rojo) cuando `msg.payload.estado` sea `"critico"`.

**Guía de solución:** usar `:class` o un `style` dinámico dentro del `ui_template` (sección 11 de este bloque), condicionando el color de fondo/borde según `msg.payload.estado`, reutilizando exactamente la misma lógica de clases dinámicas vista en Vue (Bloque 03).

