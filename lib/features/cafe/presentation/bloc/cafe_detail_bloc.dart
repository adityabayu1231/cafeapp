import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_cafe_detail_usecase.dart';
import 'cafe_detail_event.dart';
import 'cafe_detail_state.dart';

class CafeDetailBloc extends Bloc<CafeDetailEvent, CafeDetailState> {
  final GetCafeDetailUseCase getCafeDetailUseCase;

  CafeDetailBloc({required this.getCafeDetailUseCase}) : super(const CafeDetailLoading()) {
    on<CafeDetailRequested>(_onCafeDetailRequested);
  }

  Future<void> _onCafeDetailRequested(CafeDetailRequested event, Emitter<CafeDetailState> emit) async {
    emit(const CafeDetailLoading());
    final result = await getCafeDetailUseCase(event.cafeId);
    result.fold(
          (failure) => emit(CafeDetailError(failure.message)),
          (detail) => emit(CafeDetailLoaded(detail)),
    );
  }
}