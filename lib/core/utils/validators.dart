/// Form alanlarındaki kullanıcı girdilerini doğrulayan yardımcı sınıf.
class Validators {
  Validators._();

  /// E-posta formatını doğrular.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi boş bırakılamaz';
    }
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi giriniz';
    }
    return null;
  }

  /// Şifre uzunluğunu kontrol eder (en az 6 karakter).
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş bırakılamaz';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    return null;
  }

  /// Zorunlu alan kontrolü yapar.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName alanı zorunludur';
    }
    return null;
  }

  /// Telefon numarası formatını kontrol eder (en az 10 hane).
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon numarası zorunludur';
    }
    final clean = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (clean.length < 10) {
      return 'Geçerli bir telefon numarası giriniz (en az 10 hane)';
    }
    return null;
  }

  /// Pozitif sayısal girdi kontrolü yapar.
  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName zorunludur';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return '$fieldName pozitif bir sayı olmalıdır';
    }
    return null;
  }

  /// Stok tam sayısı kontrolü yapar (0 veya daha büyük).
  static String? validateStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Stok miktarı zorunludur';
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 0) {
      return 'Stok geçerli bir tam sayı olmalıdır';
    }
    return null;
  }
}

