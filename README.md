# Script Lab

Aplicación web (Flutter) para que creadores de contenido de YouTube planifiquen, escriban y perfeccionen sus guiones desde una sola plataforma, con inteligencia artificial **local** mediante [Ollama](https://ollama.com).

- Todo el proceso creativo en una sola aplicación.
- IA local: sin suscripciones ni servicios externos.
- Enfoque en productividad, organización y privacidad.
- Los datos se guardan en tu navegador (IndexedDB vía Hive).

## Funcionalidades

### Núcleo (desde 0.1.0)

- **Proyectos**: cada video es un proyecto con tema, estado, título tentativo y alternativas, miniaturas (principal + alternativas), descripción, etiquetas y notas.
- **Editor de guiones**: secciones reordenables, plegables y editables de forma independiente, con conteo de palabras y duración estimada en vivo.
- **Estructuras**: plantillas reutilizables de secciones; crear, editar, duplicar, exportar/importar JSON y aplicar a un proyecto.
- **Asistente de IA** (con el contexto completo del proyecto): corrección, análisis (contradicciones, repeticiones, secciones débiles), sugerencias (títulos, miniaturas, hooks, descripción), generación parcial y de guion completo, con respuesta en streaming.
- **Variables del canal**: nombre, saludo, público, estilo, qué evitar y duración promedio; la IA las usa automáticamente.
- **Biblioteca de prompts** reutilizables.
- **Historial de versiones**: guardar, restaurar y comparar.
- **Comparador IA vs original**: diferencias resaltadas, aceptar/rechazar todo o cambios individuales.
- **Entrenamiento de estilo**: importa transcripciones TXT/Markdown y la IA imitará tu forma de escribir.
- **Estadísticas**: palabras, caracteres, duración estimada de narración y secciones.
- **Exportación**: TXT, Markdown, PDF y JSON.
- **Búsqueda global** (⌘K / Ctrl+K), **autoguardado** y **tema claro/oscuro**.

### Desde 0.2.0

- **Dashboard (Inicio)**: pantalla principal con estadísticas globales, carrusel de sugerencias de IA, consejos contextuales, acceso rápido a Ollama, respaldo JSON, proyectos recientes, gráfico de estados y rankings de estructuras y prompts.
- **Sugerencias**: sección dedicada que propone ideas de proyectos, estructuras y prompts a partir de tus guiones; generación por categoría (5 en 5), **Sugerir de todo** (3 de cada una), aplicar o descartar, y **Limpiar todo**.
- **Estructuras con IA**: genera plantillas de secciones desde la vista Estructuras.
- **Notas Markdown**: editor con vista previa en la pestaña Información del proyecto.
- **Panel de IA**: categorías organizadas en secciones desplegables.
- **Lista de proyectos**: cambio de estado con un clic; menú contextual reducido a eliminar.
- **Respaldo completo**: exportar e importar todos los datos (incluidas sugerencias) en un único JSON.
- **Docker**: ejecutar la app y Ollama en local con Docker Compose.

## Stack

| Capa | Tecnología |
| --- | --- |
| UI | Flutter Web + Material 3 |
| Estado | GetX (`Obx`) |
| Persistencia | Hive CE (IndexedDB en web) |
| IA | Ollama local vía HTTP (`/api/tags`, `/api/chat` streaming) |
| Arquitectura | Feature First (`lib/ui/features/*`) |

## Desarrollo

```bash
flutter pub get
dart run build_runner build   # regenerar adapters de Hive si cambian los modelos
flutter run -d chrome
```

## Configurar Ollama

1. Instala Ollama y descarga al menos un modelo, por ejemplo:

```bash
ollama pull llama3.2
```

2. Para que el navegador pueda conectarse, Ollama debe permitir el origen de la app (CORS):

```bash
# Desarrollo local
OLLAMA_ORIGINS="*" ollama serve
```

3. En **Ajustes → Inteligencia artificial**, configura la URL (por defecto `http://localhost:11434`), prueba la conexión y elige el modelo predeterminado.

### Limitación importante con GitHub Pages (HTTPS)

GitHub Pages sirve la app por **HTTPS**, mientras que Ollama escucha en **HTTP** (`http://localhost:11434`). Los navegadores bloquean las peticiones HTTPS → HTTP (*mixed content*), por lo que en la versión publicada la IA puede no conectarse directamente. Opciones:

- **Recomendado**: ejecutar la app en local (`flutter run -d chrome`, Docker o servir `build/web`); el resto de funciones de la versión de GitHub Pages funcionan sin Ollama.
- Exponer Ollama detrás de un proxy/túnel HTTPS local (por ejemplo Caddy, nginx o un túnel) y usar esa URL en Ajustes.
- En algunos navegadores se puede permitir contenido inseguro para el sitio (configuración del sitio → "Insecure content" → Allow).

En todos los casos, recuerda lanzar Ollama con `OLLAMA_ORIGINS` incluyendo el origen de la app (o `*`).

## Docker (app + Ollama local)

Puedes levantar Script Lab y Ollama en tu máquina con Docker Compose. La app se sirve por **HTTP** en el puerto 8080 y Ollama en el 11434, así el navegador puede conectarse sin problemas de mixed content.

### Requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (o Docker Engine + Compose v2)

### Primer arranque

```bash
cp .env.example .env          # opcional: personaliza puertos y modelos
docker compose up -d --build
docker compose --profile setup run --rm ollama-models
```

Abre **http://localhost:8080**. En **Ajustes → Inteligencia artificial**, la URL por defecto `http://localhost:11434` debería funcionar tras pulsar **Probar**.

### Comandos útiles

```bash
docker compose up -d --build    # reconstruir y levantar
docker compose logs -f ollama   # ver logs de Ollama
docker compose down             # parar contenedores
docker compose down -v          # parar y borrar modelos descargados
```

### Descargar más modelos

Edita `OLLAMA_MODELS` en `.env` o ejecuta directamente:

```bash
docker exec -it script-lab-ollama ollama pull mistral
```

### Modelos cloud vs locales

| Tipo | Ejemplo | Requisito |
| --- | --- | --- |
| **Local** | `llama3.2`, `qwen2.5:3b` | Solo descargar con `ollama pull` |
| **Cloud** | `gpt-oss:20b-cloud` | Cuenta en [ollama.com](https://ollama.com) + `ollama signin` |

Si usas modelos **`*-cloud`**, el listado (`/api/tags`) funciona pero el chat devuelve **401 Unauthorized** hasta autenticarte:

```bash
docker exec -it script-lab-ollama ollama signin
```

Sigue el enlace en el terminal, inicia sesión en ollama.com y vuelve a probar en la app.

Para Docker sin cuenta cloud, usa modelos locales en `.env`:

```bash
OLLAMA_MODELS=llama3.2 qwen2.5:3b
docker compose --profile setup run --rm ollama-models
```

### Notas

- Los **datos de proyectos** siguen guardándose en el navegador (IndexedDB), no en Docker.
- En **Mac con Apple Silicon**, Ollama en Docker suele usar CPU; para más rendimiento puedes instalar Ollama nativo en el host y usar solo el contenedor `script-lab`.
- La primera descarga de modelos puede tardar varios minutos según tu conexión.

## Despliegue en GitHub Pages

El workflow [.github/workflows/deploy.yml](.github/workflows/deploy.yml) compila y publica automáticamente en GitHub Pages con cada push a `main` (requiere habilitar **Settings → Pages → Source: GitHub Actions** en el repositorio).

Compilación manual:

```bash
flutter build web --release --base-href "/script_lab/"
```

## Estructura del proyecto

```text
lib/
├── core/            # tema, rutas, widgets, extensiones, constantes, servicios, helpers
├── hive/            # adapters generados de Hive
└── ui/features/     # dashboard, projects, script_editor, structures, ai, prompts,
    └── <feature>/   # suggestions, settings, analytics
                     # views / controller / models / services / enums / helpers
```

## Historial de versiones

Consulta [CHANGELOG.md](CHANGELOG.md) para el detalle de cada release.
