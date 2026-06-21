import 'package:flutter/material.dart';

import '../../enums/project_status.dart';
import 'kanban_column.dart';

class KanbanBoardView extends StatefulWidget {
  const KanbanBoardView({super.key});

  @override
  State<KanbanBoardView> createState() => _KanbanBoardViewState();
}

class _KanbanBoardViewState extends State<KanbanBoardView> {
  var _isDragging = false;

  void _onDragStarted() => setState(() => _isDragging = true);

  void _onDragEnded() => setState(() => _isDragging = false);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: _isDragging
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final status in ProjectStatus.values)
            SizedBox(
              height: MediaQuery.sizeOf(context).height - 220,
              child: KanbanColumn(
                status: status,
                onDragStarted: _onDragStarted,
                onDragEnded: _onDragEnded,
              ),
            ),
        ],
      ),
    );
  }
}
