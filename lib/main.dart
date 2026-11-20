// MAIN  (punto de entrada de la app)
// -----------------------------------------------------------------------------
// Aquí solo se arranca la app y se configura el tema. Nada de lógica.
//
// INTEGRACIÓN (Día 3, todo el equipo):
//   1. Crear una sola instancia: final controller = CatalogoController();
//   2. Pasársela a CatalogoView y a CheckoutView por constructor.
//
// ROL 2: cambia el "home" de abajo por tu CatalogoView(controller: controller)
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'data/services/ecomarket_service.dart';
import 'presentation/controllers/catalogo_controller.dart';
import 'presentation/views/catalogo_view.dart';

const String _tareaSincronizacionInventario =
    'sincronizacion_silenciosa_inventario';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == _tareaSincronizacionInventario) {
      debugPrint('Sincronización silenciosa de inventario completada.');
    }
    return true;
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'ecomarket-inventario-periodico',
    _tareaSincronizacionInventario,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  runApp(const EcoMarketApp());
}

class EcoMarketApp extends StatefulWidget {
  const EcoMarketApp({super.key});

  @override
  State<EcoMarketApp> createState() => _EcoMarketAppState();
}

class _EcoMarketAppState extends State<EcoMarketApp> {
  late final CatalogoController _controller = CatalogoController(
    service: EcoMarketService(),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoMarket App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF356859),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F3EA),
        cardTheme: const CardThemeData(
          color: Color(0xFFFFFCF5),
          elevation: 3,
          shadowColor: Color(0x40356859),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        useMaterial3: true,
      ),
      home: CatalogoView(controller: _controller),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
