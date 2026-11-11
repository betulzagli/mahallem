import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/store_entity.dart';
import '../../domain/repositories/store_repository.dart';

// Events
/// İşletme yönetimi olaylarının temel sınıfı.
abstract class StoreEvent extends Equatable {
  const StoreEvent();
  @override
  List<Object?> get props => [];
}

/// Tüm mağazaları yükleme olayı.
class StoresLoadRequested extends StoreEvent {}

/// Belirli bir mağazayı seçme ve detayını getirme olayı.
class StoreSelectRequested extends StoreEvent {
  final String storeId;
  const StoreSelectRequested(this.storeId);
  @override
  List<Object?> get props => [storeId];
}

/// Mağazanın açık/kapalı durumunu değiştirme olayı.
class StoreOpenStatusToggled extends StoreEvent {
  final String storeId;
  final bool isOpen;
  final bool autoReopen;
  const StoreOpenStatusToggled({
    required this.storeId,
    required this.isOpen,
    required this.autoReopen,
  });
  @override
  List<Object?> get props => [storeId, isOpen, autoReopen];
}

/// Mağazanın sipariş kabulünü geçici duraklatma olayı.
class StorePauseStatusToggled extends StoreEvent {
  final String storeId;
  final bool isPaused;
  const StorePauseStatusToggled({required this.storeId, required this.isPaused});
  @override
  List<Object?> get props => [storeId, isPaused];
}

/// Mağaza bilgilerini güncelleme olayı.
class StoreUpdateRequested extends StoreEvent {
  final StoreEntity store;
  const StoreUpdateRequested(this.store);
  @override
  List<Object?> get props => [store];
}

// States
/// İşletme durumlarının temel sınıfı.
abstract class StoreState extends Equatable {
  const StoreState();
  @override
  List<Object?> get props => [];
}

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

class StoreLoaded extends StoreState {
  final List<StoreEntity> stores;
  final StoreEntity? selectedStore;
  const StoreLoaded({required this.stores, this.selectedStore});
  @override
  List<Object?> get props => [stores, selectedStore];
}

class StoreFailure extends StoreState {
  final String message;
  const StoreFailure(this.message);
  @override
  List<Object?> get props => [message];
}

/// İşletme listeleme, çalışma saati ve duraklatma ayarlarını yöneten BLoC.
class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final StoreRepository _storeRepository;

  StoreBloc({required StoreRepository storeRepository})
      : _storeRepository = storeRepository,
        super(StoreInitial()) {
    on<StoresLoadRequested>(_onLoadStores);
    on<StoreSelectRequested>(_onSelectStore);
    on<StoreOpenStatusToggled>(_onToggleOpen);
    on<StorePauseStatusToggled>(_onTogglePause);
    on<StoreUpdateRequested>(_onUpdateStore);
  }

  Future<void> _onLoadStores(
      StoresLoadRequested event, Emitter<StoreState> emit) async {
    emit(StoreLoading());
    try {
      final stores = await _storeRepository.getStores();
      emit(StoreLoaded(stores: stores, selectedStore: stores.isNotEmpty ? stores.first : null));
    } catch (e) {
      emit(StoreFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSelectStore(
      StoreSelectRequested event, Emitter<StoreState> emit) async {
    try {
      final store = await _storeRepository.getStoreById(event.storeId);
      final currentStores = state is StoreLoaded ? (state as StoreLoaded).stores : await _storeRepository.getStores();
      emit(StoreLoaded(stores: currentStores, selectedStore: store));
    } catch (e) {
      emit(StoreFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onToggleOpen(
      StoreOpenStatusToggled event, Emitter<StoreState> emit) async {
    try {
      await _storeRepository.toggleStoreOpenStatus(
        event.storeId,
        event.isOpen,
        event.autoReopen,
      );
      add(StoresLoadRequested());
    } catch (e) {
      emit(StoreFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onTogglePause(
      StorePauseStatusToggled event, Emitter<StoreState> emit) async {
    try {
      await _storeRepository.toggleStorePauseStatus(event.storeId, event.isPaused);
      add(StoresLoadRequested());
    } catch (e) {
      emit(StoreFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateStore(
      StoreUpdateRequested event, Emitter<StoreState> emit) async {
    try {
      await _storeRepository.updateStore(event.store);
      add(StoresLoadRequested());
    } catch (e) {
      emit(StoreFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

