import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PromoBanner extends StatefulWidget {
  final Function(String slug) onCategoryTap;

  const PromoBanner({super.key, required this.onCategoryTap});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  late PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentPage = 0;
  bool _isDragging = false;

  static const int _pageCount = 3;
  static const Duration _autoPlayDuration = Duration(seconds: 4);
  static const Duration _animationDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(_autoPlayDuration, (_) {
      if (!_isDragging && mounted) {
        final nextPage = (_currentPage + 1) % _pageCount;
        _pageController.animateToPage(
          nextPage,
          duration: _animationDuration,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.15,
      child: Column(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _isDragging = true;
                _stopAutoPlay();
              } else if (notification is ScrollEndNotification) {
                _isDragging = false;
                _startAutoPlay();
              }
              return false;
            },
            child: SizedBox(
              height: 156,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  if (mounted) {
                    setState(() => _currentPage = index);
                  }
                },
                children: [
                  _BannerSlide(
                    gradient: const [Color(0xFFFF6D00), Color(0xFFFF8F00)],
                    tag: 'LIMITED OFFER',
                    headline: 'Up to 50% off',
                    subtitle: 'On selected products',
                    cta: 'Shop now',
                    icon: Icons.local_fire_department_rounded,
                    onTap: () {}, // Decorative
                  ),
                  _BannerSlide(
                    gradient: const [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                    tag: 'NEW ARRIVALS',
                    headline: 'Latest gadgets',
                    subtitle: 'Storage, monitors and more',
                    cta: 'Explore',
                    icon: Icons.devices_rounded,
                    onTap: () => widget.onCategoryTap('electronics'),
                  ),
                  _BannerSlide(
                    gradient: const [Color(0xFFEC4899), Color(0xFFBE185D)],
                    tag: 'STYLE SALE',
                    headline: 'Min 30% off',
                    subtitle: 'On men\'s and women\'s clothing',
                    cta: 'Shop now',
                    icon: Icons.checkroom_rounded,
                    onTap: () => widget.onCategoryTap("women's clothing"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _DotsIndicator(currentPage: _currentPage, pageCount: _pageCount),
        ],
      ),
    );
  }
}

// ── Banner slide ──────────────────────────────────────────────────────────────

class _BannerSlide extends StatelessWidget {
  final List<Color> gradient;
  final String tag;
  final String headline;
  final String subtitle;
  final String cta;
  final IconData icon;
  final VoidCallback onTap;

  const _BannerSlide({
    required this.gradient,
    required this.tag,
    required this.headline,
    required this.subtitle,
    required this.cta,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background circles for depth
            Positioned(
              right: 24,
              top: 16,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 50,
              bottom: 10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Left column
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tag pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Headline
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            headline,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Subtitle
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // CTA button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cta,
                            style: TextStyle(
                              color: gradient.first,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Right icon
                  Icon(
                    icon,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dots indicator ────────────────────────────────────────────────────────────

class _DotsIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const _DotsIndicator({
    required this.currentPage,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 22 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
