import 'package:flutter/material.dart';

import '../../domain/entities/estado_entrega.dart';
import '../controllers/catalogo_controller.dart';

class SeguimientoView extends StatefulWidget {
  const SeguimientoView({required this.controller, super.key});

  final CatalogoController controller;

  @override
  State<SeguimientoView> createState() => _SeguimientoViewState();
}

class _SeguimientoViewState extends State<SeguimientoView> {
  late final Stream<EstadoEntrega> _seguimientoStream;

  @override
  void initState() {
    super.initState();
    _seguimientoStream = widget.controller.seguirPedido();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguimiento del pedido')),
      body: StreamBuilder<EstadoEntrega>(
        stream: _seguimientoStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al seguir el pedido: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No hay información del pedido.'));
          }

          final estado = snapshot.data!;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    estado.entregado
                        ? Icons.check_circle_outline
                        : Icons.local_shipping_outlined,
                    size: 72,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    estado.entregado
                        ? '¡Pedido entregado!'
                        : '${estado.minutosRestantes} minutos restantes',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(estado.mensaje, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text(
                    'Ubicación: ${estado.latitud.toStringAsFixed(4)}, '
                    '${estado.longitud.toStringAsFixed(4)}',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
