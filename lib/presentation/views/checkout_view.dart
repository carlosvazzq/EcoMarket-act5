// =============================================================================
// CHECKOUT VIEW  (Rol 3 - Especialista en Captura y Validación UX/Form)
// -----------------------------------------------------------------------------
// Vista de cierre de compra sincronizada reactivamente con CatalogoController.
// Implementa:
//   - Árbol de validación estructurado mediante Form y GlobalKey<FormState>.
//   - Validaciones en cascada automatizadas con expresiones regulares (RegExp)
//     y alertas visuales en rojo reactivas sin evaluar TextEditingControllers
//     campo por campo.
//   - Control inmutable de botones en Material 3 (onPressed: null cuando el
//     carrito está vacío) y mutación reactiva de stock al confirmar el pago.
// =============================================================================

import 'package:flutter/material.dart';

import '../../domain/entities/item_carrito.dart';
import '../controllers/catalogo_controller.dart';
import 'seguimiento_view.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({required this.controller, super.key});

  final CatalogoController controller;

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  // GlobalKey de alta jerarquía para coordinar y disparar la validación en
  // cascada de todos los TextFormField del árbol sin usar controladores manuales.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Expresiones regulares (RegExp) para blindar la captura de datos:
  // 1. Nombre completo: solo letras (incluyendo acentos/ñ) y espacios, mín. 3 caracteres.
  static final RegExp _nombreRegExp = RegExp(
    r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]{3,60}$',
  );

  // 2. Correo electrónico: estructura estándar usuario@dominio.extension
  static final RegExp _correoRegExp = RegExp(
    r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$',
  );

  // 3. Teléfono de contacto: exactamente 10 dígitos numéricos.
  static final RegExp _telefonoRegExp = RegExp(r'^\d{10}$');

  // 4. Dirección de entrega: calle, número y referencia (mín. 5 caracteres).
  static final RegExp _direccionRegExp = RegExp(
    r'^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑüÜ\s#,\.-]{5,120}$',
  );

  // 5. Tarjeta de pago: 16 dígitos numéricos (permite espacios cada 4 dígitos).
  static final RegExp _tarjetaRegExp = RegExp(r'^(\d{4}\s?){3}\d{4}$');

  CatalogoController get controller => widget.controller;

  void _procesarPago(BuildContext context) {
    final formState = _formKey.currentState;
    if (formState == null) return;

    // Dispara las validaciones en cascada de todos los TextFormField.
    // Si algún campo no cumple su RegExp, pinta los avisos visuales en rojo.
    if (!formState.validate()) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Revisa los campos marcados en rojo antes de confirmar el pago.',
                  ),
                ),
              ],
            ),
          ),
        );
      return;
    }

    // Ejecuta la mutación de stock en RAM y vacía el carrito reactivamente.
    final pagoExitoso = controller.confirmarPago();

    if (!pagoExitoso) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            content: const Text(
              'Sin stock suficiente para completar la compra.',
            ),
          ),
        );
      return;
    }

    formState.reset();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '¡Pago confirmado! El stock se actualizó y tu pedido sustentable va en camino.',
                ),
              ),
            ],
          ),
        ),
      );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SeguimientoView(controller: controller),
      ),
    );
  }

  void _incrementarProducto(BuildContext context, ItemCarrito item) {
    if (controller.agregarAlCarrito(item.producto)) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Sin stock suficiente')));
  }

  InputDecoration _buildInputDecoration({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      errorStyle: TextStyle(
        color: colorScheme.error,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final items = controller.carrito;
        final carritoVacio = controller.carritoVacio;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Checkout Sustentable'),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ResumenCarritoSection(
                  items: items,
                  total: controller.total,
                  carritoVacio: carritoVacio,
                  onIncrementar: (item) => _incrementarProducto(context, item),
                  onDecrementar: (item) =>
                      controller.quitarDelCarrito(item.producto),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Datos de Entrega y Pago',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Completa todos los campos para validar e iniciar tu envío ecológico.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            decoration: _buildInputDecoration(
                              context: context,
                              label: 'Nombre completo',
                              hint: 'Ej. Ana Sofía Morales',
                              icon: Icons.person_outline,
                            ),
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              final input = value?.trim() ?? '';
                              if (input.isEmpty) {
                                return 'El nombre del destinatario es obligatorio';
                              }
                              if (!_nombreRegExp.hasMatch(input)) {
                                return 'Ingresa solo letras y espacios (mín. 3 caracteres)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            decoration: _buildInputDecoration(
                              context: context,
                              label: 'Correo electrónico',
                              hint: 'ejemplo@ecomarket.mx',
                              icon: Icons.alternate_email,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              final input = value?.trim() ?? '';
                              if (input.isEmpty) {
                                return 'El correo electrónico es obligatorio';
                              }
                              if (!_correoRegExp.hasMatch(input)) {
                                return 'Formato de correo inválido (ej. usuario@dominio.com)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            decoration: _buildInputDecoration(
                              context: context,
                              label: 'Teléfono de contacto (10 dígitos)',
                              hint: '9991234567',
                              icon: Icons.phone_outlined,
                            ),
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              final input = value?.trim() ?? '';
                              if (input.isEmpty) {
                                return 'El teléfono de contacto es obligatorio';
                              }
                              if (!_telefonoRegExp.hasMatch(input)) {
                                return 'Debe contener exactamente 10 dígitos numéricos';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            decoration: _buildInputDecoration(
                              context: context,
                              label: 'Dirección de entrega',
                              hint: 'Calle 60 #245, Col. Centro',
                              icon: Icons.location_on_outlined,
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              final input = value?.trim() ?? '';
                              if (input.isEmpty) {
                                return 'La dirección de entrega es obligatoria';
                              }
                              if (!_direccionRegExp.hasMatch(input)) {
                                return 'Ingresa una dirección válida (mín. 5 caracteres)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            decoration: _buildInputDecoration(
                              context: context,
                              label: 'Número de tarjeta (16 dígitos)',
                              hint: '4152 3138 0000 1234',
                              icon: Icons.credit_card_outlined,
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (!carritoVacio) _procesarPago(context);
                            },
                            validator: (value) {
                              final input = value?.trim() ?? '';
                              if (input.isEmpty) {
                                return 'El número de tarjeta es obligatorio';
                              }
                              if (!_tarjetaRegExp.hasMatch(input)) {
                                return 'Ingresa los 16 dígitos válidos de tu tarjeta';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          // Control inmutable de botón en Material 3:
                          // Si el carrito está vacío, onPressed recibe null y
                          // el botón queda deshabilitado automáticamente.
                          FilledButton.icon(
                            onPressed: carritoVacio
                                ? null
                                : () => _procesarPago(context),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.lock_outline),
                            label: Text(
                              carritoVacio
                                  ? 'Agrega productos para pagar'
                                  : 'Confirmar y Pagar (\$${controller.total.toStringAsFixed(2)})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResumenCarritoSection extends StatelessWidget {
  const _ResumenCarritoSection({
    required this.items,
    required this.total,
    required this.carritoVacio,
    required this.onIncrementar,
    required this.onDecrementar,
  });

  final List<ItemCarrito> items;
  final double total;
  final bool carritoVacio;
  final ValueChanged<ItemCarrito> onIncrementar;
  final ValueChanged<ItemCarrito> onDecrementar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Resumen de tu Carrito',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (carritoVacio)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Icon(
                      Icons.remove_shopping_cart_outlined,
                      size: 44,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tu carrito está vacío',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Regresa al catálogo para agregar productos sustentables.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver al catálogo'),
                    ),
                  ],
                ),
              )
            else ...[
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.producto.nombre,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${item.cantidad} x \$${item.producto.precio.toStringAsFixed(2)} (Stock disp: ${item.producto.stock})',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.outlined(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Quitar 1 unidad',
                        onPressed: () => onDecrementar(item),
                        icon: const Icon(Icons.remove, size: 18),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${item.cantidad}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton.outlined(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Agregar 1 unidad',
                        onPressed: () => onIncrementar(item),
                        icon: const Icon(Icons.add, size: 18),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 76,
                        child: Text(
                          '\$${item.subtotal.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total a pagar',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
