import '../repositories/directorate_process_repository.dart';

class GetProcessDefinitions {
  final DirectorateProcessRepository repository;
  const GetProcessDefinitions(this.repository);

  call({required int typeId, int page = 1, int limit = 20}) => repository
      .getProcessDefinitions(typeId: typeId, page: page, limit: limit);
}
