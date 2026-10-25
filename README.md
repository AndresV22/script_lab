# Script Lab

Aplicación web (Flutter) para que creadores de contenido de YouTube planifiquen, escriban y perfeccionen sus guiones desde una sola plataforma. La inteligencia artificial puede ser **local** con [Ollama](https://ollama.com) o un proveedor externo: DeepSeek, The Hive, OpenAI o Claude.

- Todo el proceso creativo en una sola aplicación.
- IA local con Ollama, o una API externa con tu propia clave.
- Enfoque en productividad, organización y privacidad de los guiones.
- Los datos, incluidas las claves de API, se guardan en tu navegador (IndexedDB vía Hive) y forman parte del respaldo JSON.

## Funcionalidades

### Núcleo (desde 0.1.0)

- **Proyectos**: cada video es un proyecto con tema, estado, fecha estimada de lanzamiento, título tentativo y alternativas, miniaturas (principal + alternativas), descripción, etiquetas y notas.
- **Editor de guiones**: secciones reordenables, plegables y editables de forma independiente, con conteo de palabras y duración estimada en vivo.
- **Estructuras**: plantillas reutilizables de secciones; crear, editar, duplicar, exportar/importar JSON y aplicar a un proyecto.
- **Asistente de IA** (con el contexto del proyecto): corrección, análisis (contradicciones, repeticiones, secciones débiles), sugerencias (títulos, miniaturas, hooks, descripción), generación parcial y de guion completo, con respuesta en streaming.
- **Variables del canal**: nombre, saludo, público, estilo, qué evitar y duración promedio; la IA las usa automáticamente.
- **Biblioteca de prompts** reutilizables.
- **Historial de versiones**: guardar, restaurar y comparar.
- **Comparador IA vs original**: diferencias resaltadas, aceptar/rechazar todo o cambios individuales.
- **Entrenamiento de estilo**: importa transcripciones TXT/Markdown y la IA imitará tu forma de escribir.
- **Estadísticas**: palabras, caracteres, duración estimada de narración y secciones.
- **Exportación**: TXT, Markdown, PDF y JSON.
- **Búsqueda global** (⌘K / Ctrl+K), **autoguardado** y **tema claro/oscuro**.

### Desde 0.2.0

- **Dashboard (Inicio)**: pantalla principal con estadísticas globales, carrusel de sugerencias de IA, consejos contextuales, acceso rápido al proveedor de IA, respaldo JSON, proyectos recientes, gráfico de estados y rankings de estructuras y prompts.
- **Sugerencias**: sección dedicada que propone ideas de proyectos, estructuras y prompts a partir de tus guiones; generación por categoría (5 en 5), **Sugerir de todo** (3 de cada una), aplicar o descartar, y **Limpiar todo**.
- **Estructuras con IA**: genera plantillas de secciones desde la vista Estructuras.
- **Notas Markdown**: editor con vista previa en la pestaña Información del proyecto.
- **Panel de IA**: categorías organizadas en secciones desplegables.
- **Lista de proyectos**: tres modos de vista (Lista, Kanban y Calendario); cambio de estado con un clic; menú contextual reducido a eliminar.
- **Respaldo completo**: exportar e importar todos los datos (incluidas sugerencias) en un único JSON.
- **Docker**: ejecutar la app y Ollama en local con Docker Compose.

### Desde 0.3.0

- **Tablero Kanban**: pestaña en Proyectos con columnas por estado (Idea → Publicado); arrastra tarjetas entre columnas para cambiar el estado al instante.
- **Calendario de lanzamientos**: visualiza proyectos según su fecha estimada de publicación; arrastra entre días para reprogramar o al panel **Sin programar** para quitar la fecha.
- **Fecha estimada de lanzamiento**: asigna y edita la fecha desde la pestaña Información de cada proyecto.
- **Tres modos de vista en Proyectos**: Lista (grid o filas), Kanban y Calendario, con la preferencia guardada automáticamente.

### Actual

- **Proveedores de IA**: Ollama, DeepSeek, The Hive, OpenAI y Claude. Cada uno muestra solo su clave, su versión de API (v1 o v3) y su URL base.
- **Generar guion completo**: en un proyecto, Asistente IA → Generación abre un paso con un prompt y una estructura. La estructura puede ser las secciones actuales del proyecto, ninguna, o una plantilla guardada. La plantilla es opcional. Si escribes un prompt, el guion se crea desde cero con ese texto; el contenido ya escrito en las secciones no se envía al modelo.

## Stack

| Capa | Tecnología |
| --- | --- |
| UI | Flutter Web + Material 3 |
| Estado | GetX (`Obx`) |
| Persistencia | Hive CE (IndexedDB en web) |
| IA | Ollama local (`/api/tags`, `/api/chat`) o chat compatible con OpenAI (DeepSeek, The Hive, OpenAI y Claude) |
| Arquitectura | Feature First (`lib/ui/features/*`) |

## Desarrollo

```bash
flutter pub get
dart run build_runner build   # regenerar adapters de Hive si cambian los modelos
flutter run -d chrome
```

## Configurar la inteligencia artificial

En **Ajustes → Inteligencia artificial** (o en el panel del inicio) elige un proveedor. Solo se muestran los campos de ese proveedor.

| Proveedor | Qué configurar | URL base inicial |
| --- | --- | --- |
| Ollama | URL del servidor | `http://localhost:11434` |
| DeepSeek | Clave de API, versión v1 o v3 y URL base | `https://api.deepseek.com/v1` |
| The Hive | Clave de API, versión v1 o v3 y URL base | `https://api-cdn.thehive.ai/api/v3` |
| OpenAI | Clave de API, versión v1 o v3 y URL base | `https://api.openai.com/v1` |
| Claude | Clave de API, versión v1 o v3 y URL base | `https://api.anthropic.com/v1` |

Pulsa **Probar conexión** y elige el modelo predeterminado. Si el servidor no lista modelos, la app carga un catálogo documentado y puedes escribir otro identificador en **Modelo personalizado**. The Hive también admite la región Virginia: `https://api-va1.thehive.ai/api/v3`.

Con la app servida por Docker, el navegador no llama a DeepSeek, The Hive, OpenAI ni Claude de forma directa: Nginx reenvía esas rutas (`/llm-proxy/...`) para evitar el bloqueo CORS. Un dominio distinto al documentado puede quedar bloqueado. En GitHub Pages ese proxy no existe.

El control **Thinking** activa el razonamiento en Ollama y lo envía como `reasoning_effort` a DeepSeek, The Hive y OpenAI. Claude razona de forma adaptativa en su API.

### Ollama

1. Instala Ollama y descarga al menos un modelo, por ejemplo:

```bash
ollama pull llama3.2
```

2. Para que el navegador pueda conectarse, Ollama debe permitir el origen de la app (CORS):

```bash
# Desarrollo local
OLLAMA_ORIGINS="*" ollama serve
```

3. Elige **Ollama**, deja la URL en `http://localhost:11434`, prueba la conexión y selecciona el modelo.

### Limitación con GitHub Pages

GitHub Pages publica la app por HTTPS y no incluye el proxy de Nginx.

- Ollama en `http://localhost:11434` queda bloqueado porque el navegador no permite una página HTTPS llamar a HTTP.
- DeepSeek, The Hive, OpenAI y Claude se envían a `/llm-proxy/...`. Esa ruta existe cuando la app corre con Docker.

Para usar un modelo, levanta la app con Docker. El sitio publicado sigue sirviendo para editar proyectos, estructuras y el resto de funciones.

Si quieres Ollama desde un origen HTTPS, exponlo detrás de un proxy HTTPS y pon esa URL en Ajustes. Lanza Ollama con `OLLAMA_ORIGINS` igual al origen de la app, o `*`.

## Docker (app + Ollama local)

Puedes levantar Script Lab y Ollama en tu máquina con Docker Compose. La app se sirve por **HTTP** en el puerto 8080 y Ollama en el 11434. Ese mismo servidor reenvía DeepSeek, The Hive, OpenAI y Claude.

Si el puerto 11434 ya lo usa un Ollama instalado en la máquina, Compose no puede arrancar. Detén ese proceso o cambia `OLLAMA_PORT` en `.env` y la URL de Ollama en Ajustes para que coincidan.

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

- Los **datos de proyectos** y las **claves de API** se guardan en el navegador (IndexedDB), no en Docker.
- Tras reconstruir la imagen, recarga la página con fuerza (Cmd+Shift+R) si Chrome sigue mostrando la versión anterior.
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
