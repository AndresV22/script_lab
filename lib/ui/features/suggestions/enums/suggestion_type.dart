import 'package:flutter/material.dart';

enum SuggestionType {
  project,
  structure,
  prompt;

  String get label => switch (this) {
        SuggestionType.project => 'Proyectos',
        SuggestionType.structure => 'Estructuras',
        SuggestionType.prompt => 'Prompts',
      };

  IconData get icon => switch (this) {
        SuggestionType.project => Icons.video_library_outlined,
        SuggestionType.structure => Icons.account_tree_outlined,
        SuggestionType.prompt => Icons.auto_awesome_outlined,
      };

  Color get color => switch (this) {
        SuggestionType.project => const Color(0xFF5E6AD2),
        SuggestionType.structure => const Color(0xFF4CA970),
        SuggestionType.prompt => const Color(0xFF9B5ED2),
      };
}
