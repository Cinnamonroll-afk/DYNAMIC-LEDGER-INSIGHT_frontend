import 'package:equatable/equatable.dart';
import 'package:fincontrol/features/wealth/data/models/portfolio_model.dart';

abstract class PortfolioState extends Equatable {
  const PortfolioState();
  
  @override
  List<Object> get props => [];
}

class PortfolioInitial extends PortfolioState {}

class PortfolioLoading extends PortfolioState {}

class PortfolioLoaded extends PortfolioState {
  final List<PortfolioModel> portfolios;
  
  const PortfolioLoaded(this.portfolios);
  
  @override
  List<Object> get props => [portfolios];
}

class PortfolioError extends PortfolioState {
  final String message;
  
  const PortfolioError(this.message);
  
  @override
  List<Object> get props => [message];
}
