import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _apiService = ApiService();

  Product? _product;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final product = await _apiService.fetchProductById(widget.productId);
      if (!mounted) return;
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load product details. Check your connection.';
        _isLoading = false;
      });
    }
  }

  void _onAddToCart() {
    if (_product == null) return;

    context.read<CartProvider>().addProduct(_product!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_product!.title} added to cart'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View cart',
          textColor: AppColors.primary,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) => _CartBadgeButton(
              count: cart.totalQuantity,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return _ErrorView(onRetry: _loadProduct);
    }

    if (_product == null) {
      return const _EmptyView();
    }

    return _ProductContent(product: _product!, onAddToCart: _onAddToCart);
  }
}

// ── Cart badge button ─────────────────────────────────────────────────────────

class _CartBadgeButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _CartBadgeButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: onTap,
          ),
          if (count > 0)
            Positioned(
              top: 6,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                constraints:
                    const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Connection Error',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Could not load product details. Check your connection.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty ─────────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 56, color: AppColors.textHint),
          SizedBox(height: 16),
          Text(
            'Product not found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product content ───────────────────────────────────────────────────────────

class _ProductContent extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const _ProductContent({required this.product, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ImageSection(imageUrl: product.image),
                _InfoSection(product: product),
              ],
            ),
          ),
        ),
        _AddToCartBar(onAddToCart: onAddToCart),
      ],
    );
  }
}

// ── Image section ─────────────────────────────────────────────────────────────

class _ImageSection extends StatelessWidget {
  final String imageUrl;

  const _ImageSection({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final imageHeight = MediaQuery.of(context).size.height * 0.32;
    return Container(
      width: double.infinity,
      height: imageHeight.clamp(200.0, 320.0),
      color: AppColors.surface,
      padding: const EdgeInsets.all(24),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
        errorWidget: (_, __, ___) => const Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
        ),
      ),
    );
  }
}

// ── Info section ──────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  final Product product;

  const _InfoSection({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategoryChip(category: product.category),
          const SizedBox(height: 10),
          Text(
            product.title,
            style: theme.textTheme.titleLarge?.copyWith(height: 1.3),
          ),
          const SizedBox(height: 12),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          _RatingRow(rating: product.rating),
          const SizedBox(height: 20),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),
          Text(
            'Description',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Category chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Rating row ────────────────────────────────────────────────────────────────

class _RatingRow extends StatelessWidget {
  final Rating rating;

  const _RatingRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          if (i < rating.rate.floor()) {
            return const Icon(Icons.star_rounded,
                size: 18, color: AppColors.primary);
          } else if (i < rating.rate) {
            return const Icon(Icons.star_half_rounded,
                size: 18, color: AppColors.primary);
          }
          return const Icon(Icons.star_outline_rounded,
              size: 18, color: AppColors.primary);
        }),
        const SizedBox(width: 6),
        Text(
          '${rating.rate} (${rating.count} reviews)',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Add to cart bar ───────────────────────────────────────────────────────────

class _AddToCartBar extends StatelessWidget {
  final VoidCallback onAddToCart;

  const _AddToCartBar({required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAddToCart,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text(
              'Add to Cart',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
