import 'producto.dart';

// ITEM CARRITO  (Rol 1 - Dominio)
// Representa UNA línea del carrito: qué producto y cuántas unidades.
// Es inmutable (campos final). La crea el CatalogoController, la UI solo la lee.
//
// ROL 3: en el resumen del checkout muestra item.producto.nombre,
//        item.cantidad y item.subtotal de cada línea.
class ItemCarrito {
  final Producto producto;
  final int cantidad;

  // assert: nunca puede existir una línea con 0 o menos unidades.
  const ItemCarrito({
    required this.producto,
    required this.cantidad,
  }) : assert(cantidad > 0, 'La cantidad debe ser mayor a cero');

  // Getter computado: precio del producto x cantidad.
  // Ejemplo: Termo $250 x 2 = $500
  double get subtotal => producto.precio * cantidad;
}
