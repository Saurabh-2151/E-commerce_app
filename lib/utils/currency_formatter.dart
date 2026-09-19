class CurrencyFormatter {
  CurrencyFormatter._();

  static const double _usdToInr = 83.0;

  static String format(double usdPrice) {
    final inr = (usdPrice * _usdToInr).round();
    return '₹${_formatWithCommas(inr)}';
  }

  static String _formatWithCommas(int amount) {
    final s = amount.toString();
    if (s.length <= 3) return s;

    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);

    final buffer = StringBuffer();
    for (var i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buffer.write(',');
      buffer.write(rest[i]);
    }
    buffer.write(',');
    buffer.write(last3);
    return buffer.toString();
  }
}
