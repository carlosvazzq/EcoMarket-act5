
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

import 'data/datasources/productos_mock.dart';
import 'presentation/controllers/catalogo_controller.dart';
import 'presentation/views/catalogo_view.dart';

void main() {
  runApp(const EcoMarketApp());
}

class EcoMarketApp extends StatefulWidget {
  const EcoMarketApp({super.key});

  @override
  State<EcoMarketApp> createState() => _EcoMarketAppState();
}

class _EcoMarketAppState extends State<EcoMarketApp> {
  late final CatalogoController _controller =
      CatalogoController(productosIniciales: productosMock);

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
