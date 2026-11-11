import 'package:equatable/equatable.dart';

/// Kullanıcı rolü: Müşteri ([customer]) veya Mahalle Esnafı / İşletme ([business]).
enum UserRole { customer, business }

/// Kimlik doğrulaması yapılmış kullanıcıyı temsil eden etki alanı (domain) varlığı.
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final UserRole role;
  final String? storeId;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.role,
    this.storeId,
    required this.createdAt,
  });

  bool get isCustomer => role == UserRole.customer;
  bool get isBusiness => role == UserRole.business;

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    UserRole? role,
    String? storeId,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, fullName, phoneNumber, role, storeId, createdAt];
}

