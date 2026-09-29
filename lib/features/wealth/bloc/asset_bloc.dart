import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_event.dart';
import 'package:fincontrol/features/wealth/bloc/asset_state.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:fincontrol/features/wealth/data/repositories/asset_repository.dart';
import 'package:fincontrol/features/wealth/data/repositories/market_api_repository.dart';

class AssetBloc extends Bloc<AssetEvent, AssetState> {
  final AssetRepository _assetRepository;
  final MarketApiRepository _marketApiRepository;
  StreamSubscription? _assetSubscription;
  Timer? _syncTimer;

  AssetBloc({
    required AssetRepository assetRepository,
    required MarketApiRepository marketApiRepository,
  })  : _assetRepository = assetRepository,
        _marketApiRepository = marketApiRepository,
        super(AssetInitial()) {
    on<LoadAssets>(_onLoadAssets);
    on<ClearAssets>(_onClearAssets);
    on<AddAsset>(_onAddAsset);
    on<UpdateAsset>(_onUpdateAsset);
    on<DeleteAsset>(_onDeleteAsset);
    on<SyncAssetPrices>(_onSyncAssetPrices);
    on<AssetsUpdated>((event, emit) => emit(AssetLoaded(event.assets)));
    on<AssetFailed>((event, emit) => emit(AssetError(event.error)));
  }

  void _onLoadAssets(LoadAssets event, Emitter<AssetState> emit) async {
    if (state is! AssetLoaded) emit(AssetLoading());
    await _assetSubscription?.cancel();
    _assetSubscription = _assetRepository.getAssets(event.portfolioId).listen(
      (assets) {
        if (!isClosed) {
          add(AssetsUpdated(assets));
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(AssetFailed(error.toString()));
        }
      },
    );

    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 109), (_) {
      if (!isClosed) {
        add(SyncAssetPrices(event.portfolioId));
      }
    });

    if (!isClosed) {
      add(SyncAssetPrices(event.portfolioId));
    }
  }

  void _onClearAssets(ClearAssets event, Emitter<AssetState> emit) async {
    _syncTimer?.cancel();
    _syncTimer = null;
    await _assetSubscription?.cancel();
    _assetSubscription = null;
    emit(AssetInitial());
  }

  void _onAddAsset(AddAsset event, Emitter<AssetState> emit) async {
    try {
      await _assetRepository.addAsset(event.asset);
      add(const LoadAssets());
    } catch (e) {
      if (!isClosed) emit(AssetError(e.toString()));
    }
  }

  void _onUpdateAsset(UpdateAsset event, Emitter<AssetState> emit) async {
    try {
      await _assetRepository.updateAsset(event.asset);
      add(const LoadAssets());
    } catch (e) {
      if (!isClosed) emit(AssetError(e.toString()));
    }
  }

  void _onDeleteAsset(DeleteAsset event, Emitter<AssetState> emit) async {
    try {
      await _assetRepository.deleteAsset(event.id);
      add(const LoadAssets());
    } catch (e) {
      if (!isClosed) emit(AssetError(e.toString()));
    }
  }

  void _onSyncAssetPrices(SyncAssetPrices event, Emitter<AssetState> emit) async {
    try {
      final currentState = state;
      if (currentState is AssetLoaded) {
        bool changed = false;
        List<AssetModel>? fresh; // loaded lazily, only if a price changed
        bool freshLoaded = false;
        for (final asset in currentState.assets) {
          if (asset.tickerSymbol.isEmpty) continue;

          double price = 0.0;
          if (asset.category == 'Stocks' || asset.category == 'Stock') {
            price = await _marketApiRepository.getStockPrice(asset.tickerSymbol);
          } else if (asset.category == 'Crypto' || asset.category == 'Cryptocurrency') {
            price = await _marketApiRepository.getCryptoPrice(asset.tickerSymbol);
          }

          if (price > 0 && price != asset.currentPrice) {
            // Write the price onto a FRESH copy from the server: the in-memory
            // list may be stale (e.g. the asset was just moved to/from a goal)
            // and writing the old copy back would silently undo that change.
            if (!freshLoaded) {
              freshLoaded = true;
              try {
                fresh = await _assetRepository.getAssets().first;
              } catch (_) {
                fresh = null; // fall back to the in-memory copy
              }
            }
            AssetModel? base = asset;
            if (fresh != null) {
              base = null;
              for (final f in fresh) {
                if (f.id == asset.id) base = f;
              }
            }
            if (base == null) continue; // deleted in the meantime
            await _assetRepository.updateAsset(base.copyWith(currentPrice: price));
            changed = true;
          }
        }
        if (changed) {
          add(const LoadAssets());
        }
      }
    } catch (e) {
      // Fail silently for background syncs to avoid disrupting the UI
      debugPrint('Sync error: $e');
    }
  }

  @override
  Future<void> close() {
    _syncTimer?.cancel();
    _assetSubscription?.cancel();
    return super.close();
  }
}
