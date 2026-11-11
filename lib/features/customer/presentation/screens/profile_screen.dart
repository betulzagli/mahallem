import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/services/theme_service.dart';
import 'addresses_screen.dart';
import 'favorites_screen.dart';
import '../../../order/presentation/screens/order_list_screen.dart';

/// Müşteri profil ekranı: Kullanıcı bilgileri, kayıtlı adresler, favoriler, siparişler,
/// işletme paneline geçiş, açık/koyu tema değişimi ve hesabı silme imkanı sağlar.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is Authenticated ? state.user : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outline, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Müşteri Hesabı',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? 'musteri@mahallem.com',
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              user?.phoneNumber ?? '0555 123 45 67',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Quick links
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.location_on_outlined, color: colorScheme.primary),
                        title: const Text('Adreslerim'),
                        subtitle: const Text('Kayıtlı teslimat adresleriniz'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddressesScreen()),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.favorite_outline, color: Color(0xFFFF795E)),
                        title: const Text('Favorilerim'),
                        subtitle: const Text('Favori esnaf ve ürünleriniz'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.receipt_long_outlined, color: colorScheme.primary),
                        title: const Text('Sipariş Geçmişim'),
                        subtitle: const Text('Tüm aktif ve tamamlanan siparişleriniz'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const OrderListScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Theme Switch Card
                Card(
                  child: ValueListenableBuilder<ThemeMode>(
                    valueListenable: ThemeService.themeModeNotifier,
                    builder: (context, mode, _) {
                      final isDark = mode == ThemeMode.dark;
                      return SwitchListTile(
                        secondary: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: isDark ? Colors.amber : colorScheme.primary,
                        ),
                        title: const Text('Karanlık Mod (Koyu Tema)'),
                        subtitle: Text(
                          isDark ? 'Koyu tema etkin' : 'Açık tema etkin',
                        ),
                        value: isDark,
                        onChanged: (_) => ThemeService.toggleTheme(),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Role Switcher
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.swap_horiz, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Panel Değiştirici',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'İşletme sahibi ekranlarını incelemek için Esnaf Paneline geçebilirsiniz.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'İşletme (Esnaf) Paneline Geç',
                        type: AppButtonType.secondary,
                        height: 44,
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                const AuthSwitchDemoRoleRequested(UserRole.business),
                              );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                AppButton(
                  text: 'Çıkış Yap',
                  type: AppButtonType.outlined,
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthSignOutRequested());
                  },
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete_forever_outlined, color: Colors.red, size: 20),
                    label: const Text(
                      'Hesabımı Sil',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => _confirmDeleteAccount(context),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Hesabımı Sil'),
          ],
        ),
        content: const Text(
          'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve tüm kayıtlı adresleriniz, sipariş geçmişiniz ve favorileriniz sistemden kalıcı olarak silinecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthBloc>().add(AuthDeleteAccountRequested());
            },
            child: const Text('Evet, Hesabımı Sil'),
          ),
        ],
      ),
    );
  }
}
