import 'package:equatable/equatable.dart';
import 'package:fincontrol/features/wealth/data/models/portfolio_model.dart';

abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();

  @override
  List<Object> get props => [];
}

class LoadPortfolios extends PortfolioEvent {
  final String userId;
  const LoadPortfolios(this.userId);

  @override
  List<Object> get props => [userId];
}

class ClearPortfolios extends PortfolioEvent {
  const ClearPortfolios();
}

class AddPortfolio extends PortfolioEvent {
  final PortfolioModel portfolio;
  const AddPortfolio(this.portfolio);

  @override
  List<Object> get props => [portfolio];
}

class UpdatePortfolio extends PortfolioEvent {
  final PortfolioModel portfolio;
  const UpdatePortfolio(this.portfolio);

  @override
  List<Object> get props => [portfolio];
}

class DeletePortfolio extends PortfolioEvent {
  final String id;

  /// Called after the server has deleted the goal (its assets are now
  /// unassigned on the server) — used to reload assets at the right time.
  final void Function()? onDeleted;
  const DeletePortfolio(this.id, {this.onDeleted});

  @override
  List<Object> get props => [id];
}

class PortfoliosUpdated extends PortfolioEvent {
  final List<PortfolioModel> portfolios;
  const PortfoliosUpdated(this.portfolios);
}

class PortfolioFailed extends PortfolioEvent {
  final String error;
  const PortfolioFailed(this.error);
}
