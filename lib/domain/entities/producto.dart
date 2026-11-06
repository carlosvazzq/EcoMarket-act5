// =============================================================================
// PRODUCTO  (Rol 1 - Dominio)
// -----------------------------------------------------------------------------
// Entidad principal de la app: un producto del catálogo ecológico.
// Es inmutable (todos sus campos son final). Para "cambiar" el stock
// se crea una copia nueva con copyWith(), eso lo hace el CatalogoController.
//
// ROL 2: en ProductoCard muestra nombre, precio, stock e imagenUrl.
//        Usa producto.disponible para pintar "Agotado" cuando sea false.
// =============================================================================
class Producto {
  final String id;
  final String nombre;
  final String categoria;
  final double precio;
  final int stock;
  final String imagenUrl;

  /// El constructor está blindado con aserciones en la lista de
  /// inicialización: en modo debug, cualquier valor negativo detiene la app.
  const Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.stock,
    required this.imagenUrl,
  })  : assert(precio >= 0, 'El precio no puede ser negativo'),
        assert(stock >= 0, 'El stock no puede ser negativo');

  // Getter computado: true si queda al menos 1 unidad.
  bool get disponible => stock > 0;

  // Crea una copia del producto cambiando solo lo que le mandes.
  // Ejemplo: producto.copyWith(stock: 5) -> mismo producto con stock 5
  Producto copyWith({
    String? id,
    String? nombre,
    String? categoria,
    double? precio,
    int? stock,
    String? imagenUrl,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      imagenUrl: imagenUrl ?? this.imagenUrl,
    );
  }

  // Dos productos son "iguales" si tienen el mismo id.
  @override
  bool operator ==(Object other) => other is Producto && other.id == id;

  @override
  int get hashCode => id.hashCode;

  // Texto legible para debug: print(producto)
  @override
  String toString() => 'Producto($id, $nombre, \$$precio, stock: $stock)';
}
