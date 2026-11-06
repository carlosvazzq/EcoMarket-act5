import 'package:flutter/material.dart';

import '../controllers/catalogo_controller.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({required this.controller, super.key});

  final CatalogoController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) => Scaffold(
        appBar: AppBar(title: const Text('Tu carrito')),
        body: controller.carritoVacio
            ? const Center(child: Text('Tu carrito está vacío'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ...controller.carrito.map(
                    (item) => Card(
                      child: ListTile(
                        title: Text(item.producto.nombre),
                        subtitle: Text(
                          '${item.cantidad} x \$${item.producto.precio.toStringAsFixed(2)}',
                        ),
                        trailing: Text(
                          '\$${item.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total: \$${controller.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
      ),
    );
  }
}
