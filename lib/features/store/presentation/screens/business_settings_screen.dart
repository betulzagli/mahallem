import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/store_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/store_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/sample_data.dart';
import '../../../../core/services/theme_service.dart';

/// Esnaf dükkan ayarları ekranı: Dükkanı kapatma/açma (otomatik açılma tercihiyle),
/// sipariş kabulünü geçici duraklatma (mola), çalışma saatleri, müşteri moduna geçiş ve çıkış.
class BusinessSettingsScreen extends StatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  State<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  void _showCloseStoreModal(BuildContext context, StoreEntity store) {
    bool autoReopen = store.autoReopenOnNextSchedule;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Mağazayı Kapatma Seçenekleri',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => setModalState(() => autoReopen = true),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          autoReopen ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: autoReopen ? Theme.of(context).colorScheme.primary : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bir sonraki planlı açılış saatinde otomatik açıl',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Text('Örn: Yarın sabah 08:00',
                                  style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => setModalState(() => autoReopen = false),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          !autoReopen ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: !autoReopen ? Theme.of(context).colorScheme.primary : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ben açana kadar kapalı tut',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Text('Manuel olarak tekrar açana kadar kapalı kalır',
                                  style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Mağazayı Kapat',
                  onPressed: () {
                    context.read<StoreBloc>().add(
                          StoreOpenStatusToggled(
                            storeId: store.id,
                            isOpen: false,
                            autoReopen: autoReopen,
                          ),
                        );
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = context.read<AuthBloc>().state;
    final storeId = (authState is Authenticated && authState.user.storeId != null)
        ? authState.user.storeId!
        : 'store_1';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mağaza Ayarları'),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: BlocBuilder<StoreBloc, StoreState>(
        builder: (context, state) {
          final stores = state is StoreLoaded ? state.stores : SampleData.stores;
          final store = stores.firstWhere(
            (s) => s.id == storeId,
            orElse: () => stores.first,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Store Status Card
                Material(
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: colorScheme.outline, width: 0.8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mağaza Açık / Kapalı Durumu',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(store.isOpen ? 'Mağaza Açık' : 'Mağaza Kapalı'),
                        subtitle: Text(
                          store.isOpen
                              ? 'Yeni sipariş kabul ediliyor'
                              : (store.autoReopenOnNextSchedule
                                  ? 'Kapalı (Planlı saatte otomatik açılacak)'
                                  : 'Süresiz kapalı tutuluyor'),
                          style: TextStyle(
                            color: store.isOpen ? Colors.green.shade800 : Colors.red.shade800,
                            fontSize: 12,
                          ),
                        ),
                        value: store.isOpen,
                        onChanged: (val) {
                          if (!val) {
                            _showCloseStoreModal(context, store);
                          } else {
                            context.read<StoreBloc>().add(
                                  StoreOpenStatusToggled(
                                    storeId: store.id,
                                    isOpen: true,
                                    autoReopen: true,
                                  ),
                                );
                          }
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Siparişleri Geçici Duraklat'),
                        subtitle: const Text(
                          'Yoğunluk nedeniyle yeni sipariş akışını geçici olarak durdurur',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: store.isPaused,
                        onChanged: (val) {
                          context.read<StoreBloc>().add(
                                StorePauseStatusToggled(
                                  storeId: store.id,
                                  isPaused: val,
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                ),
              ),

                const SizedBox(height: 16),

                // Store Info
                Material(
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: colorScheme.outline, width: 0.8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mağaza Bilgileri',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Text('Dükkan Adı: ${store.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Kategori: ${store.category}'),
                      const SizedBox(height: 4),
                      Text('Çalışma Saatleri: ${store.openingHours}'),
                      const SizedBox(height: 4),
                      Text('Telefon: ${store.phoneNumber}'),
                      const SizedBox(height: 4),
                      Text('Adres: ${store.address} (${store.neighborhood})'),
                    ],
                  ),
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
                      const Text('Panel Değiştirici',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 4),
                      const Text(
                        'Müşteri alışveriş deneyimini incelemek için Müşteri Paneline geçebilirsiniz.',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'Müşteri Paneline Geç',
                        type: AppButtonType.secondary,
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                const AuthSwitchDemoRoleRequested(UserRole.customer),
                              );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                AppButton(
                  text: 'Oturumu Kapat',
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
                      'İşletme Hesabını Sil',
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
            Text('İşletme Hesabını Sil'),
          ],
        ),
        content: const Text(
          'İşletme hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz; dükkan profiliniz, ürünleriniz ve sipariş kayıtlarınız sistemden kalıcı olarak silinecektir.',
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
