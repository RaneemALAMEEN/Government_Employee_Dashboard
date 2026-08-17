import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/usb_signing_service.dart';
import '../repositories/auth_repository.dart';

class ChangePinResult {
  final bool usbUpdated;
  final String? usbWarning;

  const ChangePinResult({
    required this.usbUpdated,
    this.usbWarning,
  });
}

class ChangePinUseCase {
  final AuthRepository repository;
  final UsbSigningService usbSigningService;
  final SessionService sessionService;

  ChangePinUseCase({
    required this.repository,
    required this.usbSigningService,
    required this.sessionService,
  });

  Future<Either<Failure, ChangePinResult>> call({
    required String oldPin,
    required String newPin,
    required String confirmNewPin,
  }) async {
    final result = await repository.changePin(
      oldPin: oldPin,
      newPin: newPin,
      confirmNewPin: confirmNewPin,
    );

    return result.fold(
      (failure) => Left(failure),
      (_) async {
        // 1. Update session PIN
        sessionService.setSessionPin(newPin);

        // 2. Re-encrypt private key on USB
        bool usbUpdated = false;
        String? usbWarning;
        final username =
            sessionService.currentUserNotifier.value?.userName ?? '';


        if (username.isNotEmpty) {
          try {
            await usbSigningService.reEncryptKeyWithNewPin(
              username: username,
              oldPin: oldPin,
              newPin: newPin,
            );
            usbUpdated = true;
          } catch (e) {
            debugPrint('[ChangePinUseCase] USB re-encryption notice: $e');
            usbWarning = e.toString().replaceAll('Exception:', '').trim();
          }
        }

        return Right(ChangePinResult(
          usbUpdated: usbUpdated,
          usbWarning: usbWarning,
        ));
      },
    );
  }
}

