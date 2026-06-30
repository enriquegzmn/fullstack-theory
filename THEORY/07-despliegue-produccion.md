# Teoría Detallada — Bloque 07: Git, Despliegue y Producción (Semana 11 en el plan Denki)

Este bloque es tan importante para conseguir empleo como saber programar: un proyecto que solo vive en tu computadora **no cuenta como portafolio**. Aquí aprenderás a llevar cada proyecto desde tu máquina hasta una URL pública real, de forma profesional.

---

## 1. Control de versiones con Git

### 1.1 ¿Qué problema resuelve Git?
Sin control de versiones, si cometes un error y quieres volver a una versión anterior de tu código, tendrías que recordar manualmente qué cambiaste (o tener carpetas como `proyecto-final-v2-definitivo-AHORA-SI.zip`). Git resuelve esto guardando un **historial completo** de cada cambio, permitiendo volver atrás, comparar versiones, y trabajar en paralelo sin pisar el trabajo de otros (o el tuyo propio de ayer).

### 1.2 Conceptos fundamentales
- **Repositorio (repo)**: una carpeta cuyo historial de cambios está siendo rastreado por Git.
- **Commit**: una "fotografía" guardada del estado del proyecto en un momento específico, con un mensaje descriptivo.
- **Branch (rama)**: una línea de desarrollo independiente; permite trabajar en una funcionalidad nueva sin afectar el código que ya funciona.
- **Remote (remoto)**: una copia del repositorio alojada en un servidor (típicamente GitHub), que permite respaldar el código y colaborar con otros.

### 1.3 Flujo de trabajo básico

```bash
git init                          # convierte la carpeta actual en un repositorio Git
git status                         # muestra qué archivos han cambiado desde el último commit
git add archivo.html                # marca un archivo específico para incluir en el próximo commit
git add .                            # marca TODOS los archivos modificados
git commit -m "Agrega sección de contacto" # guarda una "fotografía" con un mensaje descriptivo
git log                                # muestra el historial de commits
```

**Buenas prácticas de mensajes de commit:**
- Deben describir QUÉ cambia y, si es relevante, POR QUÉ — no "cambios" o "arreglo cosas".
- Ejemplos buenos: `"Agrega validación de formulario de checkout"`, `"Corrige cálculo de envío gratis"`.
- Hacer commits **pequeños y frecuentes** es mejor que un commit gigante al final del día: facilita encontrar en qué momento se introdujo un error, y es lo primero que un reclutador revisa al ver tu historial de GitHub.

### 1.4 Conectar con GitHub (remoto)

```bash
git remote add origin https://github.com/tu-usuario/tu-proyecto.git
git branch -M main                  # renombra la rama principal a "main" (convención actual)
git push -u origin main              # sube el código al remoto por primera vez
git push                              # en adelante, solo esto para subir nuevos commits
git pull                               # descarga cambios del remoto (importante si trabajas desde varias máquinas)
```

### 1.5 Ramas (branches) y Pull Requests

```bash
git branch nueva-funcionalidad        # crea una rama nueva
git checkout nueva-funcionalidad        # cambia a esa rama
git checkout -b otra-funcionalidad        # atajo: crea Y cambia a la rama en un solo paso
git checkout main                          # vuelve a la rama principal
git merge nueva-funcionalidad                # integra los cambios de la rama a main
```

En proyectos reales (y en equipos de trabajo), el flujo típico es: crear una rama por cada funcionalidad nueva, subirla a GitHub, abrir un **Pull Request** (una solicitud para que esos cambios se integren a `main`, normalmente revisada por otra persona antes de aprobarse), y luego hacer `merge`. Esto evita que código sin revisar o con errores llegue directo a la versión "oficial" del proyecto.

### 1.6 El archivo .gitignore

```
node_modules/
.env
.DS_Store
dist/
```
Le dice a Git qué archivos/carpetas **nunca** debe rastrear ni subir al repositorio: dependencias instaladas (pesadas y regenerables), archivos con información sensible (contraseñas, claves de API), archivos generados automáticamente por el sistema operativo, y carpetas de build. Subir accidentalmente un archivo `.env` con contraseñas reales a un repositorio público es uno de los errores de seguridad más comunes de principiantes — el `.gitignore` previene esto desde el inicio del proyecto.

---

## 2. Conceptos de hosting y dominios

### 2.1 ¿Qué significa "desplegar" (deploy) un proyecto?
Desplegar significa subir tu código a un servidor que esté **encendido y accesible 24/7 desde internet**, en vez de solo en tu computadora (que se apaga, y que no tiene una dirección pública accesible para cualquiera).

### 2.2 Tipos de proyectos según su forma de despliegue

- **Sitio estático** (HTML/CSS/JS puro, o un proyecto Vue "compilado"): no necesita un servidor que ejecute código en tiempo real, solo necesita servir archivos. Se despliega en servicios como **Netlify**, **Vercel** o **GitHub Pages**.
- **Aplicación con backend** (que necesita ejecutar lógica de servidor constantemente, como Node-RED): necesita un servidor que mantenga un proceso corriendo todo el tiempo. Se despliega en servicios como **Render**, **Railway**, una VPS (servidor virtual privado), o hardware propio (como la Raspberry Pi/EDATEC en el caso de Denki).

### 2.3 DNS y dominios (concepto)
Un dominio (`www.denkipower.com`) es un nombre legible para humanos que apunta a una dirección IP (la dirección numérica real del servidor). El sistema DNS es como una "agenda de contactos" de internet: traduce el nombre de dominio a la IP correspondiente. Conectar un dominio comprado (en Squarespace, Namecheap, GoDaddy, etc.) con un servicio de hosting (como Vercel) se hace mediante registros DNS tipo `CNAME` o `A`, que apuntan el dominio hacia los servidores de ese hosting.

### 2.4 HTTPS y certificados SSL
HTTPS cifra la comunicación entre el navegador del usuario y el servidor, evitando que terceros intercepten datos sensibles (contraseñas, datos de pago). Servicios modernos como Netlify/Vercel **generan certificados SSL automáticamente y gratis** para cualquier dominio conectado, así que rara vez hay que configurarlo manualmente hoy en día — pero es importante entender qué es y por qué un sitio con candado verde es más confiable que uno sin él.

---

## 3. Desplegar proyectos estáticos (HTML/CSS/JS y Vue)

### 3.1 Despliegue con Netlify (arrastrar y soltar)
La forma más simple para un proyecto sin build (HTML/CSS/JS puro): se arrastra la carpeta del proyecto directamente a la interfaz web de Netlify, y en segundos genera una URL pública. Útil para proyectos simples, pero no escala bien a flujos de trabajo en equipo.

### 3.2 Despliegue conectado a GitHub (recomendado, flujo profesional)
1. Subir el proyecto a un repositorio de GitHub (sección 1.4).
2. Conectar ese repositorio desde Netlify o Vercel.
3. Configurar el **comando de build** (para proyectos Vue con Vite, normalmente `npm run build`) y la **carpeta de salida** (normalmente `dist`).
4. Cada vez que se haga `git push` a la rama principal, el servicio **redeploya automáticamente** la nueva versión — esto se llama **CI/CD** (Integración Continua / Despliegue Continuo).

### 3.3 ¿Qué es exactamente el "build" de un proyecto Vue?
Cuando desarrollas con Vite + Vue, el código que escribes (`.vue`, módulos ES, etc.) **no es directamente lo que el navegador entiende de forma óptima**. El comando `npm run build` toma todo ese código fuente y lo:
- **Transpila**: convierte sintaxis moderna a una compatible con más navegadores.
- **Empaqueta (bundles)**: une muchos archivos pequeños en pocos archivos optimizados, reduciendo el número de peticiones que el navegador debe hacer.
- **Minifica**: elimina espacios, comentarios y acorta nombres de variables internas, reduciendo el peso del archivo final.

El resultado son archivos estáticos optimizados (HTML/CSS/JS) en una carpeta `dist/`, que es justamente lo que se sube al hosting — por eso un sitio estático puede alojar incluso una app Vue compleja, sin necesidad de un servidor que "entienda" Vue.

### 3.4 Variables de entorno
Datos sensibles o que cambian entre ambientes (claves de API, URLs de backend) **nunca se escriben directamente en el código**. Se definen como variables de entorno:

```
# archivo .env (NUNCA se sube a Git, debe estar en .gitignore)
VITE_API_URL=https://api.miapp.com
VITE_API_KEY=abc123
```
```js
// uso en el código
const url = import.meta.env.VITE_API_URL;
```
En el panel de Netlify/Vercel se configuran las mismas variables para el ambiente de producción, de forma separada del código fuente — así, si cambias de API o necesitas rotar una clave, no hace falta modificar ni redesplegar el código, solo la configuración.

---

## 4. Desplegar aplicaciones con backend (Node-RED)

### 4.1 Opciones de despliegue para Node-RED
- **Hardware propio** (Raspberry Pi, EDATEC ED-IPC1200): instalación directa en el dispositivo, ideal cuando Node-RED necesita interactuar con sensores/GPIO físicos — es el caso típico de Denki.
- **Servicios en la nube** (Render, Railway, una VPS en DigitalOcean/AWS): cuando Node-RED actúa más como un backend de procesamiento/dashboard sin necesidad de hardware físico directamente conectado.

### 4.2 Mantener Node-RED corriendo permanentemente
Un proceso de Node.js (incluido Node-RED) se detiene si cierras la terminal donde lo iniciaste, o si el dispositivo se reinicia. Para producción, se necesita un **gestor de procesos**:

```bash
npm install -g pm2
pm2 start node-red
pm2 save                # guarda la lista de procesos para que sobrevivan a reinicios
pm2 startup              # configura pm2 para iniciar automáticamente al encender el dispositivo
```
`pm2` reinicia automáticamente el proceso si llegara a fallar, y permite ver logs (`pm2 logs`) y el estado (`pm2 status`) de la aplicación en producción.

Alternativa más robusta en Linux: configurar Node-RED como **servicio systemd**, que se integra directamente con el sistema operativo para arrancar automáticamente al iniciar el equipo, sin depender de una herramienta externa como pm2.

### 4.3 Exponer Node-RED a internet de forma segura
Por defecto, Node-RED corre en `localhost:1880`, accesible solo desde la misma red. Para acceso remoto seguro:
- Configurar **autenticación** en `settings.js` (usuario/contraseña, o tokens), para que el editor no quede abierto públicamente sin protección.
- Usar un **reverse proxy** (como Nginx) delante de Node-RED, que además puede agregar HTTPS.
- Considerar una **VPN** o túneles seguros si el dispositivo está en una red industrial privada y no se quiere exponer directamente a internet.

---

## 5. Monitoreo y mantenimiento básico en producción

- **Logs**: revisar regularmente los registros de errores (en Netlify/Vercel hay un panel de "Deploys" con logs de build; en Node-RED, `pm2 logs` o el panel de depuración).
- **Lighthouse** (herramienta integrada en Chrome DevTools): audita rendimiento, accesibilidad, buenas prácticas y SEO de un sitio desplegado, dando una puntuación de 0-100 en cada categoría.
- **Manejo de errores en producción**: a diferencia del entorno de desarrollo (donde ves los errores en la consola del navegador), en producción es buena práctica capturar errores de forma silenciosa para el usuario pero registrarlos en algún lugar (incluso un simple `console.error` ya ayuda durante las primeras semanas de un proyecto pequeño).

> Esto cubre el monitoreo mínimo de un sitio desplegado. Para resiliencia operativa real (reintentos, colas para no perder datos, health checks, backups, escalabilidad) ver el **Bloque 11 — Resiliencia, Observabilidad y Escalabilidad**, pensado específicamente para cuando Denki pase de "demo desplegada" a "producto operando con clientes reales".

---

## Ejercicios del Bloque 07

### Ejercicio 5.1 — Primer repositorio y commits
Crea un repositorio Git para uno de tus proyectos ya hechos (por ejemplo, la landing page de la Semana 1). Realiza al menos 5 commits separados y descriptivos (no uno solo gigante), simulando cómo se vería el progreso real del proyecto. Sube el repositorio a GitHub.

**Qué validar:** `git log` debe mostrar 5+ commits con mensajes claros; el repo debe ser visible públicamente en tu perfil de GitHub.

### Ejercicio 5.2 — .gitignore correcto
Para un proyecto Vue creado con Vite, identifica qué carpetas/archivos NO deberían subirse a GitHub y crea el `.gitignore` correspondiente. Verifica con `git status` que esos archivos no aparezcan como "para confirmar".

**Respuesta esperada:**
```
node_modules/
dist/
.env
.DS_Store
```

### Ejercicio 5.3 — Despliegue de un sitio estático
Despliega la Landing Page (Proyecto #1) en Netlify o Vercel, conectado directamente a tu repositorio de GitHub (no por arrastrar y soltar). Haz un cambio pequeño en el código (por ejemplo, cambiar un texto), haz `git push`, y verifica que el sitio se actualice automáticamente sin que tengas que hacer nada manual en el panel de Netlify/Vercel.

**Qué validar:** el sitio tiene una URL pública funcionando; el redeploy automático ocurre en menos de 2-3 minutos después del `push`.

### Ejercicio 5.4 — Build de un proyecto Vue
Toma el proyecto e-commerce (Proyecto #5) migrado a Vite + Vue, corre `npm run build` localmente, e inspecciona la carpeta `dist/` generada. Compara el tamaño total del código fuente original contra el tamaño de los archivos en `dist/`.

**Qué validar:** entender qué archivos se generan (`index.html`, archivos `.js`/`.css` con nombres "hasheados" como `index-a1b2c3.js`) y por qué tienen esos nombres (sirven para forzar que el navegador descargue la versión nueva cuando el contenido cambia, evitando problemas de caché).

### Ejercicio 5.5 — Variables de entorno
Modifica el proyecto del Dashboard de API (Proyecto #4) para que la URL base de la API no esté escrita directamente en el código, sino que venga de una variable de entorno (`VITE_API_URL`). Configura esa misma variable en el panel de Vercel/Netlify para el ambiente de producción.

**Qué validar:** el proyecto funciona igual en local (con un archivo `.env` local) y en producción (con la variable configurada en el panel del hosting), sin que la URL esté hardcodeada en ningún archivo subido a Git.

### Ejercicio 5.6 — Dominio personalizado (opcional, si se cuenta con uno)
Conecta un dominio propio (o subdominio gratuito) al portafolio personal (Proyecto #2) desplegado en Netlify/Vercel, configurando los registros DNS correspondientes.

**Qué validar:** el sitio carga correctamente con el dominio personalizado y con HTTPS activo (candado verde en el navegador).

### Ejercicio 5.7 — Auditoría con Lighthouse
Corre una auditoría de Lighthouse sobre tu portafolio personal ya desplegado. Identifica al menos 3 mejoras sugeridas (por ejemplo, optimizar imágenes, agregar `alt` faltantes, mejorar contraste de colores) y aplícalas.

**Qué validar:** la puntuación de rendimiento y accesibilidad mejora después de aplicar los cambios; documenta el "antes y después" con capturas de pantalla — esto es un excelente punto a mencionar en una entrevista técnica.

### Ejercicio 5.8 — Despliegue de Node-RED con pm2
En una Raspberry Pi (o cualquier máquina Linux disponible), instala Node-RED, configúralo para correr con `pm2`, y verifica que sobrevive a un reinicio del dispositivo (`pm2 save` + `pm2 startup`).

**Qué validar:** después de reiniciar la máquina, Node-RED debe estar accesible de nuevo en `http://<ip>:1880` sin que tengas que iniciarlo manualmente.

### Ejercicio 5.9 — Flujo completo con ramas y Pull Request
Para el proyecto e-commerce, crea una rama nueva (`feature/codigo-descuento`), implementa el ejercicio de extensión del código de descuento (visto en el Bloque 03), súbela a GitHub, y abre un Pull Request hacia `main` describiendo el cambio. Luego haz el `merge`.

**Qué validar:** el Pull Request en GitHub muestra claramente el diff (las líneas agregadas/eliminadas) y tiene una descripción profesional del cambio — practica directa de cómo se trabaja en equipos de desarrollo reales.

---

## Proyecto integrador del Bloque 07: "Checklist de producción"

Toma **uno de tus proyectos existentes** (preferentemente el e-commerce o el panel IoT) y llévalo a un estado de "listo para producción", documentando el proceso en el README del repositorio:

- [ ] Repositorio en GitHub con historial de commits descriptivo.
- [ ] `.gitignore` correcto (sin archivos sensibles ni carpetas innecesarias subidas).
- [ ] Desplegado con URL pública, conectado a GitHub (redeploy automático).
- [ ] Variables de entorno usadas para cualquier configuración sensible o cambiante.
- [ ] HTTPS activo.
- [ ] Auditoría de Lighthouse corrida, con puntuación de rendimiento y accesibilidad documentada.
- [ ] README actualizado con: URL en vivo, capturas de pantalla, stack técnico, instrucciones de instalación local.

Este checklist, aplicado a tu proyecto insignia, es exactamente lo que un entrevistador técnico revisa cuando dice "mándame el link de tu proyecto" — y es lo que separa un proyecto de práctica de un proyecto de portafolio real.
