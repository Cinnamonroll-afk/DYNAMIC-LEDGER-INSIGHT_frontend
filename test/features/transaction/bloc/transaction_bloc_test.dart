import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_bloc.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_event.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_state.dart';
import 'package:fincontrol/features/transaction/data/models/transaction_model.dart';
import 'package:fincontrol/features/transaction/data/repositories/transaction_repository.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

TransactionModel _tx(String id) => TransactionModel(
      id: id,
      userId: 'user1',
      type: 'expense',
      amount: 100.0,
      category: 'Food & Dining',
      note: 'test',
      date: DateTime(2024, 1, 1),
    );

void main() {
  late MockTransactionRepository mockRepo;

  setUp(() {
    mockRepo = MockTransactionRepository();
    registerFallbackValue(_tx('fallback'));
  });

  test('initial state is TransactionInitial', () {
    final bloc = TransactionBloc(transactionRepository: mockRepo);
    expect(bloc.state, isA<TransactionInitial>());
    bloc.close();
  });

  group('LoadTransactions', () {
    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionLoaded] on successful stream',
      build: () {
        when(() => mockRepo.getTransactions(any()))
            .thenAnswer((_) => Stream.fromIterable([[_tx('tx1')]]));
        return TransactionBloc(transactionRepository: mockRepo);
      },
      act: (bloc) => bloc.add(LoadTransactions('user1')),
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionLoaded>(),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'TransactionLoaded contains the transactions from the stream',
      build: () {
        when(() => mockRepo.getTransactions(any()))
            .thenAnswer((_) => Stream.fromIterable([[_tx('tx1'), _tx('tx2')]]));
        return TransactionBloc(transactionRepository: mockRepo);
      },
      act: (bloc) => bloc.add(LoadTransactions('user1')),
      expect: () => [
        isA<TransactionLoading>(),
        predicate<TransactionState>((s) => s is TransactionLoaded && s.transactions.length == 2),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionLoading then TransactionLoaded([]) for empty stream',
      build: () {
        when(() => mockRepo.getTransactions(any()))
            .thenAnswer((_) => Stream.fromIterable([[]]));
        return TransactionBloc(transactionRepository: mockRepo);
      },
      act: (bloc) => bloc.add(LoadTransactions('user1')),
      expect: () => [
        isA<TransactionLoading>(),
        predicate<TransactionState>((s) => s is TransactionLoaded && s.transactions.isEmpty),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionError when stream errors',
      build: () {
        when(() => mockRepo.getTransactions(any()))
            .thenAnswer((_) => Stream.error(Exception('db error')));
        return TransactionBloc(transactionRepository: mockRepo);
      },
      act: (bloc) => bloc.add(LoadTransactions('user1')),
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionError>(),
      ],
    );
  });

  group('TransactionsUpdated', () {
    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionLoaded with the given transactions',
      build: () => TransactionBloc(transactionRepository: mockRepo),
      act: (bloc) => bloc.add(TransactionsUpdated([_tx('tx1')])),
      expect: () => [
        predicate<TransactionState>((s) => s is TransactionLoaded && s.transactions.first.id == 'tx1'),
      ],
    );
  });

  group('TransactionFailed', () {
    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionError with the error message',
      build: () => TransactionBloc(transactionRepository: mockRepo),
      act: (bloc) => bloc.add(TransactionFailed('something went wrong')),
      expect: () => [
        predicate<TransactionState>((s) => s is TransactionError && s.message == 'something went wrong'),
      ],
    );
  });

  group('AddTransaction', () {
    blocTest<TransactionBloc, TransactionState>(
      'calls addTransaction on repository',
      build: () {
        when(() => mockRepo.addTransaction(any())).thenAnswer((_) async {});
        when(() => mockRepo.getTransactions(any()))
            .thenAnswer((_) => Stream.fromIterable([[]]));
        return TransactionBloc(transactionRepository: mockRepo);
      },
      act: (bloc) => bloc.add(AddTransaction(_tx('tx_new'))),
      verify: (_) => verify(() => mockRepo.addTransaction(any())).called(1),
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionError when addTransaction throws',
      build: () {
        when(() => mockRepo.addTransaction(any()))
            .thenThrow(Exception('add failed'));
        return TransactionBloc(transactionRepository: mockRepo);
      },
      act: (bloc) => bloc.add(AddTransaction(_tx('tx_new'))),
      expect: () => [isA<TransactionError>()],
    );
  });

  group('UpdateTransaction', () {
    blocTest<TransactionBloc, TransactionState>(
      'calls updateTransaction on repository',
      build: () {
        when(() => mockRepo.updateTransaction(any())).thenAnswer((_) async {});
        when(() => mockRepo.getTransactions(any()))
            .thenAnswer((_) => Stream.fromIterable([[]]));
        return TransactionBloc(transactionRepository: mockRepo);
      },
      act: (bloc) => bloc.add(UpdateTransaction(_tx('tx_existing'))),
      verify: (_) => verify(() => mockRepo.updateTransaction(any())).called(1),
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionError when updateTransaction throws',
      build: () {
        when(() => mockRepo.updateTransaction(any()))
            .thenThrow(Exception('update failed'));
        return TransactionBloc(transactionRepository: mockRepo);
      },
      act: (bloc) => bloc.add(UpdateTransaction(_tx('tx_existing'))),
      expect: () => [isA<TransactionError>()],
    );
  });

  group('DeleteTransaction', () {
    blocTest<TransactionBloc, TransactionState>(
      'calls deleteTransaction on repository',
      build: () {
        when(() => mockRepo.deleteTransaction(any())).thenAnswer((_) async {});
        when(() => mockRepo.getTransactions(any()))
            .thenAnswer((_) => Stream.fromIterable([[]]));
        return TransactionBloc(transactionRepository: mockRepo);
      },
      act: (bloc) => bloc.add(DeleteTransaction('tx_id')),
      verify: (_) => verify(() => mockRepo.deleteTransaction(any())).called(1),
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits TransactionError when deleteTransaction throws',
      build: () {
        when(() => mockRepo.deleteTransaction(any()))
            .thenThrow(Exception('delete failed'));
        return TransactionBloc(transactionRepository: mockRepo);
      },
      act: (bloc) => bloc.add(DeleteTransaction('tx_id')),
      expect: () => [isA<TransactionError>()],
    );
  });
}
