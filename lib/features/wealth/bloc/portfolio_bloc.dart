import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_event.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_state.dart';
import 'package:fincontrol/features/wealth/data/repositories/portfolio_repository.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final PortfolioRepository _portfolioRepository;
  StreamSubscription? _portfolioSubscription;

  PortfolioBloc({required PortfolioRepository portfolioRepository})
      : _portfolioRepository = portfolioRepository,
        super(PortfolioInitial()) {
    on<LoadPortfolios>(_onLoadPortfolios);
    on<AddPortfolio>(_onAddPortfolio);
    on<UpdatePortfolio>(_onUpdatePortfolio);
    on<DeletePortfolio>(_onDeletePortfolio);
    on<PortfoliosUpdated>((event, emit) => emit(PortfolioLoaded(event.portfolios)));
    on<PortfolioFailed>((event, emit) => emit(PortfolioError(event.error)));
  }

  void _onLoadPortfolios(LoadPortfolios event, Emitter<PortfolioState> emit) async {
    // Only show loading on first load, not on refreshes (prevents flicker)
    if (state is! PortfolioLoaded) emit(PortfolioLoading());
    await _portfolioSubscription?.cancel();
    _portfolioSubscription = _portfolioRepository.getPortfolios(event.userId).listen(
      (portfolios) {
        if (!isClosed) {
          add(PortfoliosUpdated(portfolios));
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(PortfolioFailed(error.toString()));
        }
      },
    );
  }

  void _onAddPortfolio(AddPortfolio event, Emitter<PortfolioState> emit) async {
    try {
      await _portfolioRepository.addPortfolio(event.portfolio);
      // Reload from server
      add(const LoadPortfolios(''));
    } catch (e) {
      if (!isClosed) emit(PortfolioError(e.toString()));
    }
  }

  void _onUpdatePortfolio(UpdatePortfolio event, Emitter<PortfolioState> emit) async {
    try {
      await _portfolioRepository.updatePortfolio(event.portfolio);
      add(const LoadPortfolios(''));
    } catch (e) {
      if (!isClosed) emit(PortfolioError(e.toString()));
    }
  }

  void _onDeletePortfolio(DeletePortfolio event, Emitter<PortfolioState> emit) async {
    try {
      await _portfolioRepository.deletePortfolio(event.id);
      add(const LoadPortfolios(''));
    } catch (e) {
      if (!isClosed) emit(PortfolioError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _portfolioSubscription?.cancel();
    return super.close();
  }
}
