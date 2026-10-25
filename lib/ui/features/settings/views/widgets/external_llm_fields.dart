import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/llm_provider.dart';
import '../../../../../core/widgets/labeled_field.dart';
import '../../controller/settings_controller.dart';

/// Clave de API, versión v1 o v3 y URL base de un proveedor externo.
class ExternalLlmFields extends StatelessWidget {
  final String provider;
  final bool showAdvanced;

  const ExternalLlmFields({
    super.key,
    required this.provider,
    this.showAdvanced = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final settings = controller.settings.settings.value;
      final version = settings.apiVersionFor(provider);
      final selectedVersion =
          LlmProvider.apiVersions.contains(version) ? version : LlmProvider.v1;
      final urlCtrl = switch (provider) {
        LlmProvider.hive => controller.hiveUrlCtrl,
        LlmProvider.openai => controller.openaiUrlCtrl,
        LlmProvider.claude => controller.claudeUrlCtrl,
        _ => controller.deepseekUrlCtrl,
      };
      final keyCtrl = switch (provider) {
        LlmProvider.hive => controller.hiveKeyCtrl,
        LlmProvider.openai => controller.openaiKeyCtrl,
        LlmProvider.claude => controller.claudeKeyCtrl,
        _ => controller.deepseekKeyCtrl,
      };
      final hidden = switch (provider) {
        LlmProvider.hive => controller.hideHiveKey.value,
        LlmProvider.openai => controller.hideOpenaiKey.value,
        LlmProvider.claude => controller.hideClaudeKey.value,
        _ => controller.hideDeepseekKey.value,
      };
      final testing = controller.testing.value &&
          settings.llmProvider == provider;
      final void Function(Set<String>) onVersionSelected = switch (provider) {
        LlmProvider.hive => controller.onHiveVersionSelected,
        LlmProvider.openai => controller.onOpenaiVersionSelected,
        LlmProvider.claude => controller.onClaudeVersionSelected,
        _ => controller.onDeepseekVersionSelected,
      };
      final void Function() onTest = switch (provider) {
        LlmProvider.hive => controller.onTestHive,
        LlmProvider.openai => controller.onTestOpenai,
        LlmProvider.claude => controller.onTestClaude,
        _ => controller.onTestDeepseek,
      };
      final void Function() onToggleKey = switch (provider) {
        LlmProvider.hive => controller.toggleHiveKeyVisibility,
        LlmProvider.openai => controller.toggleOpenaiKeyVisibility,
        LlmProvider.claude => controller.toggleClaudeKeyVisibility,
        _ => controller.toggleDeepseekKeyVisibility,
      };
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledField(
            label: 'Clave de API de ${LlmProvider.label(provider)}',
            child: TextField(
              key: ValueKey('llm-key-$provider'),
              controller: keyCtrl,
              obscureText: hidden,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: 'Pega aquí la clave',
                suffixIcon: IconButton(
                  tooltip: hidden ? 'Mostrar clave' : 'Ocultar clave',
                  onPressed: onToggleKey,
                  icon: Icon(
                    hidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          LabeledField(
            label: 'Versión de la API',
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: LlmProvider.v1, label: Text('v1')),
                ButtonSegment(value: LlmProvider.v3, label: Text('v3')),
              ],
              selected: {selectedVersion},
              onSelectionChanged: onVersionSelected,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final button = FilledButton.icon(
                onPressed: testing ? null : onTest,
                icon: testing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_tethering, size: 17),
                label: Text(showAdvanced ? 'Probar conexión' : 'Probar'),
              );
              final field = LabeledField(
                label: 'URL base',
                child: TextField(
                  key: ValueKey('llm-url-$provider'),
                  controller: urlCtrl,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    hintText:
                        LlmProvider.presetBaseUrl(provider, selectedVersion),
                  ),
                ),
              );
              if (constraints.maxWidth < 520) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    field,
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerLeft, child: button),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: field),
                  const SizedBox(width: 12),
                  button,
                ],
              );
            },
          ),
          if (showAdvanced) ...[
            const SizedBox(height: 8),
            Text(
              LlmProvider.helper(provider),
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
            if (kIsWeb) ...[
              const SizedBox(height: 4),
              Text(
                'En el navegador, el dominio documentado se envía por el servidor de la app. '
                'Si cambias el dominio, el navegador puede bloquear la petición.',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 14),
            if (settings.llmProvider == provider)
              LabeledField(
                label: 'Modelo personalizado',
                helper:
                    'Úsalo si el catálogo no incluye el identificador de tu modelo.',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.customModelCtrl,
                        decoration: InputDecoration(
                          hintText: LlmProvider.modelHint(provider),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: controller.useCustomModel,
                      child: const Text('Usar'),
                    ),
                  ],
                ),
              ),
          ],
        ],
      );
    });
  }
}
