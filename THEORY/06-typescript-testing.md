# Teoría Detallada — Bloque 06: TypeScript y Testing (Semana 10 en el plan Denki)

Este bloque cierra dos huecos identificados frente a vacantes júnior reales: **TypeScript** (cada vez más pedido junto a Vue) y **testing automatizado** (esperado incluso a nivel básico). Se ubica después del Bloque 03 (Vue) y antes del Bloque 07 (Despliegue), ya que requiere una base sólida de JS y Vue para tener sentido práctico.

---

## PARTE 1 — TypeScript

### 1.1 ¿Qué problema resuelve TypeScript?

JavaScript es un lenguaje de **tipado dinámico**: una variable puede contener un número y luego, sin ningún error, contener un texto. Esto da flexibilidad, pero también permite errores que solo se descubren **en tiempo de ejecución** (cuando el usuario ya está usando la app), no antes.

```js
function calcularTotal(precio, cantidad) {
  return precio * cantidad;
}

calcularTotal(100, "3"); // JS no avisa nada raro, pero "3" es texto, no número
calcularTotal(100);       // cantidad es undefined, el resultado es NaN, y JS tampoco avisa
```

TypeScript es un **superset de JavaScript** (todo código JS válido también es código TS válido) que agrega un sistema de tipos. El código TypeScript se "compila" (transpila) a JavaScript normal antes de ejecutarse, pero durante el desarrollo, el editor te avisa de errores de tipo **antes** de ejecutar el código, no después.

```ts
function calcularTotal(precio: number, cantidad: number): number {
  return precio * cantidad;
}

calcularTotal(100, "3"); // ERROR detectado en el editor, antes de correr el código:
                           // "Argument of type 'string' is not assignable to parameter of type 'number'"
```

### 1.2 Tipos básicos

```ts
let nombre: string = "Kiki";
let edad: number = 30;
let activo: boolean = true;
let etiquetas: string[] = ["sensor", "iot"];           // array de strings
let coordenadas: [number, number] = [20.6, -103.3];      // tupla: array de longitud y tipos fijos

// any: desactiva el chequeo de tipos para esa variable (usar lo MENOS posible, es "escape hatch")
let cualquierCosa: any = "puede ser lo que sea";

// unknown: similar a any, pero obliga a verificar el tipo antes de usarlo (más seguro)
let datoDesconocido: unknown = obtenerDatoExterno();
```

### 1.3 Interfaces y types: describir la forma de un objeto

```ts
interface Producto {
  id: number;
  nombre: string;
  precio: number;
  categoria: string;
  enStock?: boolean; // el "?" indica que esta propiedad es OPCIONAL
}

const sensor: Producto = {
  id: 1,
  nombre: "BMP280",
  precio: 120,
  categoria: "Sensores"
  // enStock no es obligatorio porque es opcional
};
```

`interface` (o `type`, su alternativa muy similar) describe **la forma** que debe tener un objeto: qué propiedades tiene, de qué tipo es cada una, y cuáles son opcionales. Si en algún punto del código intentas crear un `Producto` sin `nombre`, o con `precio` como texto, TypeScript marca el error inmediatamente.

```ts
type Estado = "normal" | "advertencia" | "critico"; // union type: SOLO puede ser uno de estos 3 valores exactos

function clasificarLectura(valor: number): Estado {
  if (valor > 80) return "critico";
  if (valor > 50) return "advertencia";
  return "normal";
}
```

Los **union types** (`"normal" | "advertencia" | "critico"`) son extremadamente útiles en proyectos IoT como Denki: en vez de aceptar cualquier string para el estado de un sensor (con riesgo de errores de tipeo como `"normall"`), TypeScript garantiza que solo se puedan usar esos 3 valores exactos en todo el proyecto.

### 1.4 Tipado de funciones y arrays de objetos

```ts
interface LecturaSensor {
  sensorId: string;
  valor: number;
  timestamp: string;
}

function calcularPromedio(lecturas: LecturaSensor[]): number {
  const suma = lecturas.reduce((acc, l) => acc + l.valor, 0);
  return suma / lecturas.length;
}
```
Al tipar el parámetro como `LecturaSensor[]`, el editor sabe exactamente qué propiedades tiene cada `l` dentro del `.reduce()`, ofreciendo autocompletado y detectando errores como `l.valorr` (typo) antes de ejecutar nada.

### 1.5 TypeScript en componentes Vue

```vue
<script setup lang="ts">
import { ref, computed } from 'vue';

interface Producto {
  id: number;
  nombre: string;
  precio: number;
}

const productos = ref<Producto[]>([]);
const busqueda = ref<string>("");

const productosFiltrados = computed<Producto[]>(() => {
  return productos.value.filter(p =>
    p.nombre.toLowerCase().includes(busqueda.value.toLowerCase())
  );
});

function agregarProducto(producto: Producto): void {
  productos.value.push(producto);
}
</script>
```

`<script setup lang="ts">` activa TypeScript dentro de un componente Vue, usando la **Composition API** (`ref`, `computed`) en vez de la Options API (`data()`, `computed: {}`) vista en bloques anteriores — la Composition API es el estándar actual en proyectos Vue + TypeScript, y vale la pena dominarla porque es lo que se encuentra en la mayoría de ofertas de empleo recientes.

```ts
// props tipadas con TypeScript
defineProps<{
  producto: Producto;
}>();

// eventos tipados
const emit = defineEmits<{
  agregar: [producto: Producto];
}>();
```

### 1.6 Migrar un proyecto existente a TypeScript

```bash
npm create vite@latest mi-tienda -- --template vue-ts
```
Para un proyecto ya existente en JavaScript, la migración se hace gradualmente: renombrar archivos `.js`/`.vue` a usar `lang="ts"`, agregar tipos a las interfaces de datos principales (como `Producto`, `LecturaSensor`), y dejar que TypeScript señale los puntos donde el código no es consistente con esos tipos.

---

## PARTE 2 — Testing (pruebas automatizadas)

### 2.1 ¿Qué es el testing y por qué importa?

Hasta ahora, para saber si tu código funciona, lo has probado **manualmente**: abres el navegador, haces clic, revisas que se vea bien. Esto funciona al principio, pero a medida que un proyecto crece, revisar manualmente cada funcionalidad cada vez que cambias algo se vuelve lento y poco confiable — es fácil olvidar revisar un caso que dejó de funcionar (esto se llama una "regresión").

El testing automatizado consiste en escribir código que **prueba tu propio código**, ejecutándose en segundos y avisando inmediatamente si algo se rompió.

### 2.2 Tipos de pruebas (pirámide de testing)

- **Pruebas unitarias (unit tests)**: prueban una función o componente aislado, sin dependencias externas. Son las más rápidas y las que más se escriben.
- **Pruebas de integración**: prueban que varias piezas funcionen bien juntas (por ejemplo, un componente que usa un store de Pinia).
- **Pruebas end-to-end (E2E)**: simulan a un usuario real usando la aplicación completa en un navegador (clic, escribir, navegar). Son las más lentas pero las más cercanas a la experiencia real.

Para un perfil júnior, lo esperado es dominar **pruebas unitarias** y tener nociones de integración; E2E es un plus, no un requisito básico.

### 2.3 Vitest: testing para proyectos Vite/Vue

```bash
npm install -D vitest
```

```ts
// utils.ts
export function calcularTotal(precio: number, cantidad: number): number {
  return precio * cantidad;
}
```

```ts
// utils.test.ts
import { describe, it, expect } from 'vitest';
import { calcularTotal } from './utils';

describe('calcularTotal', () => {
  it('multiplica precio por cantidad correctamente', () => {
    expect(calcularTotal(100, 3)).toBe(300);
  });

  it('devuelve 0 si la cantidad es 0', () => {
    expect(calcularTotal(100, 0)).toBe(0);
  });

  it('maneja precios decimales', () => {
    expect(calcularTotal(19.99, 2)).toBeCloseTo(39.98);
  });
});
```

**Anatomía de una prueba:**
- `describe`: agrupa un conjunto de pruebas relacionadas (normalmente todas las pruebas de una misma función o componente).
- `it` (o su alias `test`): define un caso de prueba individual, con una descripción clara de qué se espera.
- `expect(valorReal).toBe(valorEsperado)`: la "aserción" — compara lo que la función realmente devolvió contra lo que debería devolver. Si no coinciden, la prueba falla.

Matchers comunes de Vitest/Jest:
```ts
expect(resultado).toBe(5);                 // igualdad estricta (===)
expect(objeto).toEqual({ id: 1 });           // igualdad de contenido (para objetos/arrays)
expect(numero).toBeGreaterThan(10);
expect(texto).toContain("error");
expect(array).toHaveLength(3);
expect(funcion).toThrow();                    // verifica que una función lance un error
```

### 2.4 Probar componentes Vue con Vue Test Utils

```bash
npm install -D @vue/test-utils
```

```vue
<!-- ProductoCard.vue -->
<template>
  <div class="card">
    <h3>{{ producto.nombre }}</h3>
    <button @click="$emit('agregar', producto)">Agregar</button>
  </div>
</template>
```

```ts
// ProductoCard.test.ts
import { describe, it, expect } from 'vitest';
import { mount } from '@vue/test-utils';
import ProductoCard from './ProductoCard.vue';

describe('ProductoCard', () => {
  const producto = { id: 1, nombre: "Sensor BMP280", precio: 120 };

  it('muestra el nombre del producto', () => {
    const wrapper = mount(ProductoCard, { props: { producto } });
    expect(wrapper.text()).toContain("Sensor BMP280");
  });

  it('emite el evento "agregar" con el producto al hacer clic', async () => {
    const wrapper = mount(ProductoCard, { props: { producto } });
    await wrapper.find('button').trigger('click');
    expect(wrapper.emitted('agregar')).toBeTruthy();
    expect(wrapper.emitted('agregar')[0]).toEqual([producto]);
  });
});
```

`mount()` renderiza el componente en un entorno simulado (sin necesidad de un navegador real). `wrapper.find(...)` localiza elementos como `querySelector`. `wrapper.trigger('click')` simula la interacción del usuario. `wrapper.emitted('agregar')` verifica qué eventos emitió el componente — esto prueba exactamente el patrón "props down, events up" visto en el Bloque 03, ahora de forma automatizada.

### 2.5 ¿Qué probar y qué no probar?

**Buenas candidatas para pruebas unitarias:**
- Funciones puras de lógica de negocio (calcular totales, validar formularios, clasificar estados de sensores).
- Comportamiento de componentes ante interacción del usuario (clics, inputs) y su efecto en lo que se renderiza o emite.
- Casos límite: valores en 0, listas vacías, valores negativos, strings vacíos.

**No es prioritario para un perfil júnior:**
- Probar estilos CSS o detalles visuales exactos (eso es más propio de pruebas visuales/E2E).
- Probar librerías de terceros ya probadas (Vue mismo, Pinia) — se prueba **tu** lógica que las usa, no la librería en sí.

### 2.6 Test-Driven Development (TDD) — concepto introductorio

TDD es una metodología donde se escribe **primero la prueba** (que inicialmente falla, porque la función no existe aún) y **después** el código que la hace pasar. No es obligatorio dominarlo a nivel júnior, pero es importante poder explicarlo en una entrevista:
1. Escribir una prueba que describe el comportamiento esperado (falla, en rojo).
2. Escribir el código mínimo necesario para que la prueba pase (en verde).
3. Refactorizar el código manteniendo la prueba en verde.

### 2.7 Integración con CI (relación con el Bloque 07 de despliegue)

```yaml
# .github/workflows/test.yml
name: Tests
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm install
      - run: npm run test
```

Este archivo de **GitHub Actions** ejecuta automáticamente las pruebas cada vez que se hace `git push`, **antes** de que el código llegue a producción — si alguna prueba falla, el equipo se entera inmediatamente, sin tener que esperar a que un usuario reporte el bug. Esto conecta directamente con el Bloque 07 (CI/CD): un pipeline de producción serio no solo despliega automáticamente, también **prueba** automáticamente antes de desplegar.

---

## Ejercicios del Bloque 06

### Ejercicio 6.1 — Tipar el modelo de datos del e-commerce
Define interfaces de TypeScript para `Producto`, `ItemCarrito` (que extiende `Producto` con una propiedad `cantidad`) y `Cliente` (nombre, correo, dirección), y úsalas en el store de Pinia del carrito.

### Ejercicio 6.2 — Tipar funciones puras
Convierte a TypeScript las funciones de cálculo del e-commerce (`calcularSubtotal`, `calcularEnvio`, `calcularTotal`), tipando explícitamente parámetros y valores de retorno.

### Ejercicio 6.3 — Union type para estados de sensor
Para el proyecto de Node-RED/IoT, define un tipo `EstadoSensor = "normal" | "advertencia" | "critico"` y una función `clasificarLectura(valor: number): EstadoSensor`, aplicando lo visto en la sección 1.3.

### Ejercicio 6.4 — Primeras pruebas unitarias
Escribe pruebas con Vitest para las funciones de cálculo del Ejercicio 6.2, cubriendo al menos: caso normal, carrito vacío (cantidad 0), y el umbral exacto del envío gratis.

### Ejercicio 6.5 — Probar un componente con interacción
Escribe una prueba con Vue Test Utils para el componente `CarritoItem` (Bloque 03), verificando que al hacer clic en "+" se emite el evento `incrementar`, y que al hacer clic en "-" cuando la cantidad es 1, se emite `eliminar` en vez de `decrementar` (replicando la lógica vista en el proyecto e-commerce).

### Ejercicio 6.6 — Pipeline de CI
Configura un workflow de GitHub Actions que corra `npm run test` automáticamente en cada `push`, y verifica en la pestaña "Actions" de GitHub que las pruebas se ejecutan y pasan (o fallan intencionalmente, para confirmar que el pipeline sí detecta errores).

---

## Cómo se conecta este bloque con el portafolio

Agregar TypeScript y pruebas automatizadas al proyecto e-commerce (#5) y, si el tiempo lo permite, al panel IoT (#6), es uno de los puntos de mayor impacto que puedes mencionar en una entrevista: pasa de "construí una app que funciona" a **"construí una app tipada, con pruebas automatizadas que corren en cada cambio antes de desplegar"** — esa frase, respaldada por código real en GitHub, es exactamente lo que diferencia un candidato júnior "completo" del promedio.
