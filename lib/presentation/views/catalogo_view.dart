import 'package:flutter/material.dart';

import '../../domain/entities/producto.dart';
import '../controllers/catalogo_controller.dart';
import '../widgets/producto_card.dart';
import 'checkout_view.dart';

enum _SortOption { availability, price, name }

class CatalogoView extends StatefulWidget {
  const CatalogoView({required this.controller, super.key});

  final CatalogoController controller;

  @override
  State<CatalogoView> createState() => _CatalogoViewState();
}

class _CatalogoViewState extends State<CatalogoView> {
  final _searchController = TextEditingController();
  String _search = '';
  double _maxPrice = 300;
  _SortOption _sort = _SortOption.availability;
  bool _listView = false;

  CatalogoController get controller => widget.controller;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final productos = _filteredProducts();
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 164,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('EcoMarket App'),
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 54, 20, 54),
                      child: Text(
                        'Hola, eco-comprador 🌱\nProductos sustentables para ti',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(54),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: SearchBar(
                      controller: _searchController,
                      hintText: 'Buscar productos...',
                      leading: const Icon(Icons.search),
                      trailing: [
                        if (_search.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _search = '');
                            },
                            icon: const Icon(Icons.clear),
                          ),
                      ],
                      onChanged: (value) => setState(() => _search = value),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Abrir carrito',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CheckoutView(controller: controller),
                      ),
                    ),
                    icon: Badge(
                      label: Text('${controller.cantidadItems}'),
                      isLabelVisible: controller.cantidadItems > 0,
                      child: const Icon(Icons.shopping_bag_outlined),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(child: _buildControls(context)),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _CategoryFilters(
                    key: ValueKey(controller.categoriaSeleccionada),
                    controller: controller,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildCartSummary(context)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                sliver: _ProductResults(
                  key: ValueKey('${_listView}_${productos.length}_$_search'),
                  productos: productos,
                  listView: _listView,
                  onAgregar: (producto) => _agregarProducto(context, producto),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: controller.rellenarStock,
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Rellenar stock'),
          ),
        );
      },
    );
  }

  Widget _buildControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<_SortOption>(
              value: _sort,
              decoration: const InputDecoration(
                labelText: 'Ordenar por',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(
                  value: _SortOption.availability,
                  child: Text('Disponibilidad'),
                ),
                DropdownMenuItem(
                  value: _SortOption.price,
                  child: Text('Precio'),
                ),
                DropdownMenuItem(
                  value: _SortOption.name,
                  child: Text('Nombre'),
                ),
              ],
              onChanged: (value) => setState(() => _sort = value!),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: _listView ? 'Vista de cuadrícula' : 'Vista de lista',
            onPressed: () => setState(() => _listView = !_listView),
            icon: Icon(_listView ? Icons.grid_view : Icons.view_list),
          ),
          IconButton.filledTonal(
            tooltip: 'Filtrar por precio',
            onPressed: () => _showPriceFilter(context),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context) {
    if (controller.carritoVacio) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: ListTile(
          leading: const Icon(Icons.shopping_cart_checkout),
          title: Text('${controller.cantidadItems} productos en tu carrito'),
          subtitle: Text('Total: \$${controller.total.toStringAsFixed(2)}'),
          trailing: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CheckoutView(controller: controller),
              ),
            ),
            child: const Text('Ver carrito'),
          ),
        ),
      ),
    );
  }

  List<Producto> _filteredProducts() {
    final normalizedSearch = _search.trim().toLowerCase();
    final products = controller.productosFiltrados.where((producto) {
      final matchesSearch = normalizedSearch.isEmpty ||
          producto.nombre.toLowerCase().contains(normalizedSearch) ||
          producto.categoria.toLowerCase().contains(normalizedSearch);
      return matchesSearch && producto.precio <= _maxPrice;
    }).toList();

    products.sort((a, b) {
      switch (_sort) {
        case _SortOption.price:
          return a.precio.compareTo(b.precio);
        case _SortOption.name:
          return a.nombre.compareTo(b.nombre);
        case _SortOption.availability:
          return b.stock.compareTo(a.stock);
      }
    });
    return products;
  }

  Future<void> _showPriceFilter(BuildContext context) async {
    var selectedPrice = _maxPrice;
    final result = await showModalBottomSheet<double>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Precio máximo: \$${selectedPrice.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                min: 35,
                max: 300,
                divisions: 53,
                value: selectedPrice,
                label: '\$${selectedPrice.toStringAsFixed(0)}',
                onChanged: (value) =>
                    setModalState(() => selectedPrice = value),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, selectedPrice),
                child: const Text('Aplicar filtro'),
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null) setState(() => _maxPrice = result);
  }

  void _agregarProducto(BuildContext context, Producto producto) {
    if (controller.agregarAlCarrito(producto)) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Sin stock suficiente')));
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({required this.controller, super.key});

  final CatalogoController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Todos'),
            selected: controller.categoriaSeleccionada == null,
            onSelected: (_) => controller.categoriaSeleccionada = null,
          ),
          ...controller.categorias.map(
            (categoria) => ChoiceChip(
              label: Text(categoria),
              selected: controller.categoriaSeleccionada == categoria,
              onSelected: (_) => controller.categoriaSeleccionada = categoria,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductResults extends StatelessWidget {
  const _ProductResults({
    required this.productos,
    required this.listView,
    required this.onAgregar,
    super.key,
  });

  final List<Producto> productos;
  final bool listView;
  final ValueChanged<Producto> onAgregar;

  @override
  Widget build(BuildContext context) {
    if (productos.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No hay productos con estos filtros')),
        ),
      );
    }

    if (listView) {
      return SliverList.builder(
        itemCount: productos.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductoCard(
            producto: productos[index],
            listView: true,
            onAgregar: () => onAgregar(productos[index]),
          ),
        ),
      );
    }

    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: productos.length,
      itemBuilder: (context, index) => ProductoCard(
        producto: productos[index],
        onAgregar: () => onAgregar(productos[index]),
      ),
    );
  }
}
