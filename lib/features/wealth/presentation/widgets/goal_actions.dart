import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_event.dart';
import 'package:fincontrol/features/wealth/bloc/asset_state.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:fincontrol/features/wealth/logic/asset_math.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_event.dart';

/// Deletes a goal. Its assets go back to "Unassigned Assets" first, merged
/// with an unassigned holding of the same ticker (weighted average price) so
/// the same stock never shows twice. Assets are reloaded after the goal delete
/// has finished so they show up right away (Feedback #4).
void deleteGoalAndRefresh(BuildContext context, String goalId) {
  final assetBloc = context.read<AssetBloc>();
  final st = assetBloc.state;
  final inGoal = st is AssetLoaded
      ? st.assets.where((a) => a.portfolioId == goalId).toList()
      : <AssetModel>[];
  if (inGoal.isNotEmpty) moveAssetsToGoal(assetBloc, inGoal, '');
  context.read<PortfolioBloc>().add(
        DeletePortfolio(goalId, onDeleted: () {
          if (!assetBloc.isClosed) assetBloc.add(const LoadAssets());
        }),
      );
}

/// Moves [quantity] units of [asset] into a goal ('' = Unassigned). Moving
/// everything is the same as [moveAssetsToGoal]; a partial move splits it.
void moveQuantityToGoal(AssetBloc bloc, AssetModel asset, double quantity, String targetPortfolioId) {
  final st = bloc.state;
  final all = st is AssetLoaded ? st.assets : <AssetModel>[];
  final plan = AssetMath.planPartialMove(all, asset, quantity, targetPortfolioId);
  for (final a in plan.updates) {
    bloc.add(UpdateAsset(a));
  }
  for (final a in plan.adds) {
    bloc.add(AddAsset(a));
  }
  for (final id in plan.deletes) {
    bloc.add(DeleteAsset(id));
  }
}

/// Moves assets into a goal ('' = Unassigned), merging with a holding of the
/// same ticker already there (Feedback #6). Uses the latest data in the bloc.
void moveAssetsToGoal(AssetBloc bloc, List<AssetModel> assets, String targetPortfolioId) {
  final st = bloc.state;
  final all = st is AssetLoaded ? st.assets : <AssetModel>[];
  final plan = AssetMath.planMove(all, assets, targetPortfolioId);
  for (final a in plan.updates) {
    bloc.add(UpdateAsset(a));
  }
  for (final id in plan.deletes) {
    bloc.add(DeleteAsset(id));
  }
}
