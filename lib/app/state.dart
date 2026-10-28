import 'package:flutter/widgets.dart';
import 'data.dart';

enum Pantalla { mesa, viaje, motor }

/// Estado único de la experiencia. Todas las pantallas leen y escriben aquí.
class AsmodeoState extends ChangeNotifier {
  Pantalla pantalla = Pantalla.mesa;

  // 01 Mesa
  bool planoAbierto = true; // la Mesa abre con el plano desenrollado
  int lugarSel = 1; // índice en `lugares` (Pantanos por defecto, como el wireframe)

  // 02 Viaje
  int etapa = 0; // 0 = inicio … 4 = volcán
  final Set<String> recolectados = {};
  int viajeTab = 0; // 0 = Forja, 1 = Despiece

  // 03 Fragua
  final Set<String> enFragua = {};
  bool completo = false;

  // 04 Creación
  bool lupa = false;
  String lupaFrag = 'carmesi';
  int statsTab = 0; // Guardianes, Desgaste, Recursos, Daño
  final Set<String> guardianesVisibles = {'esmeralda', 'carmesi', 'turquesa'};
  String? anotacionAbierta;

  /// La tuerca recorre todo el viaje (Inicio → Volcán) libremente.
  int get etapaMaxima => 4;

  String? get fragEtapa => etapas[etapa].fragId;

  void ir(Pantalla p) {
    pantalla = p;
    notifyListeners();
  }

  void abrirPlano([bool v = true]) {
    planoAbierto = v;
    notifyListeners();
  }

  void seleccionarLugar(int i) {
    lugarSel = i;
    notifyListeners();
  }

  /// Desde la Mesa: «Ver en el viaje →».
  void verEnViaje(int lugar) {
    final destino = lugar == 4 ? 0 : lugar + 1; // lugares 0..3 → etapas 1..4; Midgard → inicio
    etapa = destino <= etapaMaxima ? destino : etapaMaxima;
    pantalla = Pantalla.viaje;
    notifyListeners();
  }

  void irEtapa(int e) {
    etapa = e.clamp(0, etapaMaxima);
    notifyListeners();
  }

  void setViajeTab(int t) {
    viajeTab = t;
    notifyListeners();
  }

  void forjar() {
    final id = fragEtapa;
    if (id == null) return;
    recolectados.add(id);
    notifyListeners();
  }

  void siguienteEtapa() => irEtapa(etapa + 1);

  void meterEnFragua(String id) {
    enFragua.add(id);
    notifyListeners();
  }

  void encender() {
    if (enFragua.length == 3) {
      completo = true;
      notifyListeners();
    }
  }

  void setLupa(bool v) {
    lupa = v;
    notifyListeners();
  }

  void setLupaFrag(String id) {
    lupaFrag = id;
    lupa = true;
    notifyListeners();
  }

  void setStatsTab(int t) {
    statsTab = t;
    notifyListeners();
  }

  void toggleGuardian(String id) {
    if (guardianesVisibles.contains(id)) {
      if (guardianesVisibles.length > 1) guardianesVisibles.remove(id);
    } else {
      guardianesVisibles.add(id);
    }
    notifyListeners();
  }

  void toggleAnotacion(String id) {
    anotacionAbierta = anotacionAbierta == id ? null : id;
    notifyListeners();
  }

  void reiniciar() {
    pantalla = Pantalla.mesa;
    planoAbierto = true;
    lugarSel = 1;
    etapa = 0;
    recolectados.clear();
    viajeTab = 0;
    enFragua.clear();
    completo = false;
    lupa = false;
    lupaFrag = 'carmesi';
    statsTab = 0;
    guardianesVisibles
      ..clear()
      ..addAll(['esmeralda', 'carmesi', 'turquesa']);
    anotacionAbierta = null;
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AsmodeoState> {
  const AppScope({super.key, required AsmodeoState state, required super.child}) : super(notifier: state);

  static AsmodeoState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
