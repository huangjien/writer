import 'package:flutter/material.dart';

import '../mobile_gestures.dart';

class LongPressMenuItem<T> {
  const LongPressMenuItem({
    required this.label,
    this.icon,
    required this.value,
    this.isDestructive = false,
  });

  final String label;
  final IconData? icon;
  final T value;
  final bool isDestructive;
}

class LongPressMenu<T> extends StatelessWidget {
  const LongPressMenu({
    super.key,
    required this.child,
    required this.items,
    this.onSelected,
    this.enabled = true,
  });

  final Widget child;
  final List<LongPressMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPressStart: (details) async {
        MobileGestures.heavyImpact();
        final overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox?;
        if (overlay == null) return;

        final pos = details.globalPosition;
        final rect = RelativeRect.fromRect(
          Rect.fromCircle(center: pos, radius: 1),
          Offset.zero & overlay.size,
        );

        final selected = await showMenu<T>(
          context: context,
          position: rect,
          items: items
              .map(
                (i) => PopupMenuItem<T>(
                  value: i.value,
                  child: Row(
                    children: [
                      if (i.icon != null) ...[
                        Icon(
                          i.icon,
                          size: 18,
                          color: i.isDestructive
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        i.label,
                        style: TextStyle(
                          color: i.isDestructive
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );

        if (selected != null) {
          MobileGestures.selectionClick();
          onSelected?.call(selected);
        }
      },
      child: child,
    );
  }
}
