import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:government_employee_dashboard/core/errors/failures.dart';
import 'package:government_employee_dashboard/core/services/usb_signing_service.dart';
import 'package:government_employee_dashboard/features/my_transactions/domain/repositories/my_transactions_repository.dart';
import 'package:government_employee_dashboard/features/my_transactions/domain/usecases/submit_transaction.dart';

class _FakeUsbProvider implements UsbDeviceIdentityProvider {
  _FakeUsbProvider(this.device);

  UsbDeviceInfo? device;

  @override
  Future<UsbDeviceInfo?> getDeviceForPath(String path) async => device;

  @override
  Future<String> getStableDeviceFingerprint(UsbDeviceInfo device) async {
    final source = [
      device.physicalSerialNumber,
      device.pnpDeviceId,
      device.vendorId,
      device.productId,
    ]
        .map((value) =>
            (value ?? '').trim().toUpperCase().replaceAll(RegExp(r'\s+'), ''))
        .join('|');
    final hash = await Sha256().hash(source.codeUnits);
    return hash.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}

class _V2Fixture {
  final Directory directory;
  final String publicKeyFingerprint;

  const _V2Fixture(this.directory, this.publicKeyFingerprint);
}

class _SigningFlowRepository implements MyTransactionsRepository {
  _SigningFlowRepository(this.fingerprint);

  final String fingerprint;
  bool completeCalled = false;
  Map<String, dynamic>? completedPayload;

  @override
  Future<Either<Failure, Map<String, dynamic>>> createSigningChallenge({
    required String taskId,
    required String pin,
    required String decision,
    bool isSubmitDocuments = false,
  }) async =>
      Right({
        'data': {
          'challenge_id': 'challenge-1',
          'transaction_id': 42,
          'message': 'challenge-message',
          'key_fingerprint': fingerprint,
        },
      });

  @override
  Future<Either<Failure, dynamic>> completeTask({
    required String taskId,
    required Map<String, dynamic> payload,
    bool isSubmitDocuments = false,
  }) async {
    completeCalled = true;
    completedPayload = payload;
    return const Right({'ok': true});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _originalDevice = UsbDeviceInfo(
  rootPath: r'E:\',
  physicalSerialNumber: 'SERIAL-123',
  pnpDeviceId: r'USBSTOR\DISK&VEN_TEST&PROD_FLASH\SERIAL-123',
  vendorId: '1234',
  productId: '5678',
  isRemovable: true,
);

Future<_V2Fixture> _createV2Fixture(
  Directory directory,
  UsbDeviceIdentityProvider provider, {
  String pin = '123456',
}) async {
  await directory.create(recursive: true);
  final algorithm = Ed25519();
  final seed = Uint8List.fromList(List.generate(32, (index) => index + 1));
  final keyPair = await algorithm.newKeyPairFromSeed(seed);
  final publicKey = await keyPair.extractPublicKey();
  const spkiPrefix = <int>[
    0x30,
    0x2a,
    0x30,
    0x05,
    0x06,
    0x03,
    0x2b,
    0x65,
    0x70,
    0x03,
    0x21,
    0x00,
  ];
  final publicPem = '-----BEGIN PUBLIC KEY-----\n'
      '${base64Encode([...spkiPrefix, ...publicKey.bytes])}\n'
      '-----END PUBLIC KEY-----';
  final publicHash = await Sha256().hash(utf8.encode(publicPem));
  final publicFingerprint = publicHash.bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  final usbFingerprint =
      await provider.getStableDeviceFingerprint(_originalDevice);
  final salt = List<int>.generate(32, (index) => 100 + index);
  final nonce = List<int>.generate(12, (index) => 20 + index);
  final metadata = <String, dynamic>{
    'version': 2,
    'package_version': 2,
    'client_key_id': '11111111-2222-4333-8444-555555555555',
    'username': 'employee',
    'algorithm': 'AES-256-GCM',
    'key_algorithm': 'Ed25519',
    'kdf': 'HKDF-SHA256',
    'usb_fingerprint_hash': usbFingerprint,
    'public_key_fingerprint': publicFingerprint,
    'salt': base64Encode(salt),
    'nonce': base64Encode(nonce),
    'mac': '',
    'created_at': '2026-08-09T10:00:00.000Z',
    'binding_token': null,
  };
  final aad = utf8.encode(jsonEncode({
    'version': metadata['version'],
    'packageVersion': metadata['package_version'],
    'clientKeyId': metadata['client_key_id'],
    'username': metadata['username'],
    'algorithm': metadata['algorithm'],
    'keyAlgorithm': metadata['key_algorithm'],
    'kdf': metadata['kdf'],
    'usbFingerprintHash': metadata['usb_fingerprint_hash'],
    'publicKeyFingerprint': metadata['public_key_fingerprint'],
    'createdAt': metadata['created_at'],
  }));
  final encryptionKey = await Hkdf(
    hmac: Hmac.sha256(),
    outputLength: 32,
  ).deriveKey(
    secretKey: SecretKey(utf8.encode(
      'pinLength=${pin.length}:$pin|usbSha256=$usbFingerprint',
    )),
    nonce: salt,
    info: utf8.encode('technical-team/usb-bound-key/v2'),
  );
  final box = await AesGcm.with256bits().encrypt(
    seed,
    secretKey: encryptionKey,
    nonce: nonce,
    aad: aad,
  );
  metadata['mac'] = base64Encode(box.mac.bytes);
  await File('${directory.path}${Platform.pathSeparator}employee-key.enc')
      .writeAsString(base64Encode(box.cipherText));
  await File('${directory.path}${Platform.pathSeparator}employee-key.meta')
      .writeAsString(jsonEncode(metadata));
  await File('${directory.path}${Platform.pathSeparator}employee-public.pem')
      .writeAsString(publicPem);
  seed.fillRange(0, seed.length, 0);
  return _V2Fixture(directory, publicFingerprint);
}

Future<void> _expectFailure(
  Future<String> Function() action,
  String message,
) async {
  await expectLater(action, throwsA(predicate((error) {
    return error.toString().contains(message);
  })));
}

void main() {
  late Directory tempRoot;
  late _FakeUsbProvider provider;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('employee-key-v2-test-');
    provider = _FakeUsbProvider(_originalDevice);
  });

  tearDown(() async {
    if (await tempRoot.exists()) await tempRoot.delete(recursive: true);
  });

  test('v2 + original USB + correct PIN signs successfully', () async {
    final fixture = await _createV2Fixture(tempRoot, provider);
    final signature =
        await UsbSigningService(usbDeviceIdentityProvider: provider)
            .signMessageFromUsb(
      keysDirectoryPath: fixture.directory.path,
      pin: '123456',
      message: 'challenge-message',
      expectedKeyFingerprint: fixture.publicKeyFingerprint,
    );
    expect(base64Decode(signature), hasLength(64));
  });

  test('wrong PIN is rejected', () async {
    final fixture = await _createV2Fixture(tempRoot, provider);
    await _expectFailure(
      () => UsbSigningService(usbDeviceIdentityProvider: provider)
          .signMessageFromUsb(
        keysDirectoryPath: fixture.directory.path,
        pin: '000000',
        message: 'challenge-message',
      ),
      'رمز PIN غير صحيح أو ملف المفتاح غير صالح',
    );
  });

  test('another USB is rejected', () async {
    final fixture = await _createV2Fixture(tempRoot, provider);
    provider.device = const UsbDeviceInfo(
      rootPath: r'F:\',
      physicalSerialNumber: 'OTHER-SERIAL',
      pnpDeviceId: 'OTHER-PNP',
      vendorId: '9999',
      productId: '0000',
      isRemovable: true,
    );
    await _expectFailure(
      () => UsbSigningService(usbDeviceIdentityProvider: provider)
          .signMessageFromUsb(
        keysDirectoryPath: fixture.directory.path,
        pin: '123456',
        message: 'challenge-message',
      ),
      'هذه الفلاشة لا تطابق الفلاشة التي أُنشئ عليها المفتاح',
    );
  });

  test('changing drive letter succeeds for the same physical USB', () async {
    final fixture = await _createV2Fixture(tempRoot, provider);
    provider.device = const UsbDeviceInfo(
      rootPath: r'Z:\',
      physicalSerialNumber: 'SERIAL-123',
      pnpDeviceId: r'USBSTOR\DISK&VEN_TEST&PROD_FLASH\SERIAL-123',
      vendorId: '1234',
      productId: '5678',
      isRemovable: true,
    );
    final signature =
        await UsbSigningService(usbDeviceIdentityProvider: provider)
            .signMessageFromUsb(
      keysDirectoryPath: fixture.directory.path,
      pin: '123456',
      message: 'challenge-message',
    );
    expect(base64Decode(signature), hasLength(64));
  });

  test('modified metadata is rejected by AES-GCM authentication', () async {
    final fixture = await _createV2Fixture(tempRoot, provider);
    final file = File(
        '${fixture.directory.path}${Platform.pathSeparator}employee-key.meta');
    final meta = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    meta['username'] = 'tampered';
    await file.writeAsString(jsonEncode(meta));
    await _expectFailure(
      () => UsbSigningService(usbDeviceIdentityProvider: provider)
          .signMessageFromUsb(
              keysDirectoryPath: fixture.directory.path,
              pin: '123456',
              message: 'x'),
      'رمز PIN غير صحيح أو ملف المفتاح غير صالح',
    );
  });

  test('modified encrypted key is rejected', () async {
    final fixture = await _createV2Fixture(tempRoot, provider);
    final file = File(
        '${fixture.directory.path}${Platform.pathSeparator}employee-key.enc');
    final bytes = base64Decode(await file.readAsString());
    bytes[0] ^= 1;
    await file.writeAsString(base64Encode(bytes));
    await _expectFailure(
      () => UsbSigningService(usbDeviceIdentityProvider: provider)
          .signMessageFromUsb(
              keysDirectoryPath: fixture.directory.path,
              pin: '123456',
              message: 'x'),
      'رمز PIN غير صحيح أو ملف المفتاح غير صالح',
    );
  });

  test('replaced public key is rejected', () async {
    final fixture = await _createV2Fixture(tempRoot, provider);
    await File(
            '${fixture.directory.path}${Platform.pathSeparator}employee-public.pem')
        .writeAsString(
            '-----BEGIN PUBLIC KEY-----\nAAAA\n-----END PUBLIC KEY-----');
    await _expectFailure(
      () => UsbSigningService(usbDeviceIdentityProvider: provider)
          .signMessageFromUsb(
              keysDirectoryPath: fixture.directory.path,
              pin: '123456',
              message: 'x'),
      'ملفات المفتاح غير متطابقة أو تم تعديلها',
    );
  });

  test('different backend key fingerprint does not reject a valid package',
      () async {
    final fixture = await _createV2Fixture(tempRoot, provider);
    final signature =
        await UsbSigningService(usbDeviceIdentityProvider: provider)
            .signMessageFromUsb(
      keysDirectoryPath: fixture.directory.path,
      pin: '123456',
      message: 'x',
      expectedKeyFingerprint: 'different',
    );
    expect(base64Decode(signature), hasLength(64));
  });

  test('missing package file is rejected', () async {
    final fixture = await _createV2Fixture(tempRoot, provider);
    await File(
            '${fixture.directory.path}${Platform.pathSeparator}employee-public.pem')
        .delete();
    await _expectFailure(
      () => UsbSigningService(usbDeviceIdentityProvider: provider)
          .signMessageFromUsb(
              keysDirectoryPath: fixture.directory.path,
              pin: '123456',
              message: 'x'),
      'ملفات المفتاح غير مكتملة أو تم تعديلها',
    );
  });

  test('challenge success signs then invokes complete endpoint flow', () async {
    final fixture = await _createV2Fixture(tempRoot, provider);
    final repository = _SigningFlowRepository(fixture.publicKeyFingerprint);
    final useCase = SubmitTransaction(
      repository,
      UsbSigningService(usbDeviceIdentityProvider: provider),
    );

    final result = await useCase(
      taskId: 'task-1',
      widgets: const [],
      formValues: const {},
      formId: 'submit-documents',
      formName: 'documents',
      isApprove: true,
      pin: '123456',
      keysDirectoryPath: fixture.directory.path,
    );

    expect(result.isRight(), isTrue);
    expect(repository.completeCalled, isTrue);
    expect(repository.completedPayload?['signature']['challenge_id'],
        'challenge-1');
    expect(
      base64Decode(
          repository.completedPayload?['signature']['signature'] as String),
      hasLength(64),
    );
  });
}
