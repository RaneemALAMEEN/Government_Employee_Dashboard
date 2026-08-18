import 'package:dio/dio.dart' as dio;

import '../../../../core/enums/api_method.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/appointment_entities.dart';
import '../models/appointment_models.dart';

class AppointmentsRemoteDataSource {
  final ApiService api;
  const AppointmentsRemoteDataSource(this.api);

  static const _base = 'api/appointments';

  Future<List<AppointmentSlotModel>> getManaged(String filter) async =>
      _slotList(ApiMethod.get, '$_base/manage', query: {'filter': filter});

  Future<List<AppointmentSlotModel>> getAvailable() async =>
      _slotList(ApiMethod.get, '$_base/slots/available');

  Future<List<AppointmentSlotModel>> _slotList(
    ApiMethod method,
    String endpoint, {
    Map<String, dynamic>? query,
  }) async {
    final result = await api.makeRequest(
      method: method,
      endPoint: endpoint,
      queryParameters: query,
    );
    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) => ((response as Map)['data'] as List? ?? const [])
          .whereType<Map>()
          .map((e) =>
              AppointmentSlotModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false),
    );
  }

  Future<AppointmentSlotModel> createSlot(AppointmentSlotInput input) =>
      _slotMutation(ApiMethod.post, '$_base/slots', input.toJson());

  Future<AppointmentSlotModel> updateSlot(int id, AppointmentSlotInput input) =>
      _slotMutation(ApiMethod.put, '$_base/slots/$id', input.toJson());

  Future<AppointmentSlotModel> _slotMutation(
    ApiMethod method,
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final result =
        await api.makeRequest(method: method, endPoint: endpoint, body: body);
    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) => AppointmentSlotModel.fromJson(
        Map<String, dynamic>.from((response as Map)['data'] as Map),
      ),
    );
  }

  Future<void> deleteSlot(int id) => _delete('$_base/slots/$id');
  Future<void> deletePastBooking(int id) => _delete('$_base/bookings/$id/past');

  Future<void> _delete(String endpoint) async {
    final result =
        await api.makeRequest(method: ApiMethod.delete, endPoint: endpoint);
    result.fold((failure) => throw ServerException(failure.message), (_) {});
  }

  Future<AppointmentBookingModel> decide(
          int id, String decision, String note) =>
      _bookingMutation('$_base/bookings/$id/decision', {
        'decision': decision,
        'note': note,
      });

  Future<AppointmentBookingModel> attendance(int id, bool attended) =>
      _bookingMutation(
          '$_base/bookings/$id/attendance', {'attended': attended});

  Future<AppointmentBookingModel> _bookingMutation(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final result = await api.makeRequest(
      method: ApiMethod.patch,
      endPoint: endpoint,
      body: body,
    );
    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) => AppointmentBookingModel.fromJson(
        Map<String, dynamic>.from((response as Map)['data'] as Map),
      ),
    );
  }

  Future<AppointmentBookingModel> book(AppointmentBookingInput input) async {
    final form = dio.FormData.fromMap({
      'appointment_id': input.appointmentId,
      'first_name': input.firstName,
      'last_name': input.lastName,
      'father_name': input.fatherName,
      'mother_name': input.motherName,
      'national_id': input.nationalId,
      'phone_number': input.phoneNumber,
      'reason': input.reason,
      'identity_image':
          await dio.MultipartFile.fromFile(input.identityImagePath),
    });
    final result = await api.makeRequest(
      method: ApiMethod.post,
      endPoint: '$_base/bookings',
      formData: form,
    );
    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) => AppointmentBookingModel.fromJson(
        Map<String, dynamic>.from((response as Map)['data'] as Map),
      ),
    );
  }
}
