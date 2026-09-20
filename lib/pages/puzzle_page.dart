import 'package:flutter/material.dart';
import '../widgets/puzzle/fragment_draggable.dart';
import '../widgets/puzzle/volcano_core.dart';
import '../widgets/charts/extraction_time_chart.dart';
import '../widgets/charts/tactical_resources_chart.dart';
import '../widgets/charts/wear_level_chart.dart';
import '../widgets/charts/human_faction_chart.dart';
import '../widgets/charts/damage_origin_chart.dart';
import '../widgets/charts/guardians_radar_chart.dart';
import '../widgets/history_dialog.dart';

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({super.key});

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  final List<String> _placedFragments = [];

  void _onFragmentAccepted(String id) {
    setState(() {
      if (!_placedFragments.contains(id)) {
        _placedFragments.add(id);
      }
    });
  }

  // Función para reiniciar el rompecabezas
  void _resetPuzzle() {
    setState(() {
      _placedFragments.clear();
    });
  }

  void _showHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const HistoryDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isComplete = _placedFragments.length == 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asmodeo: Hub de Mando'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton.icon(
              onPressed: () => _showHistory(context),
              icon: const Icon(Icons.auto_stories, color: Colors.white),
              label: const Text(
                'Historia de Asmodeo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFc0392b), // Crimson
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // SECCIÓN DEL ROMPECABEZAS
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              color: isComplete ? Colors.deepPurple.withValues(alpha: 0.1) : null,
              child: Column(
                children: [
                  Text(
                    isComplete 
                        ? '¡El Motor de la Creación late al ritmo de su nuevo creador!'
                        : 'El rompecabezas está incompleto. Arrastra los fragmentos al núcleo.',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  // Zonas de fragmentos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFragmentZone(
                        id: 'esmeralda',
                        name: 'Esmeralda',
                        color: Colors.green,
                        icon: Icons.diamond_outlined,
                        label: 'Llanuras',
                      ),
                      _buildFragmentZone(
                        id: 'carmesi',
                        name: 'Carmesí',
                        color: Colors.red,
                        icon: Icons.local_fire_department,
                        label: 'Pantanos',
                      ),
                      _buildFragmentZone(
                        id: 'turquesa',
                        name: 'Turquesa',
                        color: Colors.cyan,
                        icon: Icons.ac_unit,
                        label: 'Tundras',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Núcleo del volcán
                  VolcanoCore(
                    placedFragments: _placedFragments,
                    onAccept: _onFragmentAccepted,
                  ),
                  
                  if (isComplete) ...[
                    const SizedBox(height: 30),
                    const Text(
                      'ESTADO: NUEVO DIOS',
                      style: TextStyle(
                        color: Colors.purpleAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _resetPuzzle,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Desensamblar y Reiniciar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        elevation: 5,
                        shadowColor: Colors.purpleAccent,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            
            // SECCIÓN DEL DASHBOARD (Se desbloquea poco a poco o siempre visible)
            const Divider(height: 1, color: Colors.white24),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'DASHBOARD TÁCTICO DEL INVENTOR',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  // Grillas de gráficos (Empezamos con los primeros 2 de las imágenes)
                  GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 800 ? 2 : 1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.0, // Dar más altura para evitar que se corte la leyenda
                    children: const [
                      ExtractionTimeChart(),
                      TacticalResourcesChart(),
                      WearLevelChart(),
                      HumanFactionChart(),
                      DamageOriginChart(),
                      GuardiansRadarChart(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFragmentZone({
    required String id,
    required String name,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    bool isPlaced = _placedFragments.contains(id);
    
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 10),
        FragmentDraggable(
          id: id,
          name: name,
          color: color,
          icon: icon,
          isPlaced: isPlaced,
        ),
      ],
    );
  }
}
