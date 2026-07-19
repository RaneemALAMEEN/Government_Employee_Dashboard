import 'package:get_it/get_it.dart';

import '../../../core/services/api_service.dart';
import '../../../core/services/session_service.dart';
import '../data/datasources/organization_hierarchy_remote_data_source.dart';
import '../data/repositories/organization_hierarchy_repository_impl.dart';
import '../domain/repositories/organization_hierarchy_repository.dart';
import '../domain/usecases/get_department_leaves.dart';
import '../domain/usecases/get_department_roles.dart';
import '../domain/usecases/get_organization_employees.dart';
import '../presentation/bloc/org_hierarchy_bloc.dart';

Future<void> setupOrganizationHierarchyInjection(GetIt getIt) async {
  if (!getIt.isRegistered<OrganizationHierarchyRemoteDataSource>()) {
    getIt.registerLazySingleton<OrganizationHierarchyRemoteDataSource>(
      () => OrganizationHierarchyRemoteDataSource(getIt<ApiService>()),
    );
  }

  if (!getIt.isRegistered<OrganizationHierarchyRepository>()) {
    getIt.registerLazySingleton<OrganizationHierarchyRepository>(
      () => OrganizationHierarchyRepositoryImpl(
        getIt<OrganizationHierarchyRemoteDataSource>(),
      ),
    );
  }

  if (!getIt.isRegistered<GetDepartmentLeaves>()) {
    getIt.registerLazySingleton(
      () => GetDepartmentLeaves(getIt<OrganizationHierarchyRepository>()),
    );
  }
  if (!getIt.isRegistered<GetDepartmentRoles>()) {
    getIt.registerLazySingleton(
      () => GetDepartmentRoles(getIt<OrganizationHierarchyRepository>()),
    );
  }
  if (!getIt.isRegistered<GetOrganizationEmployees>()) {
    getIt.registerLazySingleton(
      () => GetOrganizationEmployees(
        getIt<OrganizationHierarchyRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<OrgHierarchyBloc>()) {
    getIt.registerFactory(
      () => OrgHierarchyBloc(
        sessionService: getIt<SessionService>(),
        getDepartmentLeaves: getIt<GetDepartmentLeaves>(),
        getDepartmentRoles: getIt<GetDepartmentRoles>(),
        getOrganizationEmployees: getIt<GetOrganizationEmployees>(),
      ),
    );
  }
}
