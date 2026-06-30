# Plan Maestro: 17 Semanas — De Cero a Fundador Técnico de Denki Power Systems

Versión actualizada que integra los 11 bloques de teoría existentes en un solo cronograma coherente. Se extendió de 16 a **17 semanas** para incorporar el Bloque 11 (Docker), que simplifica correr coordinados los servicios de backend (`denki-api`, PostgreSQL, InfluxDB, Node-RED) antes de avanzar a TypeScript/Testing y despliegue.

**Dedicación recomendada:** 3-4 horas diarias, 6 días a la semana.

---

## Mapa completo: semana → bloque de teoría → entregable para Denki

| Semana | Bloque de teoría | Entregable |
|---|---|---|
| 1-2 | Bloque 1 — HTML y CSS | Landing page de Denki Power Systems |
| 3-4 | Bloque 2 — JavaScript | Utilidades internas (cálculos, prototipo de tabla de sensores) |
| 5-6 | Bloque 3 — Vue.js (fundamentos → producción) | Panel de cliente / dashboard (Vite + Router + Pinia) |
| 7-8 | **Bloque 9 — Backend (Node.js/Express), SQL, Autenticación, Big O** | API real de Denki: clientes, usuarios, login, dispositivos en PostgreSQL |
| 9 | **Bloque 11 — Docker** | `denki-api` + PostgreSQL + InfluxDB + Node-RED corriendo coordinados con Docker Compose |
| 10 | Bloque 6 — TypeScript + Testing | Backend y frontend tipados, con pruebas automatizadas (Vitest + CI) |
| 11 | Bloque 5 — Git, Despliegue y Producción | `denki-landing`, `denki-app` y `denki-api` desplegados con CI/CD (ahora incluyendo build de imágenes Docker) |
| 12 | Bloque 4 — Node-RED / IoT | Flujo de procesamiento de sensores corriendo en hardware (Pi/EDATEC) |
| 13 | Bloque 7 — HTTP/CORS, Seguridad, InfluxDB | Histórico de lecturas en InfluxDB, comunicación segura entre todos los servicios |
| 14 | Bloque 10 — WebSockets y MQTT a profundidad | Dashboard en tiempo real, sensores publicando vía MQTT |
| 15 | Bloque 8 — Resiliencia, Observabilidad, Escalabilidad | Health checks, logging estructurado, backups documentados |
| 16 | Validación de producto y modelo de negocio (no técnico) | Pricing, clientes piloto, feedback real |
| 17 | Lanzamiento + Plan B (empleo) documentado | MVP lanzado con al menos 1 cliente piloto |

---

## SEMANAS 1-2 — HTML y CSS (Bloque 1)
Landing page real de Denki: identidad de marca (ámbar `#B8720A`, Russo One/Rajdhani), formulario de lista de espera, 100% responsiva.

## SEMANAS 3-4 — JavaScript (Bloque 2)
Lógica de utilidades del dominio: cálculo de consumo eléctrico, conversión de unidades de sensores, prototipo de tabla de lecturas con `fetch` y manejo de los 3 estados de UI (cargando/error/éxito).

## SEMANAS 5-6 — Vue.js (Bloque 3)
Panel de cliente con arquitectura de producción: Vite, Single File Components, Vue Router (catálogo de dispositivos + detalle), Pinia (estado de monitoreo). Es la interfaz que más adelante (Semana 13) se conecta en tiempo real.

## SEMANAS 7-8 — Backend real: Node.js, SQL y Autenticación (Bloque 9, NUEVO en el cronograma)
Esta es la incorporación más importante de esta actualización. Hasta la versión anterior del plan, Denki no tenía backend propio con código — solo Node-RED. Ahora:
- **Semana 7**: Express, rutas RESTful para `clientes`, `dispositivos`, `usuarios`; modelado y consultas en PostgreSQL (tablas, llaves foráneas, JOINs).
- **Semana 8**: flujo completo de autenticación (`bcrypt` + JWT + middleware de protección de rutas), conexión del login real desde el panel Vue, y fundamentos de Big O/estructuras de datos aplicados a la lógica de negocio.

**Entregable:** un servicio `denki-api` (Express + PostgreSQL) que maneja clientes, usuarios y permisos — separado conceptualmente del flujo de sensores (que seguirá viviendo en Node-RED desde la Semana 11), reflejando cómo se estructuran los productos IoT reales: un backend tradicional para el negocio, un backend especializado para los datos de sensores.

## SEMANA 9 — Docker (Bloque 11, NUEVO en el cronograma)
Empaquetar `denki-api` con un Dockerfile, y orquestar junto con PostgreSQL, InfluxDB y Node-RED usando Docker Compose. Esto da consistencia entre el entorno de desarrollo y el de producción para las tres piezas de backend construidas hasta ahora, antes de avanzar a tipado/testing y despliegue formal.

**Entregable:** un `docker-compose.yml` que levanta todo el stack de backend de Denki con un solo comando, con volúmenes configurados para no perder datos de PostgreSQL/InfluxDB/Node-RED.

## SEMANA 10 — TypeScript y Testing (Bloque 6)
Ahora se aplica tanto al frontend (panel Vue) como al backend nuevo (`denki-api`): interfaces compartidas de `Dispositivo`/`Cliente`/`Usuario`, pruebas unitarias de la lógica de negocio y de autenticación, pipeline de CI con GitHub Actions.

## SEMANA 11 — Git, Despliegue y Producción (Bloque 5)
Ahora son **tres** repositorios a desplegar, no dos: `denki-landing`, `denki-app` (panel Vue) y `denki-api` (Express, ahora empaquetado en Docker desde la Semana 9). Variables de entorno reales, `.gitignore` correcto, redeploy automático para los tres, y el pipeline de CI construyendo y publicando la imagen Docker de la API.

## SEMANA 12 — Node-RED / IoT (Bloque 4)
El flujo de procesamiento de sensores, corriendo en Raspberry Pi/EDATEC (con `pm2`, o como contenedor Docker según lo evaluado en el Bloque 11 respecto al acceso a GPIO). El endpoint HTTP propio de Node-RED se mantiene independiente de `denki-api` (Semana 7-8): uno gestiona el negocio (clientes/usuarios), el otro gestiona el flujo físico de datos de sensores.

## SEMANA 13 — HTTP/CORS, Seguridad e InfluxDB (Bloque 7)
CORS configurado correctamente entre `denki-app`, `denki-api` y el endpoint de Node-RED (tres orígenes distintos que deben comunicarse de forma segura). Histórico de lecturas en InfluxDB con tags/fields bien modelados (`sensor_id`, `ubicacion`, `cliente_id`).

## SEMANA 14 — WebSockets y MQTT a profundidad (Bloque 10)
Cierre del flujo de datos en tiempo real: sensores publicando vía MQTT (topics jerárquicos, QoS apropiado por tipo de mensaje, Last Will and Testament para detectar desconexiones), Node-RED procesando y difundiendo por WebSocket, panel Vue actualizándose solo, sin polling.

**Entregable:** el dashboard de Denki ya no necesita recargarse para ver datos nuevos — el flujo completo sensor → MQTT → Node-RED → InfluxDB + WebSocket → panel Vue funciona de punta a punta.

## SEMANA 15 — Resiliencia, Observabilidad y Escalabilidad (Bloque 8)
Health checks en `denki-api` y en el flujo de Node-RED, logging estructurado, detección de "sensor silencioso", plan de backups (InfluxDB + PostgreSQL + flujos de Node-RED) documentado y, si el tiempo lo permite, probado una vez.

## SEMANA 16 — Validación de producto y modelo de negocio
(Sin cambios respecto a la versión anterior: definición de cliente objetivo, pricing, demo a 3-5 contactos reales, ajuste de prioridades según feedback.)

## SEMANA 17 — Lanzamiento y Plan B
(Sin cambios respecto a la versión anterior: lanzamiento con al menos 1 cliente piloto; si se necesita generar ingresos mientras Denki madura, todo este trabajo es portafolio directamente reutilizable para una posición fullstack júnior — ahora con un argumento más fuerte que antes, porque el backend ya no es solo Node-RED, sino una API propia con autenticación real, base de datos relacional y pruebas automatizadas.)

---

## Stack técnico final de Denki (actualizado)

| Componente | Tecnología |
|---|---|
| Landing pública | HTML + CSS (Tailwind) |
| Panel de cliente | Vue 3 + Vite + TypeScript + Pinia + Vue Router |
| Backend de negocio | Node.js + Express + PostgreSQL + JWT/bcrypt |
| Backend de sensores | Node-RED en Raspberry Pi/EDATEC, con `pm2` |
| Base de datos de series temporales | InfluxDB |
| Comunicación en tiempo real | MQTT (sensores → Node-RED) + WebSockets (Node-RED/API → panel Vue) |
| Pruebas | Vitest + Vue Test Utils + GitHub Actions (CI) |
| Despliegue | Vercel/Netlify (landing y panel), servidor propio o PaaS (API), hardware propio (Node-RED) |
| Control de versiones | Git + GitHub: `denki-landing`, `denki-app`, `denki-api` |
| Empaquetado y orquestación | Docker + Docker Compose para `denki-api`, PostgreSQL, InfluxDB y Node-RED |

### Nota sobre el realismo del plazo
17 semanas (algo más de 4 meses) es un plazo considerablemente más realista que las versiones anteriores (8, luego 12, luego 16 semanas) para llegar a un MVP que use un stack completo y honesto — no solo "funciona en la demo", sino con backend propio empaquetado de forma reproducible, base de datos relacional, autenticación real, tiempo real genuino, y al menos el vocabulario de resiliencia necesario para no romperse a la primera falla de hardware. Sigue sin ser un negocio escalado y rentable — eso requiere iteración continua más allá de este plan — pero es un punto de partida considerablemente más sólido, tanto para sostener Denki como para usarlo como portafolio si el plan B de empleo se vuelve necesario.

