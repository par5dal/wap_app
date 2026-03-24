// test/core/services/app_version_service_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wap_app/core/services/app_version_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late AppVersionService service;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = MockDio();
    service = AppVersionService(dio: mockDio);
  });

  Response<Map<String, dynamic>> responseWith(Map<String, dynamic>? data) =>
      Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/app/config'),
        data: data,
        statusCode: 200,
      );

  void setInstalledVersion(String version) {
    PackageInfo.setMockInitialValues(
      appName: 'wap_app',
      packageName: 'com.jovelupe.wap',
      version: version,
      buildNumber: '1',
      buildSignature: '',
    );
  }

  group('isUpdateRequired', () {
    test('returns true when installed version < min_version', () async {
      setInstalledVersion('1.0.0');
      when(
        () => mockDio.get<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => responseWith({'min_version': '2.0.0'}));

      expect(await service.isUpdateRequired(), isTrue);
    });

    test('returns true when patch is older (1.2.0 < 1.2.1)', () async {
      setInstalledVersion('1.2.0');
      when(
        () => mockDio.get<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => responseWith({'min_version': '1.2.1'}));

      expect(await service.isUpdateRequired(), isTrue);
    });

    test('returns false when installed version == min_version', () async {
      setInstalledVersion('2.0.0');
      when(
        () => mockDio.get<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => responseWith({'min_version': '2.0.0'}));

      expect(await service.isUpdateRequired(), isFalse);
    });

    test('returns false when installed version > min_version', () async {
      setInstalledVersion('3.1.0');
      when(
        () => mockDio.get<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => responseWith({'min_version': '2.0.0'}));

      expect(await service.isUpdateRequired(), isFalse);
    });

    test('returns false when min_version key is missing', () async {
      setInstalledVersion('1.0.0');
      when(
        () => mockDio.get<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => responseWith({'other_key': 'value'}));

      expect(await service.isUpdateRequired(), isFalse);
    });

    test('returns false when response data is null', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => responseWith(null));

      expect(await service.isUpdateRequired(), isFalse);
    });

    test('returns false on network error (fail silently)', () async {
      when(() => mockDio.get<Map<String, dynamic>>(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/app/config'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(await service.isUpdateRequired(), isFalse);
    });

    test('returns false on unexpected exception (fail silently)', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(any()),
      ).thenThrow(Exception('Unexpected error'));

      expect(await service.isUpdateRequired(), isFalse);
    });
  });
}
