import 'package:flutter/material.dart';

class VolcanoCore extends StatelessWidget {
  final List<String> placedFragments;
  final Function(String) onAccept;

  const VolcanoCore({
    super.key,
    required this.placedFragments,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    bool isComplete = placedFragments.length == 3;

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => !placedFragments.contains(details.data),
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        bool isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: isComplete
                ? Colors.purple.withOpacity(0.3)
                : isHovering
                    ? Colors.orange.withOpacity(0.3)
                    : Colors.black45,
            shape: BoxShape.circle,
            border: Border.all(
              color: isComplete
                  ? Colors.purpleAccent
                  : isHovering
                      ? Colors.orangeAccent
                      : Colors.white30,
              width: isComplete ? 4 : 2,
            ),
            boxShadow: [
              if (isComplete || isHovering)
                BoxShadow(
                  color: (isComplete ? Colors.purple : Colors.orange)
                      .withOpacity(0.6),
                  blurRadius: 40,
                  spreadRadius: 10,
                )
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Icono central
              Icon(
                isComplete ? Icons.lightbulb_circle : Icons.settings,
                size: 80,
                color: isComplete ? Colors.white : Colors.grey,
              ),
              // Indicadores de fragmentos
              Positioned(
                top: 20,
                child: _buildSlot('esmeralda', Colors.green),
              ),
              Positioned(
                bottom: 40,
                left: 30,
                child: _buildSlot('carmesi', Colors.red),
              ),
              Positioned(
                bottom: 40,
                right: 30,
                child: _buildSlot('turquesa', Colors.cyan),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSlot(String id, Color color) {
    bool isPlaced = placedFragments.contains(id);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isPlaced ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isPlaced ? Colors.white : Colors.white24,
          width: 2,
        ),
        boxShadow: [
          if (isPlaced)
            BoxShadow(
              color: color,
              blurRadius: 10,
              spreadRadius: 2,
            )
        ],
      ),
    );
  }
}
