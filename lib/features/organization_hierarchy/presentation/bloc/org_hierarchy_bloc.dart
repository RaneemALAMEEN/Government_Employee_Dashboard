import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/mock_org_data_source.dart';
import 'org_hierarchy_event.dart';
import 'org_hierarchy_state.dart';

class OrgHierarchyBloc extends Bloc<OrgHierarchyEvent, OrgHierarchyState> {
  final MockOrgDataSource dataSource;

  OrgHierarchyBloc(this.dataSource) : super(OrgHierarchyInitial()) {
    on<LoadOrgHierarchy>((event, emit) async {
      emit(OrgHierarchyLoading());
      try {
        final nodes = await dataSource.getOrganizationHierarchy();
        emit(OrgHierarchyLoaded(nodes));
      } catch (e) {
        emit(OrgHierarchyFailure('فشل في تحميل الهيكل التنظيمي'));
      }
    });
  }
}
