import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../entities/organization_search_entity.dart';
import '../repositories/organization_hierarchy_repository.dart';

class SearchOrganization {
  final OrganizationHierarchyRepository repository;

  const SearchOrganization(this.repository);

  Future<Either<Failure, OrganizationSearchEntity>> call({
    required int organizationId,
    required String query,
    String scope = 'all',
    int limit = 20,
    String? cursor,
    CancelToken? cancelToken,
  }) =>
      repository.searchOrganization(
        organizationId: organizationId,
        query: query,
        scope: scope,
        limit: limit,
        cursor: cursor,
        cancelToken: cancelToken,
      );
}
