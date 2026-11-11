import 'package:equatable/equatable.dart';

/// Müşteri teslimat adresini temsil eden etki alanı varlığı.
class AddressEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String neighborhood;
  final String fullAddress;
  final String? deliveryNote;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.neighborhood = 'Gültepe Mahallesi',
    required this.fullAddress,
    this.deliveryNote,
    this.isDefault = false,
  });

  AddressEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? neighborhood,
    String? fullAddress,
    String? deliveryNote,
    bool? isDefault,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      neighborhood: neighborhood ?? this.neighborhood,
      fullAddress: fullAddress ?? this.fullAddress,
      deliveryNote: deliveryNote ?? this.deliveryNote,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        neighborhood,
        fullAddress,
        deliveryNote,
        isDefault,
      ];
}

