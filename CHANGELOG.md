# Changelog

## 0.2.0

### Dashboard (Inicio)

- Nueva pantalla de inicio como ruta principal (`/`): resumen del espacio de trabajo con estadísticas globales, accesos rápidos y paneles informativos.
- Carrusel **Ideas de la IA** con sugerencias pendientes y botón **Generar sugerencias** cuando aún no hay ninguna.
- Carrusel **Consejos** con atajos contextuales (nuevo proyecto, configurar Ollama, etc.).
- Panel de conexión a Ollama, exportar/importar respaldo JSON, proyectos recientes, gráfico de estados, rankings de estructuras y prompts.
- Selector de tema desde el pie de página del dashboard.

### Sugerencias

- Nueva sección **Sugerencias** en el menú lateral con pestañas Proyectos, Estructuras y Prompts.
- Generación por lote de 5 sugerencias por categoría, basadas en los guiones existentes.
- Botones **Sugerir de todo** (3 de cada categoría en una sola acción) y **Limpiar todo** con confirmación.
- Modelo unificado `AiSuggestion` con persistencia en Hive y migración automática desde sugerencias de proyecto legacy.
- Aplicar sugerencias: crear proyecto, abrir editor de estructura o guardar prompt en biblioteca.
- Modal de carga bloqueante durante la generación.

### Mejoras de IA y edición

- Generación de estructuras con IA desde la vista Estructuras.
- Panel lateral de IA con categorías desplegables (`ExpansionTile`).
- Notas de proyecto con editor y vista previa Markdown.
- En resultados de títulos alternativos, las acciones **Usar como tentativo** y **Añadir alternativas** cierran el diálogo al aplicarse.

### Proyectos y estructuras

- Estado del proyecto editable directamente desde la lista (`ProjectStatusPicker`); el menú contextual queda solo para eliminar.
- Corrección al crear estructura desde una sugerencia: guardado mediante servicio global y eliminación de la sugerencia solo tras guardar con éxito.

### Infraestructura

- Respaldo e importación JSON incluyen sugerencias de IA.
- Docker Compose para ejecutar la app web y Ollama localmente (`Dockerfile`, `docker-compose.yml`, `.env.example`).

## 0.1.0

Versión inicial de Script Lab.

- Sistema de proyectos: tema, estado, títulos (tentativo + alternativas), miniaturas (principal + alternativas), descripción, etiquetas y notas.
- Editor de guiones por secciones: reordenar, expandir/contraer, edición independiente y conteo de palabras/duración en vivo.
- Estructuras reutilizables: crear, editar, duplicar, exportar/importar JSON y aplicar a proyectos.
- Integración con Ollama: URL configurable, detección de estado, listado de modelos, modelo predeterminado y prueba de conexión.
- Asistente de IA con contexto del proyecto: corrección, análisis, sugerencias (títulos, miniaturas, hooks, descripción), generación parcial y completa con streaming.
- Variables reutilizables del canal y biblioteca de prompts.
- Historial de versiones con restauración y comparación.
- Comparador IA vs texto original con aceptación/rechazo de cambios individuales.
- Entrenamiento de estilo mediante transcripciones TXT/Markdown.
- Estadísticas (palabras, caracteres, narración estimada, secciones), exportación (TXT/MD/PDF/JSON), búsqueda global (⌘K), autoguardado y tema claro/oscuro.
- Workflow de despliegue a GitHub Pages.
