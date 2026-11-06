
// CATALOGO CONTROLLER  (Rol 1 - Arquitectura y Datos)

// Es el "cerebro" de la app. Guarda en memoria RAM:
//   - la lista de productos (catálogo)
//   - el carrito de compras
//   - la categoría seleccionada para filtrar
//
// Usa el patrón Observer: extiende ChangeNotifier y cada vez que algo cambia
// llama a notifyListeners() para avisarle a la pantalla que se redibuje.
//
// REGLA: las vistas NO calculan nada ni modifican el stock. Solo leen los
// getters de aquí y llaman a los métodos de aquí.
//
// ROL 2: envuelve tu CatalogoView con ListenableBuilder(listenable: controller)
// ROL 3: en CheckoutView usa controller.total y controller.confirmarPago()
// ROL 4: cuando tu Future devuelva los productos llama a controller.cargarProductos()

import 'package:flutter/foundation.dart';

import '../../domain/entities/item_carrito.dart';
import '../../domain/entities/producto.dart';

class CatalogoController extends ChangeNotifier {
  // Recibe los productos iniciales. Si no le mandas nada, arranca vacío.
  CatalogoController({List<Producto> productosIniciales = const []})
      : _productos = List.of(productosIniciales);

  // Lista de productos en RAM (privada, solo este controller la modifica).
  List<Producto> _productos;

  // Carrito: guarda "id del producto -> cuántas unidades".
  // Ejemplo: {'p1': 2, 'p5': 1}
  final Map<String, int> _carrito = {};

  // Categoría elegida en el Wrap. null = mostrar todas.
  String? _categoriaSeleccionada;

  // GETTERS (solo lectura, la UI los usa para pintar datos)

  // Todos los productos. Es "unmodifiable" para que nadie desde la UI
  // pueda agregar o borrar productos por fuera del controller.
  List<Producto> get productos => List.unmodifiable(_productos);

  // ROL 2: usa esta lista para crear las etiquetas (Chips) del Wrap.
  // Saca las categorías sin repetir: ['Higiene', 'Hogar', 'Cocina', 'Jardín']
  List<String> get categorias =>
      _productos.map((p) => p.categoria).toSet().toList();

  // ROL 2: úsalo para saber qué Chip pintar como seleccionado.
  String? get categoriaSeleccionada => _categoriaSeleccionada;

  // SETTER computado: cambia el filtro y redibuja la pantalla sola.
  // Si tocas la misma categoría otra vez, se quita el filtro.
  // ROL 2: en el onSelected del Chip pon -> controller.categoriaSeleccionada = cat;
  set categoriaSeleccionada(String? categoria) {
    _categoriaSeleccionada =
        categoria == _categoriaSeleccionada ? null : categoria;
    notifyListeners();
  }

  // ROL 2: ESTA es la lista que va en el SliverGrid (ya viene filtrada).
  List<Producto> get productosFiltrados => _categoriaSeleccionada == null
      ? productos
      : _productos.where((p) => p.categoria == _categoriaSeleccionada).toList();

  // ROL 3: lista de lo que hay en el carrito para mostrar el resumen
  // en el checkout (nombre, cantidad y subtotal de cada producto).
  List<ItemCarrito> get carrito => _carrito.entries
      .map((e) => ItemCarrito(producto: _buscar(e.key), cantidad: e.value))
      .toList();

  // ROL 2: número total de piezas en el carrito (para el badge del ícono).
  int get cantidadItems => _carrito.values.fold(0, (sum, c) => sum + c);

  // ROL 3: total a pagar. Suma los subtotales de cada línea del carrito.
  double get total => carrito.fold(0.0, (sum, item) => sum + item.subtotal);

  // ROL 3: úsalo para desactivar el botón "Pagar" si no hay nada.
  bool get carritoVacio => _carrito.isEmpty;

  // Cuántas unidades de un producto específico hay en el carrito.
  int cantidadEnCarrito(String productoId) => _carrito[productoId] ?? 0;

  // ACCIONES (métodos que cambian datos y avisan a la UI)

  // Reemplaza todo el catálogo con una lista nueva y vacía el carrito.
  // ROL 4: llámalo cuando tu Future de 1 segundo termine de cargar.
  void cargarProductos(List<Producto> productos) {
    _productos = List.of(productos);
    _carrito.clear();
    notifyListeners();
  }

  // Agrega 1 unidad al carrito.
  // Regresa true si se pudo, false si ya no hay stock suficiente.
  // ROL 2: si regresa false, muestra un SnackBar de "Sin stock suficiente".
  //   if (!controller.agregarAlCarrito(producto)) { ...mostrar SnackBar... }
  bool agregarAlCarrito(Producto producto) {
    final actual = _buscar(producto.id); // versión más reciente del producto
    final enCarrito = cantidadEnCarrito(actual.id);

    // Validación: no dejar meter más unidades de las que hay en stock.
    if (enCarrito + 1 > actual.stock) return false;

    _carrito[actual.id] = enCarrito + 1;
    notifyListeners();
    return true;
  }

  // Quita 1 unidad del carrito. Si llega a 0, se borra la línea.
  // ROL 3: opcional, para un botón "-" en el resumen del checkout.
  void quitarDelCarrito(Producto producto) {
    final enCarrito = cantidadEnCarrito(producto.id);
    if (enCarrito == 0) return;

    if (enCarrito == 1) {
      _carrito.remove(producto.id);
    } else {
      _carrito[producto.id] = enCarrito - 1;
    }
    notifyListeners();
  }

  // Confirma la compra:
  //   1. Revisa que todo tenga stock suficiente.
  //   2. Resta las unidades compradas del stock real (con copyWith).
  //   3. Vacía el carrito.
  // Regresa false si el carrito está vacío o falta stock (no cambia nada).
  // ROL 3: llámalo SOLO después de que _formKey.currentState!.validate() sea true.
  //   if (controller.confirmarPago()) { ...éxito... } else { ...SnackBar... }
  bool confirmarPago() {
    if (_carrito.isEmpty) return false;

    final haySuficiente = carrito.every((i) => i.cantidad <= i.producto.stock);
    if (!haySuficiente) return false;

    // Producto es inmutable: no se cambia, se crea una copia con el stock nuevo.
    _productos = _productos.map((p) {
      final comprado = cantidadEnCarrito(p.id);
      return comprado == 0 ? p : p.copyWith(stock: p.stock - comprado);
    }).toList();

    _carrito.clear();
    notifyListeners();
    return true;
  }

  // Le suma unidades a todos los productos (por defecto 10).
  // ROL 2: llámalo desde el onPressed del FloatingActionButton "Rellenar stock".
  void rellenarStock({int unidades = 10}) {
    assert(unidades > 0, 'Las unidades a reabastecer deben ser positivas');
    _productos =
        _productos.map((p) => p.copyWith(stock: p.stock + unidades)).toList();
    notifyListeners();
  }

  // PRIVADOS (uso interno)

  // Busca un producto por su id dentro de la lista actual.
  Producto _buscar(String id) => _productos.firstWhere((p) => p.id == id);
}
