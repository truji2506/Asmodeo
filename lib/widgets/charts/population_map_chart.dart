import 'package:flutter/material.dart';

class PopulationMapChart extends StatelessWidget {
  const PopulationMapChart({super.key});

  final Color supervivientesColor = const Color(0xFFC0CA33); // Verde Oliva
  final Color nomadasColor = const Color(0xFF00BCD4); // Cian
  final Color chatarrerosColor = const Color(0xFFFFCA28); // Amarillo
  final Color eruditosColor = const Color(0xFF00838F); // Verde Oscuro / Teal

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 800;
        
        List<Widget> children = [
          Expanded(
            flex: isDesktop ? 1 : 0,
            child: SizedBox(
              height: 400,
              child: _buildMapCard(
                title: 'Asmodeo: Ubicación Estratégica',
                isPopulationMode: false,
              ),
            ),
          ),
          SizedBox(width: isDesktop ? 20 : 0, height: isDesktop ? 0 : 20),
          Expanded(
            flex: isDesktop ? 1 : 0,
            child: SizedBox(
              height: 400,
              child: _buildMapCard(
                title: 'Asmodeo: Población por Regiones',
                isPopulationMode: true,
              ),
            ),
          ),
        ];

        return isDesktop
            ? Row(children: children)
            : Column(children: children);
      },
    );
  }

  Widget _buildMapCard({required String title, required bool isPopulationMode}) {
    return Card(
      color: const Color(0xFF1a252f),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white10, width: 1),
      ),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 12),
            
            // Leyenda
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildLegendItem('Supervivientes', supervivientesColor, 2800, isPopulationMode),
                _buildLegendItem('Nómadas', nomadasColor, 6500, isPopulationMode),
                _buildLegendItem('Chatarreros', chatarrerosColor, 4200, isPopulationMode),
                _buildLegendItem('Eruditos', eruditosColor, 1500, isPopulationMode),
              ],
            ),
            const SizedBox(height: 20),
            
            // Mapa con Posicionamiento Exacto e Imagen de Fondo
            Expanded(
              child: Center(
                child: AspectRatio(
                  // Se mantiene la relación de aspecto de la imagen original (563x381)
                  aspectRatio: 563 / 381,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = Size(constraints.maxWidth, constraints.maxHeight);
                      
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Fondo: Imagen local proporcionada por el usuario
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/mapa_asmodeo.png', 
                                fit: BoxFit.fill,
                                opacity: const AlwaysStoppedAnimation(0.8), // Transparencia táctica
                              ),
                            ),
                          ),
                          
                          // Coordenadas exactas basadas en la demarcación del mapa
                          _buildDot(size, 23, 41, 'Supervivientes', 2800, supervivientesColor, isPopulationMode), // Sur de España
                          _buildDot(size, 38, 28, 'Nómadas', 6500, nomadasColor, isPopulationMode), // Argelia / Norte
                          _buildDot(size, 60, 30, 'Chatarreros', 4200, chatarrerosColor, isPopulationMode), // Centro de Libia
                          _buildDot(size, 78, 30, 'Eruditos', 1500, eruditosColor, isPopulationMode), // Norte de Egipto
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(Size size, double x, double y, String name, int pop, Color color, bool isPopMode) {
    double radius = _getRadius(pop, isPopMode);
    
    // Mapeo exacto: X e Y como porcentaje del contenedor
    double dx = (x / 100) * size.width;
    double dy = (1 - (y / 100)) * size.height;

    return Positioned(
      left: dx - radius, 
      top: dy - radius,  
      child: Tooltip(
        message: '$name\nPoblación: $pop',
        textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF2c3e50), 
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: isPopMode ? 1.5 : 1.0),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              )
            ]
          ),
        ),
      ),
    );
  }

  double _getRadius(int population, bool isPopMode) {
    if (!isPopMode) return 6.0; 
    // Fórmula reducida para que las burbujas sean más pequeñas y no se sobrepongan
    return (population / 6500) * 28 + 8;
  }

  Widget _buildLegendItem(String name, Color color, int population, bool isPopMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.9),
            shape: isPopMode ? BoxShape.circle : BoxShape.rectangle,
            border: Border.all(color: Colors.white, width: 1.0),
            borderRadius: isPopMode ? null : BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text.rich(
          TextSpan(
            text: '$name ',
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
            children: [
              if (isPopMode)
                TextSpan(
                  text: '($population)',
                  style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.normal),
                )
            ],
          ),
        ),
      ],
    );
  }
}
