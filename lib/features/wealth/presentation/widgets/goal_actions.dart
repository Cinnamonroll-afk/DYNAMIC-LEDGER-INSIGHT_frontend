import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_event.dart';
import 'package:fincontrol/features/wealth/bloc/asset_state.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:fincontrol/features/wealth/logic/asset_math.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_event.dart';

/// Deletes a goal. Its assets become unassigned on the server; assets are
/// reloaded only after the delete has finished so they show up right away
/// under "Unassigned Assets" (Feedback #4).
void deleteGoalAndRefresh(BuildContext context, String goalId) {
  final assetBloc = context.read<AssetBloc>();
  context.read<PortfolioBloc>().add(
        DeletePortfolio(goalId, onDeleted: () {
          if (!assetBloc.isClosed) assetBloc.add(const LoadAssets());
        }),
      );
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
