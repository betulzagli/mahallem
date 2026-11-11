import 'package:flutter/material.dart';

/// Uygulamanın açık ve koyu tema durumunu yöneten reaktif tema servisi.
///
/// [ValueNotifier] aracılığıyla [ThemeMode] değişikliklerini bildirir ve uygulamanın
/// yeniden başlatılmasına gerek kalmadan temanın anında değişmesini sağlar.
class ThemeService {
  ThemeService._();

  /// Dinlenebilir aktif tema modu ([ThemeMode.light] veya [ThemeMode.dark]).
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  /// Koyu temanın aktif olup olmadığını döner.
  static bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  /// Açık ve koyu tema arasında geçiş yapar.
  static void toggleTheme() {
    themeModeNotifier.value =
        isDarkMode ? ThemeMode.light : ThemeMode.dark;
  }

  /// Temayı doğrudan belirtilen moda ayarlar.
  static void setTheme(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }
}

/// Uygulama başlık çubuğunda (AppBar) tema değiştirmeye yarayan dinamik buton.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: isDark ? Colors.amber : null,
          ),
          tooltip: isDark ? 'Açık Temaya Geç' : 'Koyu Temaya Geç',
          onPressed: () {
            ThemeService.toggleTheme();
          },
        );
      },
    );
  }
}

