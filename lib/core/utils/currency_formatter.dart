/// Para birimi ve fiyat formatlama işlemlerini standartlaştıran yardımcı sınıf.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Verilen sayısal tutarı iki ondalıklı ve 'TL' ibareli metne dönüştürür (Örn: 45.50 TL).
  static String format(double amount) {
    return '${amount.toStringAsFixed(2)} TL';
  }
}

