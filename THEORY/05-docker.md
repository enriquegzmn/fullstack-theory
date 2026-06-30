# Teoría Detallada — Bloque 05: Docker

Este bloque resuelve un problema concreto que para este punto del plan ya es real, no hipotético: Denki tiene **tres piezas distintas** que deben correr juntas (`denki-api` con Node.js/Express, PostgreSQL, Node-RED, e InfluxDB), cada una con su propia forma de instalarse y configurarse. Sin Docker, "que funcione en mi máquina" y "que funcione en el servidor/Raspberry Pi" son dos problemas separados que hay que resolver dos veces. Se ubica conceptualmente después del Bloque 04 (Backend) y se relaciona directamente con el Bloque 07 (Despliegue).

---

## 1. ¿Qué problema resuelve Docker?

### 1.1 El problema clásico: "funciona en mi máquina"

Imagina que `denki-api` necesita Node.js 18, PostgreSQL 15, y ciertas variables de entorno configuradas. En tu laptop tienes exactamente esas versiones instaladas. Cuando despliegas en un servidor nuevo (o en la Raspberry Pi), puede tener Node.js 16, una versión distinta de PostgreSQL, o simplemente no tener PostgreSQL instalado en absoluto. El resultado: código que "funcionaba" deja de funcionar, no porque el código esté mal, sino porque el **entorno** es distinto.

### 1.2 La solución: contenedores

Un **contenedor** empaqueta una aplicación junto con **todo lo que necesita para correr** (el runtime de Node.js, las librerías del sistema, la configuración) en una unidad portable y aislada. A diferencia de una máquina virtual completa (que simula una computadora entera, con su propio sistema operativo, pesada y lenta de iniciar), un contenedor comparte el kernel del sistema operativo anfitrión y solo aísla el proceso de la aplicación — mucho más ligero y rápido de iniciar (segundos, no minutos).

**Analogía**: si una máquina virtual es como mudarte a una casa completamente nueva con todo construido desde cero, un contenedor es como un departamento amueblado dentro de un edificio ya existente — comparte la estructura del edificio (el sistema operativo base), pero cada departamento (contenedor) tiene exactamente los muebles y la configuración que necesita, sin interferir con los demás.

### 1.3 Imagen vs Contenedor

- **Imagen**: la "plantilla" o "receta" — un paquete inmutable que contiene el código de la aplicación más todas sus dependencias, listo para ejecutarse.
- **Contenedor**: una **instancia en ejecución** de una imagen. De la misma imagen se pueden crear múltiples contenedores corriendo simultáneamente (por ejemplo, varias instancias de `denki-api` para repartir carga).

---

## 2. El Dockerfile: la receta de una imagen

### 2.1 Dockerfile para `denki-api` (Node.js/Express, conectando con el Bloque 04)

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 3000

CMD ["node", "server.js"]
```

**Explicación línea por línea:**
- **`FROM node:18-alpine`**: la imagen "base" sobre la que se construye — en este caso, una versión ligera (`alpine`, una distribución mínima de Linux) que ya incluye Node.js 18 instalado. No hay que instalar Node.js manualmente; ya viene en la imagen base.
- **`WORKDIR /app`**: define la carpeta de trabajo dentro del contenedor; todos los comandos siguientes se ejecutan relativos a esta ruta.
- **`COPY package*.json ./`**: copia primero **solo** los archivos de dependencias (`package.json` y `package-lock.json`), antes de copiar el resto del código.
- **`RUN npm install --production`**: instala las dependencias dentro de la imagen.
- **`COPY . .`**: copia el resto del código fuente.
- **`EXPOSE 3000`**: documenta que la aplicación escucha en el puerto 3000 (no abre el puerto por sí mismo, es informativo).
- **`CMD [...]`**: el comando que se ejecuta cuando el contenedor arranca.

**¿Por qué copiar `package.json` antes que el resto del código?** Docker construye imágenes en **capas**, y cachea cada capa: si solo cambias un archivo de código fuente (no las dependencias), Docker puede reutilizar la capa ya construida de `npm install` (que suele ser la parte más lenta) en vez de reinstalar todo desde cero cada vez. Cambiar el orden (copiar todo el código antes de instalar dependencias) invalidaría ese caché en cada cambio de código, haciendo cada build innecesariamente lento.

### 2.2 Construir y correr la imagen

```bash
docker build -t denki-api .          # construye la imagen, etiquetada como "denki-api"
docker run -p 3000:3000 denki-api      # corre un contenedor, mapeando el puerto 3000 del contenedor al 3000 de la máquina anfitriona
```
`-p 3000:3000` (formato `puerto_anfitrión:puerto_contenedor`) es lo que permite acceder a la app desde `http://localhost:3000` en tu máquina, aunque la aplicación esté corriendo "dentro" del contenedor aislado.

### 2.3 Variables de entorno en Docker (conectando con el Bloque 07 y 9)

```bash
docker run -p 3000:3000 \
  -e DATABASE_URL="postgresql://usuario:clave@db:5432/denki" \
  -e JWT_SECRET="secreto-real-no-este" \
  denki-api
```
Las variables de entorno (vistas en el Bloque 07 para el frontend, y en el Bloque 04 para `JWT_SECRET`/`DATABASE_URL`) se inyectan al contenedor en tiempo de ejecución, **nunca** se incluyen dentro de la imagen — la misma imagen de `denki-api` puede correr en desarrollo, staging o producción simplemente cambiando las variables de entorno con las que se inicia, sin reconstruir nada.

---

## 3. Docker Compose: orquestar varios servicios juntos

### 3.1 El problema de correr todo por separado

`denki-api` necesita a PostgreSQL corriendo y accesible; si además se quiere correr Node-RED e InfluxDB en el mismo entorno de desarrollo, ejecutar cada `docker run` por separado, con sus puertos y redes correctos, se vuelve tedioso y propenso a errores. **Docker Compose** describe todos los servicios relacionados en **un solo archivo**, y los levanta juntos con un solo comando.

### 3.2 docker-compose.yml para el stack completo de Denki

```yaml
version: "3.8"

services:
  api:
    build: ./denki-api
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://denki:claveSegura@db:5432/denki
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      - POSTGRES_USER=denki
      - POSTGRES_PASSWORD=claveSegura
      - POSTGRES_DB=denki
    volumes:
      - datos_postgres:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  influxdb:
    image: influxdb:2.7
    ports:
      - "8086:8086"
    volumes:
      - datos_influx:/var/lib/influxdb2

  node-red:
    image: nodered/node-red:latest
    ports:
      - "1880:1880"
    volumes:
      - datos_nodered:/data
    depends_on:
      - influxdb

volumes:
  datos_postgres:
  datos_influx:
  datos_nodered:
```

**Conceptos clave:**
- **`services`**: cada bloque (`api`, `db`, `influxdb`, `node-red`) es un servicio independiente, equivalente a un contenedor.
- **`build` vs `image`**: `api` se **construye** desde un Dockerfile local (`./denki-api`); `db`, `influxdb` y `node-red` usan **imágenes ya publicadas** (oficiales), sin necesidad de escribir un Dockerfile propio para ellas.
- **`depends_on`**: indica el orden de arranque (la API espera a que la base de datos inicie primero) — aunque, importante, **no garantiza** que el servicio dependiente ya esté completamente listo para recibir conexiones, solo que el contenedor ya inició; para eso existen mecanismos de "health check" más avanzados que no se cubren a este nivel introductorio.
- **`volumes`**: la sección más importante para no perder datos (conectando directamente con el Bloque 11 — backups). Sin volúmenes, los datos de PostgreSQL/InfluxDB/Node-RED viven **dentro** del contenedor, y se pierden por completo si el contenedor se elimina. Con un volumen nombrado (`datos_postgres`, etc.), los datos persisten en el disco del anfitrión, independientemente de si el contenedor se recrea, actualiza o elimina.
- **`environment` con `${JWT_SECRET}`**: Compose puede leer variables desde un archivo `.env` en la misma carpeta (excluido de Git, como se vio en el Bloque 07), evitando escribir secretos directamente en el `docker-compose.yml`.

### 3.3 Comandos básicos de Compose

```bash
docker compose up -d          # levanta TODOS los servicios definidos, en segundo plano (-d = detached)
docker compose logs -f api      # sigue los logs de un servicio específico en tiempo real
docker compose down               # detiene y elimina los contenedores (los volúmenes persisten, a menos que se use -v)
docker compose ps                   # lista el estado de los servicios
```
Con un solo `docker compose up -d`, todo el stack de Denki (API, PostgreSQL, InfluxDB, Node-RED) arranca coordinado — esto reemplaza el proceso manual de instalar y configurar cada pieza por separado, tanto en tu máquina de desarrollo como, potencialmente, en el servidor de producción.

---

## 4. Docker en el contexto específico de Denki (hardware + nube)

### 4.1 ¿Dónde sí y dónde no usar Docker en la arquitectura de Denki?

- **`denki-api` + PostgreSQL**: candidatos ideales para Docker, ya sea en un servidor en la nube (Render, Railway, una VPS) o incluso en el propio hardware si se prefiere centralizar.
- **Node-RED**: puede correr en Docker perfectamente (de hecho, la imagen oficial `nodered/node-red` ya lo asume), incluso en la Raspberry Pi/EDATEC — esto simplifica actualizar Node-RED a una versión nueva (solo se cambia la imagen) sin tener que reinstalar manualmente con `npm`.
- **GPIO de la Raspberry Pi**: aquí hay una consideración especial — acceder a hardware físico (pines GPIO) desde un contenedor requiere configuración adicional (montar dispositivos específicos del sistema dentro del contenedor), porque por diseño los contenedores están aislados del hardware del anfitrión. Para el flujo de sensores que dependen directamente de GPIO, evaluar caso por caso si conviene correr Node-RED en Docker o nativamente en el sistema operativo de la Pi.

### 4.2 Docker y el pipeline de CI/CD (conectando con el Bloque 07)

```yaml
# .github/workflows/deploy.yml (extensión del visto en el Bloque 07)
name: Build and Push
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: docker build -t denki-api:${{ github.sha }} ./denki-api
      - run: docker push tu-registro/denki-api:${{ github.sha }}
```
Esto construye una imagen Docker nueva en cada `push`, etiquetada con el identificador exacto del commit (`github.sha`), y la sube a un registro de imágenes (Docker Hub, GitHub Container Registry). El servidor de producción luego solo necesita **descargar** esa imagen ya construida y correrla — un proceso de despliegue mucho más predecible que copiar código fuente y esperar que el entorno de producción tenga exactamente las mismas versiones de todo.

---

## Ejercicios del Bloque 05

### Ejercicio 11.1 — Dockerfile para denki-api
Escribe el Dockerfile completo para `denki-api` (Bloque 04), constrúyelo (`docker build`) y córrelo (`docker run`), verificando que responda correctamente en `http://localhost:3000`.

### Ejercicio 11.2 — docker-compose con dos servicios
Crea un `docker-compose.yml` con solo dos servicios: `api` y `db` (PostgreSQL), usando `depends_on` y un volumen para los datos de PostgreSQL. Levántalo con `docker compose up -d` y verifica que `denki-api` pueda conectarse correctamente a la base de datos.

### Ejercicio 11.3 — Persistencia de datos con volúmenes
Levanta el servicio `db` del ejercicio anterior, inserta datos de prueba, y luego ejecuta `docker compose down` seguido de `docker compose up -d` nuevamente. Verifica que los datos sigan ahí gracias al volumen — y luego repite el experimento **sin** el volumen configurado, para confirmar (de forma controlada) que los datos efectivamente se pierden sin él.

### Ejercicio 11.4 — Stack completo de Denki
Extiende el `docker-compose.yml` para incluir los 4 servicios de la sección 3.2 (`api`, `db`, `influxdb`, `node-red`), y levanta todo el stack con un solo comando.

### Ejercicio 11.5 — Variables de entorno seguras
Modifica el `docker-compose.yml` para que `JWT_SECRET` y las credenciales de PostgreSQL se lean desde un archivo `.env` (excluido de Git), en vez de estar escritas directamente en el archivo de Compose.

---

## Cómo se conecta este bloque con el resto del plan

Docker no sustituye nada de lo aprendido en los Bloques 5 (despliegue), 8 (backups/resiliencia) o 9 (backend) — los complementa, dándote una forma consistente de empaquetar y mover el stack completo de Denki entre tu máquina de desarrollo, un entorno de pruebas, y producción, sin que "funciona en mi máquina" sea un riesgo recurrente. Es, junto con el Bloque 04, una de las piezas que hace que el backend de Denki se sienta como infraestructura real de producto, no como un experimento que solo corre en una computadora específica.
