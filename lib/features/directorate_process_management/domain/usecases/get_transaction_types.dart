import '../repositories/directorate_process_repository.dart';

class GetTransactionTypes {
  final DirectorateProcessRepository repository;
  const GetTransactionTypes(this.repository);

  call() => repository.getTransactionTypes();
}
