import 'package:flutter/material.dart';

class HistoryDialog extends StatelessWidget {
  const HistoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 750),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a), // Fondo oscuro elegante
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFc0392b).withValues(alpha: 0.5), width: 2), // Borde Carmesí
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFc0392b).withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          children: [
            // Cabecera
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_stories, color: Color(0xFFc0392b), size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Los Archivos de Midgard',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
            
            // Contenido Escroleable
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Asmodeo',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFf39c12), // Naranja para el título
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildParagraph(
                        'El continente de Midgard siempre fue un lugar completamente despiadado y salvaje, donde sobrevivir era cosa de todos los días. La verdad, era el escenario perfecto para alguien como Asmodeo. Él no era para nada el típico héroe idealista que va por ahí buscando salvar a la gente o ser el bueno del cuento, de esos ya había demasiados. Más bien, Asmodeo era un sabelotodo bastante sarcástico, un inventor súper calculador que estaba obsesionado con encontrar la lógica que se escondía detrás de la magia. Para él, hacer conjuros no tenía sentido si no podías medirlo en un plano o ajustarlo con una llave inglesa. Su objetivo en la vida no era ganar fama ni rescatar a nadie, sino resolver el rompecabezas mecánico más antiguo y complicado de la historia: el Motor de la Creación.'
                      ),
                      _buildParagraph(
                        'Las viejas leyendas del continente hablaban de tres Fragmentos del Génesis. Eran unas piezas geométricas hechas de un cristal súper raro, forjadas por deidades míticas hace miles de años. Estaban diseñadas para ensamblarse como si fueran un rompecabezas de alta ingeniería, formando un único artefacto de poder absoluto. Como era de esperarse, Asmodeo no vio esto como una misión divina, sino como un proyecto de diseño muy complejo que debía solucionar, justo ahora que corría el año 842 de la era astral y el mundo parecía más caótico que nunca.'
                      ),
                      _buildParagraph(
                        'Su primera parada fueron las llanuras. Ahí se enfrentó a un enorme tirano porcino, una bestia que era pura fuerza bruta y cero cerebro. En lugar de ir a darle espadazos de frente, Asmodeo armó una red de trampas mecánicas muy meticulosas. Calculó el peso, la fuerza de impacto y la velocidad de la criatura y, con un par de cuerdas y engranajes perfectamente ubicados, hizo que el enorme cerdo cayera en su propio juego. Así, casi sin despeinarse, le arrebató el Fragmento Esmeralda.'
                      ),
                      _buildParagraph(
                        'Unos meses después, el viaje lo llevó a los pantanos, un lugar húmedo, tóxico y asqueroso donde vivía un hechicero bastante arrogante. Este tipo se creía invencible solo porque sabía mover las manos y recitar hechizos. Asmodeo, fiel a su estilo, decidió demostrarle que la ciencia y la física le ganaban a la magia. Usando unos artefactos que él mismo había inventado, cargados con mucha pólvora y temporizadores, le preparó una emboscada. Cuando el hechicero quiso atacar y se confió, Asmodeo detonó todo. Entre el humo y el barro, caminó tranquilo y extrajo la pieza Carmesí directamente del báculo roto de su enemigo. Ya tenía dos.'
                      ),
                      _buildParagraph(
                        'Pero la última parte no fue para nada fácil. Le tocó viajar a unas tundras congeladas, llenas de laberintos de hielo donde patrullaban minotauros enormes. Aquí la cosa se puso realmente fea. Asmodeo no era un guerrero físico, así que el clima extremo y el acoso constante de las bestias casi acaban con él. Tuvo que sobrevivir a base de pura resistencia, escondiéndose en la nieve y revisando sus planos ya todos desgastados y húmedos. La probabilidad matemática de fallar era altísima, pero logró escabullirse. Acumulando unas cuantas cicatrices nuevas que le dolerían siempre, por fin consiguió el Fragmento Turquesa.'
                      ),
                      _buildParagraph(
                        'Con las tres piezas en su poder, viajó hasta el centro de un volcán inactivo. El calor ahí era insoportable, pero era la fragua natural que necesitaba. Asmodeo sacó las tres piezas de cristal. Respiró hondo y las dispuso frente a él. Con una precisión milimétrica, propia de un relojero obsesivo, deslizó los engranajes de cristal uno dentro del otro. No hubo grandes explosiones mágicas al principio, solo el ruido de un mecanismo haciendo un clic perfecto. De repente, los fragmentos rotaron solos y se fusionaron en una esfera pulsante de energía pura. El rompecabezas estaba completo. El universo entero se quedó en silencio por un segundo, y luego comenzó a latir al ritmo de su nuevo creador.'
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.6, // Interlineado profesional
          color: Colors.white70,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
