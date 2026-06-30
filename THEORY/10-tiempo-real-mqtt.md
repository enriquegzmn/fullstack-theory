# Teoría Detallada — Bloque 10: Comunicación en Tiempo Real (WebSockets) y MQTT a Profundidad

Hasta ahora, toda comunicación HTTP (Bloque 09, Bloque 04) sigue el patrón petición/respuesta: el cliente pregunta, el servidor responde, la conexión termina. Para que el panel de Denki se actualice **solo**, sin que el usuario tenga que recargar la página cada vez que llega una nueva lectura, se necesita un modelo distinto. Este bloque cubre WebSockets (la base de la actualización en tiempo real, tanto en web general como en lo que usa internamente el Dashboard de Node-RED) y profundiza en MQTT (el protocolo estándar de IoT, mencionado superficialmente en el Bloque 08).

---

## PARTE 1 — WebSockets

### 1.1 El problema con HTTP para tiempo real

Con HTTP tradicional, si quieres que el panel "sepa" que llegó una nueva lectura, tendrías que hacer **polling**: preguntar repetidamente "¿hay algo nuevo?" cada pocos segundos.

```js
// Polling: funciona, pero es ineficiente
setInterval(async () => {
  const respuesta = await fetch('/api/ultima-lectura');
  actualizarDashboard(await respuesta.json());
}, 3000); // pregunta cada 3 segundos, sin importar si realmente hay algo nuevo
```
**Problemas del polling**: desperdicia peticiones cuando no hay nada nuevo, y si se necesita más "tiempo real" (cada 1 segundo en vez de cada 3), la cantidad de peticiones innecesarias crece rápidamente con cada cliente conectado.

### 1.2 ¿Qué es un WebSocket?

Un WebSocket es una **conexión persistente y bidireccional** entre el navegador y el servidor: una vez establecida, ambos lados pueden enviar mensajes **en cualquier momento**, sin tener que abrir una nueva conexión cada vez (a diferencia de HTTP, donde cada petición es independiente y se cierra al terminar).

```
HTTP tradicional:           WebSocket:
Cliente → pregunta            Cliente ↔ conexión abierta permanentemente ↔ Servidor
Servidor → responde            (cualquiera de los dos puede enviar un mensaje en cualquier momento)
(conexión se cierra)
Cliente → pregunta de nuevo
...
```

### 1.3 WebSockets en el navegador (API nativa)

```js
const socket = new WebSocket('wss://api.denkipower.com/tiempo-real');

socket.addEventListener('open', () => {
  console.log('Conexión establecida');
});

socket.addEventListener('message', (evento) => {
  const lectura = JSON.parse(evento.data);
  actualizarDashboard(lectura); // se ejecuta automáticamente cada vez que el servidor envía algo
});

socket.addEventListener('close', () => {
  console.log('Conexión cerrada, reintentar...');
});

socket.addEventListener('error', (error) => {
  console.error('Error de WebSocket:', error);
});
```
Nota el prefijo `wss://` (WebSocket Secure, equivalente a HTTPS) en vez de `https://`. A diferencia de `fetch`, aquí **no hay un ciclo de petición/respuesta**: simplemente escuchas el evento `message` y reaccionas cuando llegue, sin que el cliente tenga que pedir nada activamente.

### 1.4 WebSockets en un servidor Express (con la librería `ws`)

```bash
npm install ws
```
```js
import { WebSocketServer } from 'ws';

const wss = new WebSocketServer({ port: 8080 });

wss.on('connection', (socket) => {
  console.log('Cliente conectado');

  socket.on('message', (data) => {
    console.log('Mensaje recibido:', data);
  });

  // enviar una lectura nueva a TODOS los clientes conectados
  function difundirLectura(lectura) {
    wss.clients.forEach(cliente => {
      cliente.send(JSON.stringify(lectura));
    });
  }
});
```
Este patrón (`wss.clients.forEach(...)`, enviando a todos los conectados) se llama **broadcast**, y es exactamente lo que necesita Denki: cuando llega una lectura nueva de un sensor (vía Node-RED/MQTT), se difunde inmediatamente a todos los paneles de cliente que estén abiertos en ese momento, sin que cada uno tenga que estar preguntando constantemente.

### 1.5 Reconexión automática (resiliencia, conectando con el Bloque 11)

Una conexión WebSocket puede caerse (el usuario pierde WiFi momentáneamente, el servidor se reinicia). Un cliente robusto debe reintentar la conexión automáticamente:

```js
function conectar() {
  const socket = new WebSocket('wss://api.denkipower.com/tiempo-real');

  socket.addEventListener('close', () => {
    console.log('Conexión perdida, reintentando en 3s...');
    setTimeout(conectar, 3000); // reintento simple; en producción real, aplicar backoff exponencial (Bloque 11)
  });

  socket.addEventListener('message', (evento) => {
    actualizarDashboard(JSON.parse(evento.data));
  });

  return socket;
}
conectar();
```

### 1.6 WebSockets dentro de un componente Vue

```vue
<script setup>
import { ref, onMounted, onUnmounted } from 'vue';

const lecturas = ref([]);
let socket;

onMounted(() => {
  socket = new WebSocket('wss://api.denkipower.com/tiempo-real');
  socket.addEventListener('message', (evento) => {
    lecturas.value.push(JSON.parse(evento.data));
  });
});

onUnmounted(() => {
  socket?.close(); // IMPORTANTE: cerrar la conexión cuando el componente se destruye, para no dejar conexiones abiertas innecesariamente
});
</script>
```
`onUnmounted` (el equivalente en Composition API al hook `unmounted` visto en el Bloque 03) es crítico aquí: si no se cierra el socket al destruir el componente, la conexión queda "viva" innecesariamente, consumiendo recursos tanto en el navegador como en el servidor — un descuido común que con el tiempo degrada el rendimiento general del sistema.

### 1.7 Por qué el Dashboard de Node-RED ya hace esto por ti

Como se mencionó en el Bloque 08, el Dashboard de Node-RED actualiza sus widgets en tiempo real **usando WebSockets internamente**, sin que tengas que escribir este código manualmente. Entender WebSockets ahora te permite: (a) explicar en una entrevista técnica cómo funciona realmente esa "magia" del Dashboard, y (b) construir tu propio canal de tiempo real cuando el panel Vue personalizado (Bloque 03/9) necesite actualizarse en vivo, más allá de lo que el Dashboard predefinido de Node-RED ofrece.

---

## PARTE 2 — MQTT a profundidad

### 2.1 Repaso: ¿por qué MQTT y no HTTP para sensores?

HTTP fue diseñado para la web (peticiones relativamente pesadas, ocasionales). MQTT fue diseñado específicamente para **IoT**: dispositivos con poca batería/ancho de banda, que necesitan enviar mensajes pequeños y frecuentes de forma eficiente. Un sensor con batería limitada "gasta" mucho menos energía manteniendo una conexión MQTT persistente y enviando mensajes cortos, que abriendo una conexión HTTP completa cada vez.

### 2.2 El patrón Publish/Subscribe

```
[Sensor BMP280] --publica--> [Topic: denki/planta1/temperatura] --notifica--> [Suscriptor 1: Node-RED]
                                                                  --notifica--> [Suscriptor 2: otro sistema]
```
A diferencia de HTTP (donde el cliente pide algo a un destino específico conocido), en MQTT los dispositivos **publican** mensajes a un "topic" (canal con nombre), sin saber ni importarles quién los va a recibir. Cualquier cantidad de **suscriptores** interesados en ese topic los reciben automáticamente. Esto desacopla completamente a los sensores de quién consume sus datos — se puede agregar un nuevo sistema suscrito sin tocar el código del sensor.

### 2.3 El Broker MQTT

Todo esto requiere un **broker** (servidor intermediario) que reciba las publicaciones y las distribuya a los suscriptores correctos. Brokers comunes: Mosquitto (ligero, open source, ideal para correr en la misma Raspberry Pi/EDATEC), HiveMQ, o brokers en la nube (AWS IoT Core, etc.).

```bash
# instalar Mosquitto en la Raspberry Pi/EDATEC
sudo apt install mosquitto mosquitto-clients
sudo systemctl enable mosquitto # arranca automáticamente al iniciar el dispositivo
```

### 2.4 Estructura de topics (jerarquía con `/`)

```
denki/planta1/sensor-bmp280/temperatura
denki/planta1/sensor-bmp280/presion
denki/planta2/sensor-dht22/humedad
```
Una buena convención de topics usa una jerarquía lógica: `empresa/ubicación/dispositivo/medición`. Esto permite suscribirse de forma granular o amplia usando **wildcards**:
```
denki/planta1/+/temperatura    → "+" sustituye exactamente UN nivel (cualquier sensor de planta1, solo temperatura)
denki/planta1/#                  → "#" sustituye CUALQUIER cantidad de niveles restantes (todo lo que pase por planta1)
```

### 2.5 QoS (Quality of Service): qué tan garantizada es la entrega

MQTT define 3 niveles de garantía de entrega de cada mensaje:

- **QoS 0** ("at most once"): el mensaje se envía una vez, sin confirmación. Puede perderse si hay un problema de red. Más rápido, menor overhead — aceptable para datos donde perder una lectura ocasional no es crítico (ej. una lectura más, cuando llegan cada segundo).
- **QoS 1** ("at least once"): el receptor confirma la recepción; si la confirmación se pierde, el emisor reenvía — el mensaje puede llegar **duplicado**, pero no se pierde. Apropiado cuando perder un dato importa más que recibirlo duplicado (el código que lo procesa debe ser capaz de manejar duplicados sin romperse, ej. usando el `id`/timestamp para detectar y descartar duplicados).
- **QoS 2** ("exactly once"): garantiza que el mensaje llega **exactamente una vez**, ni se pierde ni se duplica — el más confiable, pero con mayor overhead de comunicación. Apropiado para comandos críticos (ej. "apagar el sistema de emergencia"), donde tanto perder el mensaje como ejecutarlo dos veces sería problemático.

**Recomendación práctica para Denki**: lecturas rutinarias de sensores → QoS 0 o 1 (priorizando eficiencia); alertas críticas y comandos de control → QoS 1 o 2 (priorizando garantía de entrega).

### 2.6 Mensajes retenidos (retained messages)

```js
// al publicar con la opción "retain"
cliente.publish('denki/planta1/sensor-bmp280/temperatura', '24.3', { retain: true });
```
Un mensaje retenido queda "guardado" en el broker como el **último valor conocido** de ese topic. Cuando un nuevo suscriptor se conecta (por ejemplo, alguien abre el panel de Denki por primera vez en el día), recibe **inmediatamente** el último valor retenido, sin tener que esperar a que llegue una lectura nueva — soluciona el problema de "abro el dashboard y está vacío hasta que llegue el próximo dato".

### 2.7 Last Will and Testament (LWT): detectar desconexiones

```js
cliente.connect({
  will: {
    topic: 'denki/planta1/sensor-bmp280/estado',
    payload: 'desconectado',
    qos: 1,
    retain: true
  }
});
```
El broker MQTT detecta cuándo un dispositivo se desconecta de forma anormal (sin avisar, por ejemplo por pérdida de energía), y publica automáticamente este mensaje "de último deseo" en su nombre. Esto resuelve, a nivel de protocolo, exactamente el problema de "sensor silencioso" descrito en el Bloque 11 — en vez de tener que inferir la desconexión por ausencia de datos durante varios minutos, el broker lo notifica de forma inmediata y explícita.

### 2.8 Conectar MQTT con Node-RED e InfluxDB (cerrando el flujo completo)

```
[mqtt in: denki/+/+/+] → [function: parsear topic y payload] → [function: dar formato measurement/tags/fields] → [influxdb out]
                                                                → [websocket out: difundir a paneles conectados]
```
Este es el flujo completo de Denki integrando todo lo aprendido: el sensor publica vía MQTT (eficiente para el dispositivo), Node-RED se suscribe y procesa el mensaje, lo persiste en InfluxDB (Bloque 09) para histórico, y simultáneamente lo difunde por WebSocket a cualquier panel Vue (Bloque 03/9) que esté abierto en ese momento — logrando que el dashboard se actualice en tiempo real sin polling, exactamente el objetivo de este bloque.

---

## Ejercicios del Bloque 10

### Ejercicio 10.1 — WebSocket básico cliente-servidor
Crea un servidor WebSocket simple con `ws` que reciba un mensaje del cliente y lo reenvíe a todos los demás clientes conectados (broadcast), y un cliente HTML simple que envíe y reciba mensajes.

### Ejercicio 10.2 — Reconexión automática
Implementa la lógica de reconexión automática de la sección 1.5 en un cliente WebSocket, y pruébala cerrando manualmente el servidor mientras el cliente está conectado, verificando que se reconecte solo cuando el servidor vuelve a estar disponible.

### Ejercicio 10.3 — Integración WebSocket + Vue
Integra un WebSocket dentro de un componente Vue (sección 1.6) que muestre en tiempo real las últimas 10 lecturas recibidas, usando `onMounted`/`onUnmounted` correctamente.

### Ejercicio 10.4 — Diseño de topics MQTT
Diseña la jerarquía de topics MQTT para Denki considerando: múltiples plantas/ubicaciones, múltiples sensores por planta, y múltiples tipos de medición por sensor. Escribe 3 ejemplos de suscripción usando wildcards (`+` y `#`) para distintos niveles de granularidad.

### Ejercicio 10.5 — QoS aplicado
Para cada uno de estos casos, decide y justifica qué QoS usarías: (a) lectura rutinaria de temperatura cada 5 segundos, (b) alerta de temperatura crítica, (c) comando para apagar remotamente un dispositivo.

**Respuesta esperada:** (a) QoS 0 — perder una lectura ocasional no es grave dado la frecuencia. (b) QoS 1 — no se puede perder, duplicados son tolerables (la alerta simplemente se procesa dos veces, sin daño real). (c) QoS 2 — ni perder el comando ni ejecutarlo dos veces es aceptable en un comando de control crítico.

### Ejercicio 10.6 — Mensaje retenido y LWT
Configura un mensaje retenido para el estado de un sensor simulado, y un Last Will and Testament que publique "desconectado" si el sensor se cae abruptamente. Verifica ambos comportamientos simulando una desconexión abrupta (cerrando el proceso sin enviar un mensaje de despedida explícito).

### Ejercicio 10.7 — Flujo completo end-to-end
Construye el flujo completo de la sección 2.8 en Node-RED: sensor simulado → MQTT → procesamiento → InfluxDB + WebSocket, y conecta el panel Vue del Bloque 04 para que se actualice en tiempo real sin recargar la página ni hacer polling.

---

## Cómo se conecta este bloque con el resto del plan

Con este bloque, el sistema de Denki deja de depender de que el usuario recargue manualmente el panel o de hacer polling ineficiente: las lecturas viajan de forma eficiente desde el sensor (MQTT), se persisten para histórico (InfluxDB, Bloque 09), se resguardan ante fallos (Bloque 11), y se reflejan instantáneamente en cualquier panel abierto (WebSockets) — completando, de punta a punta, el flujo de datos en tiempo real que es, en esencia, la propuesta de valor central de un producto de monitoreo IoT.
