import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fincontrol/features/wealth/bloc/asset_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_event.dart';
import 'package:fincontrol/features/wealth/bloc/asset_state.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:fincontrol/features/wealth/data/repositories/asset_repository.dart';
import 'package:fincontrol/features/wealth/data/repositories/market_api_repository.dart';

class MockAssetRepository extends Mock implements AssetRepository {}
class MockMarketApiRepository extends Mock implements MarketApiRepository {}

AssetModel _asset({
  String id = 'a1',
  String category = 'Stocks',
  String ticker = 'AAPL',
  double currentPrice = 175.0,
}) =>
    AssetModel(
      id: id,
      userId: 'user1',
      portfolioId: 'port1',
      name: 'Apple',
      tickerSymbol: ticker,
      category: category,
      totalQuantity: 10.0,
      averageBuyPrice: 150.0,
      currentPrice: currentPrice,
    );

void main() {
  late MockAssetRepository mockAssetRepo;
  late MockMarketApiRepository mockMarketRepo;

  setUp(() {
    mockAssetRepo = MockAssetRepository();
    mockMarketRepo = MockMarketApiRepository();
    registerFallbackValue(_asset());
  });

  test('initial state is AssetInitial', () {
    final bloc = AssetBloc(
      assetRepository: mockAssetRepo,
      marketApiRepository: mockMarketRepo,
    );
    expect(bloc.state, isA<AssetInitial>());
    bloc.close();
  });

  group('AssetsUpdated', () {
    blocTest<AssetBloc, AssetState>(
      'emits AssetLoaded with given assets',
      build: () => AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo),
      act: (bloc) => bloc.add(AssetsUpdated([_asset()])),
      expect: () => [
        predicate<AssetState>((s) => s is AssetLoaded && s.assets.length == 1),
      ],
    );

    blocTest<AssetBloc, AssetState>(
      'emits AssetLoaded with empty list',
      build: () => AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo),
      act: (bloc) => bloc.add(const AssetsUpdated([])),
      expect: () => [
        predicate<AssetState>((s) => s is AssetLoaded && s.assets.isEmpty),
      ],
    );
  });

  group('AssetFailed', () {
    blocTest<AssetBloc, AssetState>(
      'emits AssetError with the error message',
      build: () => AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo),
      act: (bloc) => bloc.add(AssetFailed('something broke')),
      expect: () => [
        predicate<AssetState>((s) => s is AssetError && s.message == 'something broke'),
      ],
    );
  });

  group('LoadAssets', () {
    blocTest<AssetBloc, AssetState>(
      'emits [AssetLoading, AssetLoaded] with empty list',
      build: () {
        when(() => mockAssetRepo.getAssets(any()))
            .thenAnswer((_) => Stream.fromIterable([[]]));
        // SyncAssetPrices dispatched right after — empty list, no API calls needed
        return AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo);
      },
      act: (bloc) => bloc.add(const LoadAssets()),
      expect: () => [
        isA<AssetLoading>(),
        predicate<AssetState>((s) => s is AssetLoaded && s.assets.isEmpty),
      ],
    );

    blocTest<AssetBloc, AssetState>(
      'does NOT emit AssetLoading when already in AssetLoaded state',
      build: () {
        when(() => mockAssetRepo.getAssets(any()))
            .thenAnswer((_) => Stream.fromIterable([[_asset(id: 'a2')]]));
        return AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo);
      },
      seed: () => AssetLoaded([_asset(id: 'a1')]),
      act: (bloc) => bloc.add(const LoadAssets()),
      expect: () => [
        predicate<AssetState>((s) => s is AssetLoaded && s.assets.first.id == 'a2'),
      ],
    );

    blocTest<AssetBloc, AssetState>(
      'emits AssetError when stream errors',
      build: () {
        when(() => mockAssetRepo.getAssets(any()))
            .thenAnswer((_) => Stream.error(Exception('db error')));
        return AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo);
      },
      act: (bloc) => bloc.add(const LoadAssets()),
      expect: () => [
        isA<AssetLoading>(),
        isA<AssetError>(),
      ],
    );
  });

  group('AddAsset', () {
    blocTest<AssetBloc, AssetState>(
      'calls addAsset on repository',
      build: () {
        when(() => mockAssetRepo.addAsset(any())).thenAnswer((_) async {});
        when(() => mockAssetRepo.getAssets(any()))
            .thenAnswer((_) => Stream.fromIterable([[]]));
        return AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo);
      },
      act: (bloc) => bloc.add(AddAsset(_asset(id: 'new'))),
      verify: (_) => verify(() => mockAssetRepo.addAsset(any())).called(1),
    );

    blocTest<AssetBloc, AssetState>(
      'emits AssetError when addAsset throws',
      build: () {
        when(() => mockAssetRepo.addAsset(any()))
            .thenThrow(Exception('add failed'));
        return AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo);
      },
      act: (bloc) => bloc.add(AddAsset(_asset(id: 'new'))),
      expect: () => [isA<AssetError>()],
    );
  });

  group('UpdateAsset', () {
    blocTest<AssetBloc, AssetState>(
      'calls updateAsset on repository',
      build: () {
        when(() => mockAssetRepo.updateAsset(any())).thenAnswer((_) async {});
        when(() => mockAssetRepo.getAssets(any()))
            .thenAnswer((_) => Stream.fromIterable([[]]));
        return AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo);
      },
      act: (bloc) => bloc.add(UpdateAsset(_asset())),
      verify: (_) => verify(() => mockAssetRepo.updateAsset(any())).called(1),
    );

    blocTest<AssetBloc, AssetState>(
      'emits AssetError when updateAsset throws',
      build: () {
        when(() => mockAssetRepo.updateAsset(any()))
            .thenThrow(Exception('update failed'));
        return AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo);
      },
      act: (bloc) => bloc.add(UpdateAsset(_asset())),
      expect: () => [isA<AssetError>()],
    );
  });

  group('DeleteAsset', () {
    blocTest<AssetBloc, AssetState>(
      'calls deleteAsset on repository',
      build: () {
        when(() => mockAssetRepo.deleteAsset(any())).thenAnswer((_) async {});
        when(() => mockAssetRepo.getAssets(any()))
            .thenAnswer((_) => Stream.fromIterable([[]]));
        return AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo);
      },
      act: (bloc) => bloc.add(DeleteAsset('a1')),
      verify: (_) => verify(() => mockAssetRepo.deleteAsset(any())).called(1),
    );

    blocTest<AssetBloc, AssetState>(
      'emits AssetError when deleteAsset throws',
      build: () {
        when(() => mockAssetRepo.deleteAsset(any()))
            .thenThrow(Exception('delete failed'));
        return AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo);
      },
      act: (bloc) => bloc.add(DeleteAsset('a1')),
      expect: () => [isA<AssetError>()],
    );
  });

  group('SyncAssetPrices', () {
    blocTest<AssetBloc, AssetState>(
      'does nothing when state is not AssetLoaded',
      build: () => AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo),
      act: (bloc) => bloc.add(const SyncAssetPrices()),
      expect: () => [],
    );

    blocTest<AssetBloc, AssetState>(
      'does nothing when asset list is empty',
      build: () => AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo),
      seed: () => const AssetLoaded([]),
      act: (bloc) => bloc.add(const SyncAssetPrices()),
      expect: () => [],
    );

    blocTest<AssetBloc, AssetState>(
      'skips assets with empty tickerSymbol',
      build: () => AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo),
      seed: () => AssetLoaded([_asset(ticker: '', category: 'Stocks')]),
      act: (bloc) => bloc.add(const SyncAssetPrices()),
      verify: (_) {
        verifyNever(() => mockMarketRepo.getStockPrice(any()));
        verifyNever(() => mockMarketRepo.getCryptoPrice(any()));
      },
      expect: () => [],
    );

    blocTest<AssetBloc, AssetState>(
      'skips assets with non-stock/crypto category',
      build: () => AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo),
      seed: () => AssetLoaded([_asset(ticker: 'FUND1', category: 'Mutual Fund')]),
      act: (bloc) => bloc.add(const SyncAssetPrices()),
      verify: (_) {
        verifyNever(() => mockMarketRepo.getStockPrice(any()));
        verifyNever(() => mockMarketRepo.getCryptoPrice(any()));
      },
      expect: () => [],
    );

    blocTest<AssetBloc, AssetState>(
      'calls getStockPrice for Stocks category',
      build: () {
        when(() => mockMarketRepo.getStockPrice('AAPL')).thenAnswer((_) async => 175.0);
        return AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo);
      },
      seed: () => AssetLoaded([_asset(category: 'Stocks', ticker: 'AAPL', currentPrice: 175.0)]),
      act: (bloc) => bloc.add(const SyncAssetPrices()),
      verify: (_) => verify(() => mockMarketRepo.getStockPrice('AAPL')).called(1),
    );

    blocTest<AssetBloc, AssetState>(
      'calls getCryptoPrice for Crypto category',
      build: () {
        when(() => mockMarketRepo.getCryptoPrice('BTC-USD')).thenAnswer((_) async => 30000.0);
        return AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo);
      },
      seed: () => AssetLoaded([_asset(category: 'Crypto', ticker: 'BTC-USD', currentPrice: 30000.0)]),
      act: (bloc) => bloc.add(const SyncAssetPrices()),
      verify: (_) => verify(() => mockMarketRepo.getCryptoPrice('BTC-USD')).called(1),
    );

    blocTest<AssetBloc, AssetState>(
      'calls updateAsset when new price differs from current price',
      build: () {
        when(() => mockMarketRepo.getStockPrice('AAPL')).thenAnswer((_) async => 200.0);
        when(() => mockAssetRepo.updateAsset(any())).thenAnswer((_) async {});
        when(() => mockAssetRepo.getAssets(any()))
            .thenAnswer((_) => Stream.fromIterable([[]]));
        return AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo);
      },
      seed: () => AssetLoaded([_asset(category: 'Stocks', ticker: 'AAPL', currentPrice: 175.0)]),
      act: (bloc) => bloc.add(const SyncAssetPrices()),
      verify: (_) => verify(() => mockAssetRepo.updateAsset(any())).called(1),
    );

    blocTest<AssetBloc, AssetState>(
      'does NOT call updateAsset when price is 0',
      build: () {
        when(() => mockMarketRepo.getStockPrice('AAPL')).thenAnswer((_) async => 0.0);
        return AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo);
      },
      seed: () => AssetLoaded([_asset(category: 'Stocks', ticker: 'AAPL', currentPrice: 175.0)]),
      act: (bloc) => bloc.add(const SyncAssetPrices()),
      verify: (_) => verifyNever(() => mockAssetRepo.updateAsset(any())),
    );

    blocTest<AssetBloc, AssetState>(
      'does NOT call updateAsset when price is same as current',
      build: () {
        when(() => mockMarketRepo.getStockPrice('AAPL')).thenAnswer((_) async => 175.0);
        return AssetBloc(assetRepository: mockAssetRepo, marketApiRepository: mockMarketRepo);
      },
      seed: () => AssetLoaded([_asset(category: 'Stocks', ticker: 'AAPL', currentPrice: 175.0)]),
      act: (bloc) => bloc.add(const SyncAssetPrices()),
      verify: (_) => verifyNever(() => mockAssetRepo.updateAsset(any())),
    );
  });
}
