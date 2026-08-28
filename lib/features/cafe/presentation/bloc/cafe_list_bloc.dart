import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/usecases/get_cafes_usecase.dart';
import 'cafe_list_event.dart';
import 'cafe_list_state.dart';

EventTransformer<E> _debounce<E>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}

class CafeListBloc extends Bloc<CafeListEvent, CafeListState> {
  final GetCafesUseCase getCafesUseCase;

  CafeListBloc({required this.getCafesUseCase}) : super(const CafeListLoading()) {
    on<CafeListRequested>((event, emit) => _fetchCafes(event.city, emit));
    on<CafeSearchChanged>(
          (event, emit) => _fetchCafes(event.city, emit),
      transformer: _debounce(const Duration(milliseconds: 400)),
    );
  }

  Future<void> _fetchCafes(String? city, Emitter<CafeListState> emit) async {
    emit(const CafeListLoading());
    final result = await getCafesUseCase(city: city);
    result.fold(
          (failure) => emit(CafeListError(failure.message)),
          (data) => emit(CafeListLoaded(data.items)),
    );
  }
}