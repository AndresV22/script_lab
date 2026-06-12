import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/ai_options.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/helpers/text_stats.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/ollama_service.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/editable_chips.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/ollama_model_dropdown.dart';
import '../../structures/services/structure_service.dart';
import '../controller/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selected: AppSection.settings,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Ajustes',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                const _OllamaCard(),
                const SizedBox(height: 16),
                const _ChannelCard(),
                const SizedBox(height: 16),
                const _ProjectDefaultsCard(),
                const SizedBox(height: 16),
                const _StyleTrainingCard(),
                const SizedBox(height: 16),
                const _AppearanceCard(),
                const SizedBox(height: 16),
                const _WritingCard(),
                const SizedBox(height: 16),
                const _BackupCard(),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SettingsCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!,
                  style: TextStyle(
                      fontSize: 12.5, color: scheme.onSurfaceVariant)),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _OllamaCard extends StatelessWidget {
  const _OllamaCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final ollama = OllamaService.to;
    return _SettingsCard(
      title: 'Inteligencia artificial (Ollama)',
      subtitle:
          'Conexión con tu servidor local de Ollama. Todo el procesamiento ocurre en tu equipo.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: LabeledField(
                  label: 'URL del servidor',
                  child: TextField(
                    controller: controller.urlCtrl,
                    decoration: const InputDecoration(
                        hintText: 'http://localhost:11434'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => FilledButton.icon(
                    onPressed: controller.testing.value
                        ? null
                        : controller.testConnection,
                    icon: controller.testing.value
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi_tethering, size: 17),
                    label: const Text('Probar conexión'),
                  )),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() {
            final status = ollama.status.value;
            final (color, label) = switch (status) {
              OllamaStatus.connected => (
                  Colors.green,
                  'Conectado · ${ollama.models.length} modelos disponibles'
                ),
              OllamaStatus.checking => (Colors.orange, 'Comprobando conexión…'),
              OllamaStatus.disconnected => (
                  Colors.red,
                  'Sin conexión: ${ollama.lastError.value.truncate(120)}'
                ),
              OllamaStatus.unknown => (Colors.grey, 'Estado desconocido'),
            };
            return Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(label, style: const TextStyle(fontSize: 13))),
              ],
            );
          }),
          const SizedBox(height: 14),
          Obx(() {
            if (ollama.models.isEmpty) return const SizedBox.shrink();
            final current = controller.settings.settings.value.defaultModel;
            return LabeledField(
              label: 'Modelo predeterminado',
              child: OllamaModelDropdown(
                value: current,
                models: ollama.models,
                onChanged: controller.setDefaultModel,
              ),
            );
          }),
          const SizedBox(height: 14),
          Obx(() {
            controller.settings.settings.value;
            final thinkMode = controller.settings.settings.value.thinkMode;
            return LabeledField(
              label: 'Thinking (razonamiento)',
              helper:
                  'Activa el razonamiento previo en modelos compatibles. '
                  'Usa «Activado» para qwen3/deepseek-r1; niveles bajo/medio/alto '
                  'para gpt-oss. Las respuestas pueden tardar más.',
              child: DropdownButtonFormField<String>(
                initialValue: AiThinkMode.values.contains(thinkMode)
                    ? thinkMode
                    : AiThinkMode.off,
                isExpanded: true,
                items: [
                  for (final mode in AiThinkMode.values)
                    DropdownMenuItem(
                      value: mode,
                      child: Text(AiThinkMode.label(mode)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) controller.setThinkMode(value);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return _SettingsCard(
      title: 'Variables del canal',
      subtitle:
          'Información permanente que la IA usará automáticamente en cada tarea.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledField(
            label: 'Nombre del canal',
            child: TextField(
              controller: controller.channelNameCtrl,
              decoration:
                  const InputDecoration(hintText: 'Ej. Relojes Altiro'),
            ),
          ),
          const SizedBox(height: 14),
          LabeledField(
            label: 'Saludo habitual',
            child: TextField(
              controller: controller.greetingCtrl,
              decoration: const InputDecoration(
                  hintText: 'Ej. Bienvenidos una vez más a Relojes Altiro.'),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: LabeledField(
                  label: 'Público objetivo',
                  child: TextField(
                    controller: controller.audienceCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Ej. Aficionados a los relojes'),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: LabeledField(
                  label: 'Duración promedio',
                  child: TextField(
                    controller: controller.durationCtrl,
                    decoration:
                        const InputDecoration(hintText: 'Ej. 10 minutos'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LabeledField(
            label: 'Estilo de escritura',
            child: TextField(
              controller: controller.styleCtrl,
              decoration:
                  const InputDecoration(hintText: 'Ej. Conversacional'),
            ),
          ),
          const SizedBox(height: 14),
          LabeledField(
            label: 'Evitar',
            child: TextField(
              controller: controller.avoidCtrl,
              decoration: const InputDecoration(
                  hintText: 'Ej. Frases demasiado formales'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectDefaultsCard extends StatelessWidget {
  const _ProjectDefaultsCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return _SettingsCard(
      title: 'Proyectos nuevos',
      subtitle:
          'Valores que se aplican automáticamente al crear un proyecto, para no repetir lo mismo cada vez.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledField(
            label: 'Descripción predeterminada',
            child: TextField(
              controller: controller.defaultDescriptionCtrl,
              minLines: 3,
              maxLines: 8,
              decoration: const InputDecoration(
                  hintText:
                      'Ej. Sígueme en redes… / enlaces fijos del canal…'),
            ),
          ),
          const SizedBox(height: 14),
          LabeledField(
            label: 'Etiquetas predeterminadas',
            child: Obx(() {
              controller.settings.projectDefaults.value;
              return EditableChips(
                values: controller.settings.projectDefaults.value.tags,
                hint: 'Añadir etiqueta predeterminada… (separa con comas)',
                onAdd: controller.addDefaultTag,
                onRemove: controller.removeDefaultTag,
                addOnComma: true,
              );
            }),
          ),
          const SizedBox(height: 14),
          LabeledField(
            label: 'Notas predeterminadas',
            child: TextField(
              controller: controller.defaultNotesCtrl,
              minLines: 2,
              maxLines: 6,
              decoration: const InputDecoration(
                  hintText: 'Ej. Checklist de grabación, recordatorios…'),
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            final structures = StructureService.to.structures;
            final current =
                controller.settings.projectDefaults.value.structureId;
            return LabeledField(
              label: 'Estructura predeterminada',
              helper: structures.isEmpty
                  ? 'Crea estructuras en la sección Estructuras para poder elegir una.'
                  : 'Sus secciones se crearán automáticamente en cada proyecto nuevo.',
              child: DropdownButtonFormField<String>(
                initialValue: structures.any((s) => s.id == current)
                    ? current
                    : '',
                isExpanded: true,
                items: [
                  const DropdownMenuItem(
                      value: '', child: Text('Ninguna')),
                  for (final structure in structures)
                    DropdownMenuItem(
                      value: structure.id,
                      child: Text(structure.name,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                    ),
                ],
                onChanged: structures.isEmpty
                    ? null
                    : controller.setDefaultStructure,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StyleTrainingCard extends StatelessWidget {
  const _StyleTrainingCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final scheme = Theme.of(context).colorScheme;
    return _SettingsCard(
      title: 'Entrenamiento del estilo',
      subtitle:
          'Importa transcripciones de tus videos (TXT o Markdown). La IA las usará como referencia para imitar tu forma de escribir.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            final samples = controller.settings.styleSamples;
            if (samples.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Aún no has importado transcripciones.',
                  style: TextStyle(
                      fontSize: 13, color: scheme.onSurfaceVariant),
                ),
              );
            }
            return Column(
              children: [
                for (final sample in samples)
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 6),
                    dense: true,
                    leading: Icon(Icons.description_outlined,
                        size: 18, color: scheme.onSurfaceVariant),
                    title: Text(sample.name,
                        style: const TextStyle(fontSize: 13.5)),
                    subtitle: Text(
                      '${TextStats.words(sample.content)} palabras · importado ${sample.importedAt.relative}',
                      style: TextStyle(
                          fontSize: 11.5, color: scheme.onSurfaceVariant),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      tooltip: 'Eliminar',
                      onPressed: () async {
                        final ok = await showConfirmDialog(
                          title: 'Eliminar transcripción',
                          message: 'Se eliminará "${sample.name}".',
                        );
                        if (ok) controller.deleteStyleSample(sample);
                      },
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            );
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: controller.importStyleSamples,
              icon: const Icon(Icons.upload_file_outlined, size: 17),
              label: const Text('Importar transcripciones'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    final theme = ThemeController.to;
    return _SettingsCard(
      title: 'Apariencia',
      child: Obx(() => SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('Sistema'),
                icon: Icon(Icons.brightness_auto_outlined, size: 16),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Claro'),
                icon: Icon(Icons.light_mode_outlined, size: 16),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Oscuro'),
                icon: Icon(Icons.dark_mode_outlined, size: 16),
              ),
            ],
            selected: {theme.mode.value},
            onSelectionChanged: (selection) =>
                theme.setMode(selection.first),
          )),
    );
  }
}

class _BackupCard extends StatelessWidget {
  const _BackupCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _SettingsCard(
      title: 'Datos y respaldo',
      subtitle:
          'Tus datos viven únicamente en este navegador. Exporta respaldos con regularidad para no perderlos si limpias el almacenamiento o cambias de equipo.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              FilledButton.icon(
                onPressed: BackupService.exportBackup,
                icon: const Icon(Icons.download_outlined, size: 17),
                label: const Text('Exportar respaldo'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: BackupService.importBackup,
                icon: const Icon(Icons.upload_outlined, size: 17),
                label: const Text('Importar respaldo'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'El respaldo incluye proyectos (con guiones, versiones, miniaturas y chats), estructuras, prompts, transcripciones y todos los ajustes. Al importar se reemplazan los datos actuales.',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _WritingCard extends StatelessWidget {
  const _WritingCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return _SettingsCard(
      title: 'Escritura',
      subtitle:
          'Velocidad de narración usada para estimar la duración de los guiones.',
      child: Obx(() {
        final wpm = controller.settings.settings.value.wordsPerMinute;
        return Row(
          children: [
            Expanded(
              child: Slider(
                value: wpm.toDouble(),
                min: 90,
                max: 200,
                divisions: 22,
                label: '$wpm ppm',
                onChanged: (v) =>
                    controller.setWordsPerMinute(v.round()),
              ),
            ),
            SizedBox(
              width: 130,
              child: Text('$wpm palabras/min',
                  style: const TextStyle(fontSize: 13)),
            ),
          ],
        );
      }),
    );
  }
}
