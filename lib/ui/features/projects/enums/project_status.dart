import 'package:flutter/material.dart';

enum ProjectStatus {
  idea,
  writing,
  review,
  ready,
  published;

  String get label => switch (this) {
        ProjectStatus.idea => 'Idea',
        ProjectStatus.writing => 'Escribiendo',
        ProjectStatus.review => 'En revisión',
        ProjectStatus.ready => 'Listo',
        ProjectStatus.published => 'Publicado',
      };

  Color get color => switch (this) {
        ProjectStatus.idea => const Color(0xFF8A8F98),
        ProjectStatus.writing => const Color(0xFF5E6AD2),
        ProjectStatus.review => const Color(0xFFD2A65E),
        ProjectStatus.ready => const Color(0xFF4CA970),
        ProjectStatus.published => const Color(0xFF9B5ED2),
      };
}
