import 'package:equatable/equatable.dart';

/// Mahalle esnafını/işletmesini, çalışma saatlerini ve sipariş kabul durumunu temsil eden etki alanı varlığı.
class StoreEntity extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String category;
  final String phoneNumber;
  final String address;
  final String neighborhood;
  final bool isOpen;
  final bool isPaused;
  final bool autoReopenOnNextSchedule;
  final String openingHours;
  final String sampleImageKey;
  final String? imageUrl;
  final double sampleRouteDistanceKm;

  const StoreEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.category,
    required this.phoneNumber,
    required this.address,
    required this.neighborhood,
    this.isOpen = true,
    this.isPaused = false,
    this.autoReopenOnNextSchedule = true,
    this.openingHours = '08:00 - 21:00',
    required this.sampleImageKey,
    this.imageUrl,
    this.sampleRouteDistanceKm = 1.5,
  });

  bool get canAcceptOrders => isOpen && !isPaused;

  StoreEntity copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? category,
    String? phoneNumber,
    String? address,
    String? neighborhood,
    bool? isOpen,
    bool? isPaused,
    bool? autoReopenOnNextSchedule,
    String? openingHours,
    String? sampleImageKey,
    String? imageUrl,
    double? sampleRouteDistanceKm,
  }) {
    return StoreEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      neighborhood: neighborhood ?? this.neighborhood,
      isOpen: isOpen ?? this.isOpen,
      isPaused: isPaused ?? this.isPaused,
      autoReopenOnNextSchedule: autoReopenOnNextSchedule ?? this.autoReopenOnNextSchedule,
      openingHours: openingHours ?? this.openingHours,
      sampleImageKey: sampleImageKey ?? this.sampleImageKey,
      imageUrl: imageUrl ?? this.imageUrl,
      sampleRouteDistanceKm: sampleRouteDistanceKm ?? this.sampleRouteDistanceKm,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        description,
        category,
        phoneNumber,
        address,
        neighborhood,
        isOpen,
        isPaused,
        autoReopenOnNextSchedule,
        openingHours,
        sampleImageKey,
        imageUrl,
        sampleRouteDistanceKm,
      ];
}
