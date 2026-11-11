import 'package:flutter/material.dart';

class DemoModeBadge extends StatelessWidget {
  final bool isLiveFirebase;

  const DemoModeBadge({
    super.key,
    required this.isLiveFirebase,
  });

  @override
  Widget build(BuildContext context) {
    if (isLiveFirebase) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.green.shade700, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_done, size: 14, color: Colors.green.shade700),
            const SizedBox(width: 4),
            Text(
              'Firebase Canlı',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF3158C9)),
                SizedBox(width: 8),
                Text('Sistem Modu Bilgisi'),
              ],
            ),
            content: const Text(
              'Uygulama şu anda Bağımsız Demo / Simülasyon Modunda çalışmaktadır.\n\n'
              'Firebase yapılandırması (firebase_options.dart / google-services.json) henüz projeye bağlanmadığı için '
              'tüm kimlik doğrulama, sipariş ve mağaza işlemleri yerel simülasyon ve mock veri sağlayıcısı ile güvenle çalıştırılmaktadır.\n\n'
              'Canlı Firebase\'e geçmek için Firebase CLI ile flutterfire configure çalıştırmanız ve '
              'firestore.rules dosyasını Firestore konsoluna dağıtmanız yeterlidir.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Anladım'),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.amber.shade800, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.science_outlined, size: 14, color: Colors.amber.shade900),
            const SizedBox(width: 4),
            Text(
              'Demo / Simülasyon Modu',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.amber.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

