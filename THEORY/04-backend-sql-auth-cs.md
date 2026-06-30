# Teoría Detallada — Bloque 04: Backend con Node.js, Bases de Datos SQL, Autenticación y Fundamentos de CS

Este bloque cierra el hueco más importante para que el perfil califique honestamente como **"fullstack"**: hasta ahora, todo el "backend" del curso es Node-RED, una herramienta excelente para IoT pero que muchos entrevistadores no van a reconocer como equivalente a "sé construir una API". Este bloque agrega un backend tradicional con código, una base de datos relacional (la más preguntada en entrevistas), un flujo de autenticación real, y los fundamentos de estructuras de datos/complejidad que cualquier entrevista técnica formal puede tocar.

---

## PARTE 1 — Node.js y Express: backend desde cero

### 1.1 ¿Qué es Node.js, exactamente?

JavaScript nació para correr **solo dentro del navegador**. Node.js es un entorno de ejecución que permite correr JavaScript **fuera** del navegador, directamente en una computadora/servidor — es lo que ya usabas indirectamente cada vez que corrías `npm install` o `vite`. Node.js le da a JavaScript acceso a cosas que el navegador no permite por seguridad: leer/escribir archivos del sistema, abrir conexiones de red de bajo nivel, manejar bases de datos.

### 1.2 npm y package.json (formalizando lo ya usado)

Ya usaste `npm install` varias veces en bloques anteriores; aquí se explica qué pasa exactamente:

```json
{
  "name": "denki-api",
  "version": "1.0.0",
  "scripts": {
    "dev": "node server.js",
    "test": "vitest"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
```
- **`dependencies`**: paquetes necesarios para que la app **funcione en producción** (Express, una librería de base de datos).
- **`devDependencies`**: paquetes solo necesarios **durante el desarrollo** (herramientas de testing, recarga automática), que no se necesitan en el servidor final.
- **Versionado semántico (`^4.18.2`)**: el formato es `MAYOR.MENOR.PARCHE`. Un cambio de **PARCHE** corrige bugs sin romper nada; un cambio de **MENOR** agrega funcionalidad sin romper compatibilidad; un cambio **MAYOR** puede romper código existente. El símbolo `^` permite actualizar automáticamente versiones menores/parche, pero no mayores — esto evita que una actualización silenciosa rompa el proyecto.
- **`package-lock.json`**: registra las versiones **exactas** instaladas de cada dependencia (incluyendo las dependencias de las dependencias), garantizando que todo el equipo (y el servidor de producción) instale exactamente lo mismo.

### 1.3 Express: el framework backend más usado en el ecosistema Node

```bash
npm install express
```

```js
// server.js
import express from 'express';
const app = express();

app.use(express.json()); // middleware: permite leer el body de peticiones JSON automáticamente

app.get('/api/dispositivos', (req, res) => {
  res.json([{ id: 1, nombre: "Sensor planta1" }]);
});

app.post('/api/dispositivos', (req, res) => {
  const nuevoDispositivo = req.body; // ya viene parseado gracias al middleware
  // ... guardar en base de datos (Parte 2)
  res.status(201).json(nuevoDispositivo);
});

app.listen(3000, () => console.log('Servidor corriendo en puerto 3000'));
```

**Conceptos clave:**
- `app.get`/`app.post`/`app.patch`/`app.delete`: registran una función que se ejecuta cuando llega una petición con ese método y ruta — exactamente las rutas RESTful diseñadas en el Bloque 09, ahora implementadas con código real en vez de nodos visuales de Node-RED.
- **`req` (request)**: contiene todo sobre la petición entrante (`req.body`, `req.params`, `req.query`, `req.headers`).
- **`res` (response)**: el objeto con el que se construye la respuesta (`res.json(...)`, `res.status(...)`).
- **Middleware** (`app.use(...)`): funciones que se ejecutan **antes** de llegar a la ruta final, útiles para tareas transversales (parsear el body, verificar autenticación, registrar logs) sin repetir ese código en cada ruta.

### 1.4 Parámetros de ruta y query strings

```js
app.get('/api/dispositivos/:id', (req, res) => {
  const id = req.params.id; // de la URL: /api/dispositivos/5 → id = "5"
  res.json({ id, nombre: "Sensor planta1" });
});

app.get('/api/dispositivos', (req, res) => {
  const ubicacion = req.query.ubicacion; // de la URL: /api/dispositivos?ubicacion=planta1
  res.json({ filtradoPor: ubicacion });
});
```

### 1.5 Middleware personalizado (ejemplo: logging y manejo de errores)

```js
function logRequests(req, res, next) {
  console.log(`${req.method} ${req.path} — ${new Date().toISOString()}`);
  next(); // IMPORTANTE: sin next(), la petición se queda "atascada" y nunca llega a su ruta final
}
app.use(logRequests);

// middleware de manejo de errores: debe ir AL FINAL, después de todas las rutas
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: "Error interno del servidor" });
});
```

### 1.6 Organización de un proyecto Express real

```
denki-api/
  src/
    routes/
      dispositivos.js
      alertas.js
    controllers/
      dispositivosController.js
    middleware/
      auth.js
    db/
      conexion.js
  server.js
```

Esta separación (rutas / controladores / middleware / acceso a datos) es el equivalente backend a separar componentes/stores/router en Vue (Bloque 03): cada capa tiene una responsabilidad clara, lo que facilita mantener y probar el código a medida que crece.

---

## PARTE 2 — Bases de datos relacionales (SQL)

### 2.1 ¿Por qué SQL además de InfluxDB?

InfluxDB (Bloque 09) es ideal para **series temporales** (lecturas de sensores). Pero datos como "clientes de Denki", "usuarios y sus permisos", "dispositivos registrados y a qué cliente pertenecen" tienen **relaciones** entre sí (un cliente tiene muchos dispositivos, un dispositivo pertenece a un cliente) — para esto, una base de datos **relacional** (PostgreSQL, MySQL) es la herramienta correcta, y es, por mucho, la más preguntada en entrevistas técnicas júnior.

### 2.2 Tablas, filas y columnas

```sql
CREATE TABLE clientes (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  correo VARCHAR(100) UNIQUE NOT NULL,
  creado_en TIMESTAMP DEFAULT NOW()
);

CREATE TABLE dispositivos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  cliente_id INTEGER REFERENCES clientes(id), -- llave foránea: conecta con la tabla clientes
  ubicacion VARCHAR(100)
);
```
- **`PRIMARY KEY`**: identificador único de cada fila.
- **`REFERENCES`** (llave foránea / foreign key): establece la **relación** entre tablas — cada dispositivo "pertenece" a un cliente específico, y la base de datos garantiza que no se pueda registrar un dispositivo con un `cliente_id` que no exista.
- **`UNIQUE`**: ningún correo puede repetirse entre dos clientes.
- **`NOT NULL`**: el campo es obligatorio.

### 2.3 CRUD con SQL

```sql
-- Create
INSERT INTO dispositivos (nombre, cliente_id, ubicacion) VALUES ('BMP280-01', 1, 'Planta 1');

-- Read
SELECT * FROM dispositivos WHERE cliente_id = 1;

-- Update
UPDATE dispositivos SET ubicacion = 'Planta 2' WHERE id = 5;

-- Delete
DELETE FROM dispositivos WHERE id = 5;
```

### 2.4 JOINs: la operación más importante de SQL

```sql
SELECT dispositivos.nombre, clientes.nombre AS cliente
FROM dispositivos
JOIN clientes ON dispositivos.cliente_id = clientes.id
WHERE clientes.id = 1;
```
Un `JOIN` combina filas de dos (o más) tablas relacionadas, en este caso devolviendo el nombre del dispositivo **junto con** el nombre del cliente al que pertenece, en una sola consulta — sin esto, habría que hacer dos consultas separadas y unir los resultados manualmente en código.

### 2.5 Normalización (concepto básico)

Normalizar significa organizar los datos para evitar **duplicación** y **inconsistencia**. Ejemplo de diseño **mal normalizado**:
```
dispositivos: id, nombre, cliente_nombre, cliente_correo  -- el nombre/correo del cliente se repite en cada dispositivo
```
Si el cliente cambia su correo, habría que actualizarlo en **cada fila de dispositivo** donde aparece — fácil de olvidar, generando inconsistencia. La versión normalizada (sección 2.2) guarda el correo **una sola vez** en `clientes`, y los dispositivos solo guardan una referencia (`cliente_id`).

### 2.6 Conectar Express a PostgreSQL

```bash
npm install pg
```
```js
// db/conexion.js
import { Pool } from 'pg';
export const pool = new Pool({ connectionString: process.env.DATABASE_URL });
```
```js
// routes/dispositivos.js
app.get('/api/dispositivos', async (req, res) => {
  const resultado = await pool.query('SELECT * FROM dispositivos WHERE cliente_id = $1', [req.clienteId]);
  res.json(resultado.rows);
});
```
**Nota de seguridad crítica**: usar `$1` como parámetro (en vez de concatenar el valor directamente en el string SQL) previene **inyección SQL** (SQL injection) — un ataque donde alguien envía código SQL malicioso dentro de un input normal (por ejemplo, en un campo de búsqueda), intentando manipular la consulta para leer o borrar datos que no debería. Nunca se debe construir una consulta SQL concatenando directamente texto proveniente del usuario.

---

## PARTE 3 — Autenticación real, de extremo a extremo

### 3.1 Flujo completo de registro

```js
import bcrypt from 'bcrypt';

app.post('/api/registro', async (req, res) => {
  const { correo, password } = req.body;

  const hash = await bcrypt.hash(password, 10); // NUNCA se guarda la contraseña en texto plano

  await pool.query(
    'INSERT INTO usuarios (correo, password_hash) VALUES ($1, $2)',
    [correo, hash]
  );

  res.status(201).json({ mensaje: "Usuario creado" });
});
```

**Por qué `bcrypt` y no guardar la contraseña directamente**: si la base de datos llegara a filtrarse (un riesgo real, no hipotético), las contraseñas en texto plano comprometerían inmediatamente las cuentas de todos los usuarios — y como mucha gente reutiliza contraseñas, también otras cuentas suyas en otros servicios. `bcrypt` aplica un algoritmo de hash **diseñado para ser lento intencionalmente** (a diferencia de hashes rápidos como MD5/SHA-1, inapropiados para contraseñas), dificultando ataques de fuerza bruta incluso si el hash se filtra.

### 3.2 Flujo completo de login

```js
import jwt from 'jsonwebtoken';

app.post('/api/login', async (req, res) => {
  const { correo, password } = req.body;

  const resultado = await pool.query('SELECT * FROM usuarios WHERE correo = $1', [correo]);
  const usuario = resultado.rows[0];

  if (!usuario) {
    return res.status(401).json({ error: "Credenciales inválidas" });
  }

  const passwordCorrecta = await bcrypt.compare(password, usuario.password_hash);
  if (!passwordCorrecta) {
    return res.status(401).json({ error: "Credenciales inválidas" });
  }

  const token = jwt.sign(
    { userId: usuario.id, clienteId: usuario.cliente_id },
    process.env.JWT_SECRET,
    { expiresIn: '24h' }
  );

  res.json({ token });
});
```

**Punto de seguridad importante**: el mensaje de error es **el mismo** ("Credenciales inválidas") tanto si el correo no existe como si la contraseña es incorrecta. Si se diera un mensaje distinto ("este correo no existe" vs "contraseña incorrecta"), un atacante podría usar esa diferencia para **descubrir qué correos están registrados** en el sistema, probando uno por uno — esto se llama "enumeración de usuarios" y es una vulnerabilidad real y común.

### 3.3 Middleware de autenticación (protegiendo rutas)

```js
// middleware/auth.js
import jwt from 'jsonwebtoken';

export function requiereAutenticacion(req, res, next) {
  const header = req.headers.authorization; // "Bearer eyJhbGc..."
  const token = header?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: "No autenticado" });
  }

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.clienteId = payload.clienteId; // disponible para las rutas siguientes
    next();
  } catch (e) {
    return res.status(401).json({ error: "Token inválido o expirado" });
  }
}
```
```js
app.get('/api/dispositivos', requiereAutenticacion, async (req, res) => {
  // req.clienteId ya está disponible y verificado, viene del token, NUNCA de un parámetro libre
  const resultado = await pool.query('SELECT * FROM dispositivos WHERE cliente_id = $1', [req.clienteId]);
  res.json(resultado.rows);
});
```
Esto implementa, con código real, exactamente el patrón de multi-tenancy seguro descrito conceptualmente en el Bloque 11: el `clienteId` viene del token verificado por el servidor, nunca de algo que el cliente podría manipular libremente.

### 3.4 Consumir esto desde el panel Vue (cerrando el círculo con el Bloque 03)

```ts
async function login(correo: string, password: string) {
  const respuesta = await fetch('/api/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ correo, password })
  });
  const { token } = await respuesta.json();
  localStorage.setItem('token', token); // ver Bloque 09, sección 2.3, sobre los riesgos de esto vs cookies HttpOnly

  return token;
}

async function obtenerDispositivos() {
  const token = localStorage.getItem('token');
  const respuesta = await fetch('/api/dispositivos', {
    headers: { Authorization: `Bearer ${token}` }
  });
  return await respuesta.json();
}
```

---

## PARTE 4 — Fundamentos de estructuras de datos y complejidad (Big O)

### 4.1 ¿Por qué importa esto si ya sabes usar arrays y objetos?

En el Bloque 02 usaste arrays/objetos de forma práctica. Lo que falta es entender **qué tan "caro" es** cada operación a medida que los datos crecen — esto es lo que se pregunta en entrevistas técnicas más formales, y también afecta directamente el rendimiento real de Denki cuando haya miles de lecturas de sensores.

### 4.2 Notación Big O (concepto, sin matemática formal)

Big O describe cómo crece el tiempo (o la memoria) que toma una operación, **en función del tamaño de los datos** (`n`), no el tiempo exacto en segundos.

| Notación | Significado | Ejemplo |
|---|---|---|
| `O(1)` | Tiempo constante, no importa cuántos datos haya | Acceder a `array[5]` por índice |
| `O(log n)` | Crece muy lento al aumentar los datos | Búsqueda binaria en datos ordenados |
| `O(n)` | Crece proporcional a la cantidad de datos | Un `for`/`map`/`filter` recorriendo todo el array una vez |
| `O(n²)` | Crece al cuadrado — peligroso con datos grandes | Un `for` anidado dentro de otro `for` sobre el mismo array |

```js
// O(n): una sola pasada
function buscarPorId(dispositivos, id) {
  return dispositivos.find(d => d.id === id); // recorre como máximo una vez todo el array
}

// O(n²): peligroso si "dispositivos" crece mucho
function encontrarDuplicados(dispositivos) {
  const duplicados = [];
  for (let i = 0; i < dispositivos.length; i++) {
    for (let j = i + 1; j < dispositivos.length; j++) {
      if (dispositivos[i].id === dispositivos[j].id) duplicados.push(dispositivos[i]);
    }
  }
  return duplicados;
}

// La misma operación, O(n) usando un Set/Map en vez de comparar todo contra todo
function encontrarDuplicadosEficiente(dispositivos) {
  const vistos = new Set();
  const duplicados = [];
  for (const d of dispositivos) {
    if (vistos.has(d.id)) duplicados.push(d);
    vistos.add(d.id);
  }
  return duplicados;
}
```
Con 100 dispositivos, ambas versiones son casi igual de rápidas. Con 100,000 lecturas de sensores acumuladas, la versión `O(n²)` puede tardar **minutos** mientras la versión `O(n)` tarda milisegundos — esta es la razón práctica, no solo teórica, de por qué importa.

### 4.3 Estructuras de datos básicas más allá de array/objeto

```js
// Set: colección de valores ÚNICOS, búsqueda O(1)
const idsConectados = new Set();
idsConectados.add("sensor-1");
idsConectados.has("sensor-1"); // true, búsqueda muy rápida sin importar cuántos elementos tenga

// Map: como un objeto, pero con cualquier tipo de clave y mejor rendimiento para muchas entradas
const cacheLecturas = new Map();
cacheLecturas.set("sensor-1", { valor: 24.3, timestamp: Date.now() });
cacheLecturas.get("sensor-1");

// Pila (stack): "último en entrar, primero en salir" — útil para historial de acciones (deshacer/rehacer)
const historial = [];
historial.push(accion);     // agregar
historial.pop();              // quitar el más reciente

// Cola (queue): "primero en entrar, primero en salir" — útil para procesar mensajes en orden (conecta con la cola de reintentos del Bloque 11)
const colaMensajes = [];
colaMensajes.push(mensaje); // agregar al final
colaMensajes.shift();         // quitar el más antiguo
```

### 4.4 Por qué esto conecta directamente con Denki

Cuando el sistema de Denki acumule miles de lecturas históricas y necesite, por ejemplo, detectar rápidamente si un `sensorId` ya fue procesado en el ciclo actual (para evitar duplicados), usar un `Set` (`O(1)` de búsqueda) en vez de `array.includes()` (`O(n)`, recorre todo el array cada vez) es la diferencia entre un sistema que escala bien y uno que se vuelve lento silenciosamente a medida que crecen los datos — exactamente el tipo de problema de escalabilidad mencionado conceptualmente en el Bloque 11, ahora con la herramienta concreta para resolverlo.

---

## Ejercicios del Bloque 04

### Ejercicio 9.1 — API REST con Express
Construye, con Express, las rutas `GET /api/dispositivos`, `POST /api/dispositivos` y `DELETE /api/dispositivos/:id`, usando un array en memoria como almacenamiento temporal (sin base de datos todavía).

### Ejercicio 9.2 — Modelado y consultas SQL
Diseña las tablas `clientes`, `dispositivos` y `usuarios` (con `password_hash`) con sus llaves foráneas correspondientes, e instala PostgreSQL localmente (o usa un servicio gratuito como Supabase/Neon) para crear las tablas con `CREATE TABLE`.

### Ejercicio 9.3 — JOIN real
Escribe una consulta SQL que devuelva, para cada dispositivo, su nombre y el correo del cliente al que pertenece, usando `JOIN`.

### Ejercicio 9.4 — Flujo completo de autenticación
Implementa `/api/registro` y `/api/login` con `bcrypt` y `jsonwebtoken`, y el middleware `requiereAutenticacion`. Prueba que una ruta protegida rechace peticiones sin token (401) y acepte peticiones con un token válido.

### Ejercicio 9.5 — Conectar el panel de Denki a la nueva API
Modifica el panel Vue (Bloque 03) para que el login real consuma `/api/login`, guarde el token, y lo use en cada petición subsecuente a `/api/dispositivos`.

### Ejercicio 9.6 — Big O aplicado
Toma la función `encontrarDuplicados` (sección 4.2, versión `O(n²)`) y reescríbela usando un `Set` para que sea `O(n)`. Prueba ambas versiones con un array de 10,000 elementos generados aleatoriamente y compara el tiempo de ejecución con `console.time()`/`console.timeEnd()`.

---

## Cómo se conecta este bloque con el resto del plan

Con este bloque, Denki deja de depender únicamente de Node-RED para su lógica de negocio (clientes, usuarios, permisos), reservando Node-RED para lo que mejor hace: procesamiento de datos de sensores en tiempo real. La arquitectura final tiene dos backends complementarios, no uno sustituyendo al otro: **Express + PostgreSQL** para datos relacionales del negocio (clientes, usuarios, configuración), y **Node-RED + InfluxDB** para el flujo de datos de sensores — exactamente como suelen estructurarse los productos IoT reales en la industria.
