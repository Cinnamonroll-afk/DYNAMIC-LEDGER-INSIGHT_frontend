import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_event.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_state.dart';
import 'package:fincontrol/features/wealth/data/models/portfolio_model.dart';
import 'package:fincontrol/features/wealth/data/repositories/portfolio_repository.dart';

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

PortfolioModel _portfolio(String id) => PortfolioModel(
      id: id,
      userId: 'user1',
      name: 'Test Portfolio',
      createdAt: DateTime(2024, 1, 1),
    );

void main() {
  late MockPortfolioRepository mockRepo;

  setUp(() {
    mockRepo = MockPortfolioRepository();
    registerFallbackValue(_portfolio('fallback'));
  });

  test('initial state is PortfolioInitial', () {
    final bloc = PortfolioBloc(portfolioRepository: mockRepo);
    expect(bloc.state, isA<PortfolioInitial>());
    bloc.close();
  });

  group('LoadPortfolios', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'emits [PortfolioLoading, PortfolioLoaded] from initial state',
      build: () {
        when(() => mockRepo.getPortfolios(any()))
            .thenAnswer((_) => Stream.fromIterable([[_portfolio('p1')]]));
        return PortfolioBloc(portfolioRepository: mockRepo);
      },
      act: (bloc) => bloc.add(LoadPortfolios('user1')),
      expect: () => [
        isA<PortfolioLoading>(),
        isA<PortfolioLoaded>(),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'PortfolioLoaded contains correct portfolios',
      build: () {
        when(() => mockRepo.getPortfolios(any()))
            .thenAnswer((_) => Stream.fromIterable([[_portfolio('p1'), _portfolio('p2')]]));
        return PortfolioBloc(portfolioRepository: mockRepo);
      },
      act: (bloc) => bloc.add(LoadPortfolios('user1')),
      expect: () => [
        isA<PortfolioLoading>(),
        predicate<PortfolioState>((s) => s is PortfolioLoaded && s.portfolios.length == 2),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'does NOT emit PortfolioLoading when already in PortfolioLoaded state',
      build: () {
        when(() => mockRepo.getPortfolios(any()))
            .thenAnswer((_) => Stream.fromIterable([[_portfolio('p2')]]));
        return PortfolioBloc(portfolioRepository: mockRepo);
      },
      seed: () => PortfolioLoaded([_portfolio('p1')]),
      act: (bloc) => bloc.add(LoadPortfolios('user1')),
      expect: () => [
        // No PortfolioLoading, goes directly to new PortfolioLoaded
        predicate<PortfolioState>((s) => s is PortfolioLoaded && s.portfolios.first.id == 'p2'),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'emits PortfolioError when stream errors',
      build: () {
        when(() => mockRepo.getPortfolios(any()))
            .thenAnswer((_) => Stream.error(Exception('db error')));
        return PortfolioBloc(portfolioRepository: mockRepo);
      },
      act: (bloc) => bloc.add(LoadPortfolios('user1')),
      expect: () => [
        isA<PortfolioLoading>(),
        isA<PortfolioError>(),
      ],
    );
  });

  group('PortfoliosUpdated', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'emits PortfolioLoaded with given portfolios',
      build: () => PortfolioBloc(portfolioRepository: mockRepo),
      act: (bloc) => bloc.add(PortfoliosUpdated([_portfolio('p1')])),
      expect: () => [
        predicate<PortfolioState>((s) => s is PortfolioLoaded && s.portfolios.first.id == 'p1'),
      ],
    );
  });

  group('PortfolioFailed', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'emits PortfolioError with the error message',
      build: () => PortfolioBloc(portfolioRepository: mockRepo),
      act: (bloc) => bloc.add(PortfolioFailed('network error')),
      expect: () => [
        predicate<PortfolioState>((s) => s is PortfolioError && s.message == 'network error'),
      ],
    );
  });

  group('AddPortfolio', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'calls addPortfolio on repository',
      build: () {
        when(() => mockRepo.addPortfolio(any())).thenAnswer((_) async => 'new_id');
        when(() => mockRepo.getPortfolios(any()))
            .thenAnswer((_) => Stream.fromIterable([[]]));
        return PortfolioBloc(portfolioRepository: mockRepo);
      },
      act: (bloc) => bloc.add(AddPortfolio(_portfolio('new'))),
      verify: (_) => verify(() => mockRepo.addPortfolio(any())).called(1),
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'emits PortfolioError when addPortfolio throws',
      build: () {
        when(() => mockRepo.addPortfolio(any()))
            .thenThrow(Exception('add failed'));
        return PortfolioBloc(portfolioRepository: mockRepo);
      },
      act: (bloc) => bloc.add(AddPortfolio(_portfolio('new'))),
      expect: () => [isA<PortfolioError>()],
    );
  });

  group('UpdatePortfolio', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'calls updatePortfolio on repository',
      build: () {
        when(() => mockRepo.updatePortfolio(any())).thenAnswer((_) async {});
        when(() => mockRepo.getPortfolios(any()))
            .thenAnswer((_) => Stream.fromIterable([[]]));
        return PortfolioBloc(portfolioRepository: mockRepo);
      },
      act: (bloc) => bloc.add(UpdatePortfolio(_portfolio('p1'))),
      verify: (_) => verify(() => mockRepo.updatePortfolio(any())).called(1),
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'emits PortfolioError when updatePortfolio throws',
      build: () {
        when(() => mockRepo.updatePortfolio(any()))
            .thenThrow(Exception('update failed'));
        return PortfolioBloc(portfolioRepository: mockRepo);
      },
      act: (bloc) => bloc.add(UpdatePortfolio(_portfolio('p1'))),
      expect: () => [isA<PortfolioError>()],
    );
  });

  group('DeletePortfolio', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'calls deletePortfolio on repository',
      build: () {
        when(() => mockRepo.deletePortfolio(any())).thenAnswer((_) async {});
        when(() => mockRepo.getPortfolios(any()))
            .thenAnswer((_) => Stream.fromIterable([[]]));
        return PortfolioBloc(portfolioRepository: mockRepo);
      },
      act: (bloc) => bloc.add(DeletePortfolio('p_id')),
      verify: (_) => verify(() => mockRepo.deletePortfolio(any())).called(1),
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'emits PortfolioError when deletePortfolio throws',
      build: () {
        when(() => mockRepo.deletePortfolio(any()))
            .thenThrow(Exception('delete failed'));
        return PortfolioBloc(portfolioRepository: mockRepo);
      },
      act: (bloc) => bloc.add(DeletePortfolio('p_id')),
      expect: () => [isA<PortfolioError>()],
    );
  });
}
