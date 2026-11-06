import 'package:flutter/material.dart';

import '../../domain/entities/producto.dart';

class ProductoCard extends StatefulWidget {
  const ProductoCard({
    required this.producto,
    required this.onAgregar,
    this.listView = false,
    super.key,
  });

  final Producto producto;
  final VoidCallback onAgregar;
  final bool listView;

  @override
  State<ProductoCard> createState() => _ProductoCardState();
}

class _ProductoCardState extends State<ProductoCard> {
  bool _showAdded = false;

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final theme = Theme.of(context);
    final badge = _badgeFor(producto);

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(widget.listView ? 16 : 20),
      child: Image.network(
        producto.imagenUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorBuilder: (context, error, stackTrace) => const ColoredBox(
          color: Color(0xFFE6EFE5),
          child: Center(
            child: Icon(Icons.image_not_supported_outlined, size: 40),
          ),
        ),
      ),
    );

    final details = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            producto.nombre,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            producto.categoria,
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          const Spacer(),
          Text(
            '\$${producto.precio.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            producto.disponible ? 'Stock: ${producto.stock}' : 'Agotado',
            style: TextStyle(
              color: producto.disponible
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: producto.disponible
                  ? () {
                      setState(() => _showAdded = true);
                      widget.onAgregar();
                      Future<void>.delayed(
                        const Duration(milliseconds: 500),
                        () {
                          if (mounted) setState(() => _showAdded = false);
                        },
                      );
                    }
                  : null,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _showAdded
                    ? const Icon(Icons.check, key: ValueKey('added'))
                    : const Text('Agregar', key: ValueKey('add')),
              ),
            ),
          ),
        ],
      ),
    );

    return AnimatedScale(
      scale: _showAdded ? 1.02 : 1,
      duration: const Duration(milliseconds: 180),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: widget.listView
            ? SizedBox(
                height: 190,
                child: Row(
                  children: [
                    SizedBox(width: 150, height: double.infinity, child: image),
                    Expanded(child: details),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 4,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        image,
                        if (!producto.disponible) const _StockOverlay(),
                      ],
                    ),
                  ),
                  Expanded(flex: 5, child: details),
                ],
              ),
      ),
    );
  }

  String? _badgeFor(Producto producto) {
    if (!producto.disponible) return null;
    if (producto.id == 'p1') return 'Más vendido';
    if (producto.id == 'p8') return 'Nuevo';
    if (producto.id == 'p6') return 'Eco recomendado';
    return null;
  }
}

class _StockOverlay extends StatelessWidget {
  const _StockOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Color(0x66000000),
      child: Center(
        child: Text(
          'AGOTADO',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
