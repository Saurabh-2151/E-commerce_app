import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/category_item.dart';
import '../providers/cart_provider.dart';
import '../providers/catalog_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/promo_banner.dart';
import 'cart_screen.dart';
import 'product_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadCategories();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<CatalogProvider>().loadCategories(force: true);
  }

  void _onCategoryTap(CategoryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListScreen(category: item),
      ),
    );
  }

  void _onBannerCategoryTap(String slug) {
    final catalog = context.read<CatalogProvider>();
    final category = catalog.categories
        .cast<CategoryItem?>()
        .firstWhere((c) => c?.slug == slug, orElse: () => null);
    if (category != null) {
      _onCategoryTap(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                size: 17,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            const Text('ShopEasy'),
          ],
        ),
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
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _onRefresh,
        child: Consumer<CatalogProvider>(
          builder: (context, catalog, _) {
            if (catalog.isLoading) return const _ShimmerDashboard();
            if (catalog.status == CatalogStatus.error) {
              return _ErrorView(
                message: catalog.errorMessage,
                onRetry: () =>
                    context.read<CatalogProvider>().loadCategories(force: true),
              );
            }
            return _DashboardBody(
              categories: catalog.categories,
              onCategoryTap: _onCategoryTap,
              onBannerCategoryTap: _onBannerCategoryTap,
            );
          },
        ),
      ),
    );
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

// ── Dashboard body ────────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  final List<CategoryItem> categories;
  final ValueChanged<CategoryItem> onCategoryTap;
  final Function(String slug) onBannerCategoryTap;

  const _DashboardBody({
    required this.categories,
    required this.onCategoryTap,
    required this.onBannerCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Hello, Shopper',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.waving_hand_rounded,
                      size: 16,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'What are you\nlooking for today?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PromoBanner(onCategoryTap: onBannerCategoryTap),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Row(
              children: [
                const Text(
                  'Shop by Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${categories.length} categories',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 14)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _CategoryCard(
                item: categories[index],
                onTap: () => onCategoryTap(categories[index]),
              ),
              childCount: categories.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Category card ─────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final CategoryItem item;
  final VoidCallback onTap;

  const _CategoryCard({required this.item, required this.onTap});

  static const Map<String, IconData> _icons = {
    'electronics': Icons.devices_rounded,
    'jewelery': Icons.diamond_rounded,
    "men's clothing": Icons.checkroom_rounded,
    "women's clothing": Icons.dry_cleaning_rounded,
  };

  static const Map<String, List<Color>> _gradients = {
    'electronics': [Color(0xFF3B82F6), Color(0xFF1E40AF)],
    'jewelery': [Color(0xFFF59E0B), Color(0xFFD97706)],
    "men's clothing": [Color(0xFF14B8A6), Color(0xFF0F766E)],
    "women's clothing": [Color(0xFFEC4899), Color(0xFFBE185D)],
  };

  static const List<Color> _fallbackGradient = [
    Color(0xFF6B7280),
    Color(0xFF374151),
  ];

  IconData get _icon => _icons[item.slug] ?? Icons.category_rounded;
  List<Color> get _gradient =>
      _gradients[item.slug] ?? _fallbackGradient;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Positioned(
                right: -16,
                bottom: -16,
                child: Icon(
                  _icon,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_icon, color: Colors.white, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    item.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _ItemCountText(count: item.itemCount),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Item count text ───────────────────────────────────────────────────────────

class _ItemCountText extends StatelessWidget {
  final int? count;

  const _ItemCountText({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == null) {
      // Loading or failed - show placeholder
      return SizedBox(
        width: 40,
        height: 16,
        child: Shimmer.fromColors(
          baseColor: Colors.white.withValues(alpha: 0.3),
          highlightColor: Colors.white.withValues(alpha: 0.5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
    }

    final itemText = count == 1 ? '1 item' : '$count items';
    return Text(
      itemText,
      style: TextStyle(
        fontSize: 12,
        color: Colors.white.withValues(alpha: 0.8),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ── Shimmer skeleton ──────────────────────────────────────────────────────────

class _ShimmerDashboard extends StatelessWidget {
  const _ShimmerDashboard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerBox(120, 16),
            const SizedBox(height: 8),
            _shimmerBox(200, 22),
            const SizedBox(height: 20),
            _shimmerBox(double.infinity, 156, radius: 20),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Container(
                  width: i == 0 ? 22 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _shimmerBox(160, 16),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                4,
                (_) => _shimmerBox(double.infinity, double.infinity,
                    radius: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double w, double h, {double radius = 8}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

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
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
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
