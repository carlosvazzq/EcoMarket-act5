import '../../domain/entities/estado_entrega.dart';
import '../../domain/entities/producto.dart';
import '../datasources/productos_mock.dart';

class EcoMarketService {
  Future<List<Producto>> obtenerCatalogo({bool simularError = false}) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (simularError) {
      throw Exception('No se pudo cargar el catálogo.');
    }
    return productosMock;
  }

  Stream<EstadoEntrega> seguirRepartidor({int minutosIniciales = 12}) async* {
    var minutosRestantes = minutosIniciales;
    var latitud = 19.4326;
    var longitud = -99.1332;

    yield EstadoEntrega(
      minutosRestantes: minutosRestantes,
      latitud: latitud,
      longitud: longitud,
      mensaje: 'El repartidor está en camino.',
    );

    while (minutosRestantes > 0) {
      await Future<void>.delayed(const Duration(seconds: 3));
      minutosRestantes--;
      latitud += 0.001;
      longitud += 0.001;

      yield EstadoEntrega(
        minutosRestantes: minutosRestantes,
        latitud: latitud,
        longitud: longitud,
        mensaje: minutosRestantes == 0
            ? 'El pedido ha sido entregado.'
            : 'El repartidor se acerca a tu ubicación.',
      );
    }
  }
}
