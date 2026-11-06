import '../../domain/entities/producto.dart';

// PRODUCTOS MOCK  (Rol 1 - Datos)
// Datos de prueba del catálogo. No hay base de datos ni internet:
// todo vive en la memoria RAM mientras la app está abierta.
//
// Para la demo (prueba de estrés):
//   - "Velas de soya" tiene stock 1  -> al agregar 2 sale el SnackBar
//   - "Popotes de metal" tiene stock 3
//
// ROL 4: en data/services/eco_service.dart regresa esta lista con
//        Future.delayed(const Duration(seconds: 1), () => productosMock)
// ROL 2: las imágenes son de internet; usa loadingBuilder y errorBuilder
//        en Image.network por si no cargan.
const List<Producto> productosMock = [
  Producto(
    id: 'p1',
    nombre: 'Cepillo de bambú',
    categoria: 'Higiene',
    precio: 45.0,
    stock: 10,
    imagenUrl: 'https://picsum.photos/seed/bambu/400/400',
  ),
  Producto(
    id: 'p2',
    nombre: 'Bolsa de tela',
    categoria: 'Hogar',
    precio: 60.0,
    stock: 8,
    imagenUrl: 'https://picsum.photos/seed/bolsa/400/400',
  ),
  Producto(
    id: 'p3',
    nombre: 'Termo de acero',
    categoria: 'Cocina',
    precio: 250.0,
    stock: 5,
    imagenUrl: 'https://picsum.photos/seed/termo/400/400',
  ),
  Producto(
    id: 'p4',
    nombre: 'Jabón artesanal',
    categoria: 'Higiene',
    precio: 35.0,
    stock: 15,
    imagenUrl: 'https://picsum.photos/seed/jabon/400/400',
  ),
  Producto(
    id: 'p5',
    nombre: 'Popotes de metal',
    categoria: 'Cocina',
    precio: 80.0,
    stock: 3,
    imagenUrl: 'https://picsum.photos/seed/popotes/400/400',
  ),
  Producto(
    id: 'p6',
    nombre: 'Composta orgánica',
    categoria: 'Jardín',
    precio: 120.0,
    stock: 6,
    imagenUrl: 'https://picsum.photos/seed/composta/400/400',
  ),
  Producto(
    id: 'p7',
    nombre: 'Maceta biodegradable',
    categoria: 'Jardín',
    precio: 55.0,
    stock: 12,
    imagenUrl: 'https://picsum.photos/seed/maceta/400/400',
  ),
  Producto(
    id: 'p8',
    nombre: 'Velas de soya',
    categoria: 'Hogar',
    precio: 95.0,
    stock: 1,
    imagenUrl: 'https://picsum.photos/seed/velas/400/400',
  ),
];
