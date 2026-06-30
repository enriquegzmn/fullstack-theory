# Teoría Detallada — Bloque 11: Resiliencia, Observabilidad y Escalabilidad

Este es el bloque que separa "MVP que funciona en una demo" de "producto que opera de forma confiable sin que tengas que vigilarlo todo el tiempo". A diferencia de los bloques anteriores, aquí muchos conceptos se entienden mejor viéndolos fallar en producción real que leyéndolos — por eso este bloque está escrito para darte el **vocabulario y los patrones base**, sabiendo que la maestría real vendrá de operar el piloto de Denki con datos reales.

---

## 1. Manejo de fallos de hardware y conectividad

### 1.1 El problema: el mundo real falla constantemente
A diferencia de un proyecto de práctica donde todo "siempre funciona", un sistema IoT real enfrenta: sensores que se desconectan, WiFi que se cae, la Raspberry Pi que pierde energía, InfluxDB que no responde momentáneamente. Un sistema **resiliente** no es uno que nunca falla — es uno diseñado asumiendo que **va a fallar**, y que se recupera o degrada de forma controlada en vez de romperse silenciosamente.

### 1.2 Reintentos con backoff exponencial

Cuando una petición falla (por ejemplo, escribir en InfluxDB falla porque la base de datos está temporalmente saturada), reintentar inmediatamente y sin límite puede empeorar el problema (sobrecargar aún más un sistema ya saturado). El patrón estándar es el **backoff exponencial**: esperar cada vez más tiempo entre reintentos.

```js
// dentro de un nodo function de Node-RED, o en JS general
async function escribirConReintentos(datos, intentoActual = 1, maxIntentos = 5) {
  try {
    await escribirEnInfluxDB(datos);
  } catch (error) {
    if (intentoActual >= maxIntentos) {
      throw new Error(`Falló después de ${maxIntentos} intentos: ${error.message}`);
    }
    const esperaMs = Math.pow(2, intentoActual) * 1000; // 2s, 4s, 8s, 16s, 32s...
    await new Promise(resolve => setTimeout(resolve, esperaMs));
    return escribirConReintentos(datos, intentoActual + 1, maxIntentos);
  }
}
```
Esto evita un patrón muy común y dañino: un fallo temporal que se convierte en una tormenta de reintentos inmediatos que termina tumbando el sistema por completo.

### 1.3 Colas de mensajes: no perder lecturas durante una caída

Si InfluxDB está caída por 10 minutos y las lecturas de sensores simplemente se descartan mientras tanto, hay un **hueco de datos permanente** en el historial del cliente — inaceptable para un producto de monitoreo. La solución es una **cola**: las lecturas se almacenan temporalmente (en memoria, en un archivo local, o en un nodo `file` de Node-RED) mientras el destino no responde, y se "drenan" hacia la base de datos en cuanto vuelve a estar disponible.

```js
// patrón conceptual dentro de Node-RED:
// [sensor] → [function: intentar escribir en InfluxDB]
//                ├── éxito → continúa normalmente
//                └── falla → [function: guardar en cola local (archivo/contexto)]
//
// [inject cada 1 min] → [function: leer cola local] → [influxdb out] → [function: vaciar cola si tuvo éxito]
```
Esto usa directamente el contexto de flujo/global visto en el Bloque 08, ahora aplicado específicamente a no perder datos durante una interrupción.

### 1.4 Nodo `catch` y `status` en profundidad (extendiendo el Bloque 08)

En el Bloque 08 se mencionó brevemente `catch` y `status`. Aplicado a resiliencia real:

```js
// nodo function conectado después de un nodo catch global
const error = msg.error;
const nodoOrigen = error.source.id;

// registrar el error con contexto suficiente para diagnosticar después
node.warn(`Error en nodo ${nodoOrigen}: ${error.message} — ${new Date().toISOString()}`);

// decidir si es recuperable automáticamente o requiere notificación humana
if (error.message.includes("ECONNREFUSED")) {
  // problema de conectividad, reintentar tiene sentido
  msg.reintentar = true;
} else {
  // error inesperado, mejor notificar a un humano
  msg.notificar = true;
}
return msg;
```
La diferencia entre un manejo de errores básico (Bloque 08) y uno resiliente es que este último **clasifica** el error (¿es temporal? ¿es recuperable automáticamente? ¿necesita intervención humana?) en vez de simplemente registrarlo.

### 1.5 Health checks (verificaciones de salud)

Un endpoint dedicado que reporta si el sistema está funcionando correctamente, separado de la lógica de negocio:

```js
// http in: GET /api/health → function → http response
msg.payload = {
  estado: "ok",
  influxdb: await verificarConexionInfluxDB(),
  ultimaLectura: flow.get('ultimaLectura') ? "reciente" : "sin datos",
  timestamp: new Date().toISOString()
};
return msg;
```
Este endpoint permite que herramientas externas (o incluso un simple `cron` que haga `ping` cada 5 minutos) detecten si el sistema dejó de funcionar, sin depender de que un humano note manualmente que el dashboard "se ve raro".

---

## 2. Observabilidad: saber qué está pasando sin tener que adivinar

### 2.1 Logging estructurado

Un `console.log("error")` suelto es insuficiente para diagnosticar problemas en producción. El **logging estructurado** registra eventos con un formato consistente y datos contextuales:

```js
function log(nivel, mensaje, contexto = {}) {
  console.log(JSON.stringify({
    nivel,            // "info" | "warn" | "error"
    mensaje,
    contexto,          // datos adicionales: sensorId, clienteId, etc.
    timestamp: new Date().toISOString()
  }));
}

log("error", "Fallo al escribir en InfluxDB", { sensorId: "BMP280", intento: 3 });
```
Al ser JSON estructurado (no texto libre), estos logs se pueden filtrar, buscar y analizar después con herramientas de búsqueda (incluso `grep` sobre un archivo, o un servicio dedicado más adelante), respondiendo preguntas como "¿cuántos errores tuvo el sensor X esta semana?" sin tener que leer manualmente miles de líneas de texto.

### 2.2 Niveles de log y cuándo usar cada uno

- **`info`**: eventos normales del sistema (un dispositivo se conectó, una lectura se procesó correctamente). Útil para entender el flujo normal, no indica problema.
- **`warn`**: algo inusual pero no crítico (un reintento, una lectura fuera de rango esperado pero no necesariamente errónea).
- **`error`**: algo falló y requiere atención (no se pudo escribir en la base de datos, una petición a la API falló).

### 2.3 Métricas básicas a monitorear en un sistema de monitoreo (sí, monitorear el monitor)

- **Uptime**: porcentaje de tiempo que el sistema estuvo disponible y respondiendo correctamente.
- **Latencia**: cuánto tarda una lectura en pasar de sensor → procesamiento → almacenamiento → dashboard.
- **Tasa de error**: porcentaje de peticiones/escrituras que fallan respecto al total.
- **Frescura de datos** (data freshness): hace cuánto tiempo llegó la última lectura de cada sensor — crítico para detectar un sensor "silenciosamente desconectado" (no manda error, simplemente deja de mandar datos).

```js
// detección de "silencio" de un sensor, dentro de un flujo periódico
const ultimaLectura = flow.get(`ultimaLectura_${sensorId}`);
const minutosSinDatos = (Date.now() - new Date(ultimaLectura).getTime()) / 60000;

if (minutosSinDatos > 15) {
  msg.payload = { alerta: "sensor_silencioso", sensorId, minutosSinDatos };
  return msg; // dispara una notificación
}
```
Esta es una de las fallas más comunes y más fáciles de pasar por alto en sistemas de monitoreo: un sensor que se desconecta no genera un "error" explícito, simplemente deja de reportar — si nadie revisa activamente la frescura de los datos, el cliente puede pensar que "todo está normal" durante horas cuando en realidad el sistema dejó de recibir información.

### 2.4 Alertas sobre el sistema mismo (no solo sobre los sensores)

Hasta ahora, las alertas del Bloque 08/7 eran sobre los **datos** (temperatura fuera de rango). Un sistema observable también necesita alertas sobre la **infraestructura**: Node-RED se reinició inesperadamente, InfluxDB lleva 5 minutos sin responder, el disco de la Raspberry Pi está por llenarse. Estas alertas son las que evitan el peor escenario para un producto de monitoreo: que el sistema que se supone debe avisar de problemas, falle en silencio.

---

## 3. Backups y recuperación ante desastres

### 3.1 ¿Qué se debe respaldar?

- **Datos de InfluxDB**: el historial de lecturas es el activo más valioso del producto — perderlo significa perder el valor entregado a cada cliente.
- **Flujos de Node-RED**: el archivo de configuración (`flows.json`) que contiene toda la lógica construida.
- **Configuración del sistema**: variables de entorno, certificados, credenciales (de forma segura, no en texto plano).

### 3.2 Backup de InfluxDB

```bash
# backup completo de un bucket
influx backup /ruta/de/respaldo --bucket denki

# restaurar desde un backup
influx restore /ruta/de/respaldo
```
**Regla práctica**: un backup que nunca se ha probado a restaurar **no es un backup confiable**, es una suposición. Es recomendable, al menos una vez, ejecutar conscientemente el proceso de restauración completo (en un entorno de prueba, no en producción) para confirmar que realmente funciona antes de necesitarlo en una emergencia real.

### 3.3 Backup de flujos de Node-RED

El archivo `flows.json` (y `flows_cred.json` para credenciales) puede respaldarse simplemente versionándolo en Git (como cualquier otro código, conectando con el Bloque 07), o exportándolo periódicamente. La ventaja de tenerlo en Git: si un cambio reciente rompe el sistema, se puede volver a una versión anterior funcional en minutos.

### 3.4 Estrategia de respaldo (regla 3-2-1, simplificada)

Una guía clásica y suficiente para un producto en etapa de piloto: mantener **al menos 2 copias** de los datos críticos (la copia "viva" en producción + al menos un respaldo), y que **al menos 1 de esas copias esté en una ubicación distinta** (no en la misma tarjeta SD de la Raspberry Pi que podría corromperse físicamente) — por ejemplo, un respaldo automático diario de InfluxDB subido a un almacenamiento en la nube.

### 3.5 ¿Qué pasa si el hardware físico falla?

Si la Raspberry Pi o el EDATEC fallan físicamente (no solo se desconectan, sino que el dispositivo deja de funcionar), se necesita un plan documentado: tener la imagen del sistema operativo configurado respaldada, los flujos de Node-RED en Git, las variables de entorno documentadas de forma segura (en un gestor de secretos, no en una nota de texto), de modo que un dispositivo de reemplazo pueda ponerse en marcha en horas, no días.

---

## 4. Migraciones y versionado de esquema

### 4.1 El problema

Cuando agregas un campo nuevo a la interfaz `Dispositivo` en TypeScript (Bloque 06) o cambias la estructura de tags/fields en InfluxDB (Bloque 09), los datos **ya existentes** no se actualizan automáticamente. Si el frontend espera un campo que los datos viejos no tienen, se puede romper la interfaz para datos históricos.

### 4.2 Cambios compatibles hacia atrás (backward-compatible)

```ts
interface Dispositivo {
  id: string;
  nombre: string;
  ubicacion?: string; // agregar como OPCIONAL es seguro: los registros viejos sin este campo siguen siendo válidos
}
```
Agregar un campo nuevo como **opcional** (`?`) es la forma más segura de evolucionar el modelo de datos sin romper nada existente. Hacerlo obligatorio desde el día uno obliga a migrar todos los datos históricos antes de poder desplegar el cambio.

### 4.3 Manejar datos con forma antigua en el frontend

```ts
function normalizarDispositivo(datoCrudo: any): Dispositivo {
  return {
    id: datoCrudo.id,
    nombre: datoCrudo.nombre,
    ubicacion: datoCrudo.ubicacion ?? "Sin especificar" // valor por defecto si el dato viejo no lo tiene
  };
}
```
Esta función "normaliza" cualquier dato que llegue (sin importar si viene de un registro antiguo o nuevo) a una forma consistente, evitando que el componente Vue tenga que lidiar con la inconsistencia directamente en el template.

### 4.4 Versionado de la API

Cuando un cambio en la API **sí** rompe compatibilidad (no se puede evitar), la práctica estándar es versionar la ruta (`/api/v1/dispositivos` vs `/api/v2/dispositivos`), permitiendo que clientes que aún no se actualizaron sigan funcionando con la versión anterior mientras se migra gradualmente.

---

## 5. Multi-tenancy: aislar datos entre clientes de forma robusta

### 5.1 El riesgo de un enfoque ingenuo

Filtrar datos por `clienteId` únicamente en el frontend (Vue) es **inseguro**: cualquiera con conocimientos básicos puede inspeccionar las peticiones de red y, si la API no valida también del lado del servidor, pedir directamente los datos de otro cliente cambiando un id en la URL.

```
GET /api/dispositivos?clienteId=5   ← si la API no verifica que el usuario autenticado realmente pertenece al cliente 5,
                                        cualquiera podría cambiar el "5" por cualquier otro número
```

### 5.2 Aislamiento correcto: validar en el servidor, no confiar en el cliente

```js
// dentro del nodo function que atiende la petición en Node-RED
const clienteIdDelToken = obtenerClienteIdDesdeToken(msg.req.headers.authorization); // extraído de forma segura del JWT, NUNCA del query param
const dispositivosDelCliente = obtenerDispositivos(clienteIdDelToken); // se ignora cualquier "clienteId" que venga en la URL

msg.payload = dispositivosDelCliente;
return msg;
```
La regla de oro: **el servidor decide a qué datos tiene acceso un usuario, basándose en su identidad verificada (el token), nunca en un parámetro que el propio cliente envía** y que podría manipular.

### 5.3 Aislamiento a nivel de base de datos (InfluxDB)

Una estrategia común para varios clientes en InfluxDB es usar un **tag** `cliente_id` en cada punto de datos (conectando con el Bloque 09), y que toda consulta Flux incluya obligatoriamente ese filtro, generado del lado del servidor a partir del usuario autenticado, nunca aceptado como parámetro libre desde el frontend.

---

## 6. Escalabilidad: qué pasa al crecer

### 6.1 Límites de un único proceso de Node-RED

Node-RED corre, por defecto, en un **solo proceso de Node.js** — eso significa que, aunque maneja bastante bien decenas o incluso cientos de mensajes por segundo para casos de uso típicos de IoT, hay un punto donde un solo dispositivo/proceso deja de ser suficiente (muchos clientes, muchos sensores, alta frecuencia de lecturas).

### 6.2 Señales de que se necesita escalar

- Latencia creciente entre que llega una lectura y que se refleja en el dashboard.
- El proceso de Node-RED usando consistentemente un alto porcentaje de CPU/memoria del dispositivo.
- Mensajes perdidos o retrasados durante picos de actividad.

### 6.3 Estrategias de escalamiento (conceptos, no implementación completa en este nivel)

- **Vertical**: usar hardware más potente (más RAM/CPU) para el mismo proceso — la solución más simple, con límite eventual.
- **Horizontal**: separar responsabilidades en varios procesos/dispositivos — por ejemplo, un Node-RED por sitio/cliente en vez de uno centralizado manejando todo, o separar la ingesta de datos del procesamiento de alertas en flujos/instancias distintas.
- **Mover el almacenamiento pesado fuera del dispositivo de borde**: en vez de que la Raspberry Pi en sitio del cliente también cargue con consultas analíticas pesadas, esas consultas se mueven a una instancia de InfluxDB centralizada en la nube, dejando que el dispositivo local solo se encargue de capturar y enviar datos.

### 6.4 Costos de operación al escalar

A medida que crece el número de clientes/sensores, crecen también los costos de hosting, almacenamiento en InfluxDB (especialmente si se usa InfluxDB Cloud en vez de auto-hospedado), y ancho de banda. Es razonable, desde etapas tempranas, llevar un registro simple de estos costos por cliente, para asegurar que el modelo de precio definido en la validación de negocio (parte del plan general de Denki) siga siendo rentable a medida que el número de dispositivos monitoreados crece.

---

## Ejercicios del Bloque 11

### Ejercicio 8.1 — Reintentos con backoff
Implementa una función de reintentos con backoff exponencial para una petición `fetch` que falla intermitentemente (simúlalo con `Math.random()`), con un máximo de 4 intentos.

### Ejercicio 8.2 — Detección de sensor silencioso
Extiende el flujo de Node-RED del Bloque 09 para que, si un sensor no reporta datos en más de 15 minutos, se genere una alerta distinta a las alertas de valores fuera de rango (un nuevo tipo: `"sensor_silencioso"`).

### Ejercicio 8.3 — Endpoint de health check
Crea el endpoint `/api/health` descrito en la sección 1.5, que reporte el estado de conexión a InfluxDB y la frescura de la última lectura recibida.

### Ejercicio 8.4 — Logging estructurado
Reemplaza los `console.log` sueltos del proyecto e-commerce/panel de Denki (Bloques 2-3) por la función de logging estructurado de la sección 2.1, y agrega contexto relevante a cada log (qué componente, qué acción, qué dato).

### Ejercicio 8.5 — Migración compatible hacia atrás
Agrega un campo nuevo `ubicacion` a la interfaz `Dispositivo` (Bloque 06) como opcional, y escribe la función `normalizarDispositivo` de la sección 4.3 para manejar registros antiguos que no tengan ese campo.

### Ejercicio 8.6 — Aislamiento de datos por cliente
Revisa el endpoint del panel de Denki que devuelve los dispositivos de un cliente (Bloque 09), y verifica que el filtrado se haga del lado del servidor a partir del token, no de un parámetro en la URL. Si actualmente depende de un parámetro libre, corrígelo.

### Ejercicio 8.7 — Plan de backup documentado
Escribe (en un README, no necesariamente en código) el plan de backup de Denki: qué se respalda, con qué frecuencia, dónde se guarda la copia secundaria, y cómo se probaría una restauración completa al menos una vez.

---

## Cómo se conecta este bloque con el resto del plan

Este bloque no se "termina" como los anteriores con un ejercicio final perfecto — es, por diseño, el bloque donde la teoría entrega el vocabulario y los patrones, pero la competencia real se construye operando el piloto de Denki con datos reales y viendo (de forma controlada, en un piloto con pocos clientes) qué falla. Eso no es una limitación del curso: es honesto reconocer que la resiliencia operativa se aprende mayormente en producción, con datos reales fallando frente a ti — el objetivo de este bloque es que cuando eso pase, ya tengas el marco conceptual para diagnosticarlo y resolverlo, en vez de empezar desde cero en ese momento.
