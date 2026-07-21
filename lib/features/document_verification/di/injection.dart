import '../../../core/di/injection.dart';
import '../../../core/services/api_service.dart';
import '../data/datasources/document_verification_remote_data_source.dart';
import '../data/repositories/document_verification_repository_impl.dart';
import '../domain/repositories/document_verification_repository.dart';
import '../domain/usecases/verify_document.dart';
import '../presentation/bloc/document_verification_bloc.dart';

Future<void> setupDocumentVerificationInjection() async {
  getIt.registerLazySingleton(
    () => DocumentVerificationRemoteDataSource(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<DocumentVerificationRepository>(
    () => DocumentVerificationRepositoryImpl(
      getIt<DocumentVerificationRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton(
    () => VerifyDocument(getIt<DocumentVerificationRepository>()),
  );
  getIt.registerFactory(
    () => DocumentVerificationBloc(verifyDocument: getIt<VerifyDocument>()),
  );
}
