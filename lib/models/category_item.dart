class CategoryItem {
  final String slug;
  final String displayName;
  final int? itemCount;

  const CategoryItem({
    required this.slug,
    required this.displayName,
    this.itemCount,
  });

  CategoryItem copyWith({int? itemCount}) => CategoryItem(
        slug: slug,
        displayName: displayName,
        itemCount: itemCount ?? this.itemCount,
      );

  static String displayNameFromSlug(String slug) {
    const map = {
      'jewelery': 'Jewellery',
      "men's clothing": "Men's Clothing",
      "women's clothing": "Women's Clothing",
      'electronics': 'Electronics',
    };
    if (map.containsKey(slug)) return map[slug]!;
    return slug
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
