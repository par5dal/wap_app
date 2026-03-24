// test/features/preferences/presentation/pages/settings_page_legal_test.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/config/dependency_injection.dart' as di;
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/entities/legal_document.dart';
import 'package:wap_app/features/auth/domain/usecases/get_legal_document.dart';
import 'package:wap_app/features/preferences/presentation/pages/settings_page.dart';
import 'package:wap_app/l10n/app_localizations.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';
import 'package:wap_app/presentation/bloc/locale/locale_cubit.dart';
import 'package:wap_app/presentation/bloc/theme/theme_cubit.dart';
import 'package:wap_app/features/profile/presentation/bloc/profile_bloc.dart';

class MockGetLegalDocumentUseCase extends Mock
    implements GetLegalDocumentUseCase {}

class MockAppBloc extends Mock implements AppBloc {}

class MockLocaleCubit extends Mock implements LocaleCubit {}

class MockThemeCubit extends Mock implements ThemeCubit {}

class MockProfileBloc extends Mock implements ProfileBloc {}

void main() {
  late MockGetLegalDocumentUseCase mockGetLegalDocument;
  late MockAppBloc mockAppBloc;
  late MockLocaleCubit mockLocaleCubit;
  late MockThemeCubit mockThemeCubit;
  late MockProfileBloc mockProfileBloc;

  final tPrivacyDocument = LegalDocument(
    id: 'privacy-1.0-en',
    version: '1.0',
    type: 'privacy',
    lang: 'en',
    effectiveDate: DateTime(2024, 1, 15),
    sections: const [
      LegalSection(
        id: 'collection',
        title: 'Data Collection',
        content: '## Data Collection\n\n**We collect** the following data...',
      ),
      LegalSection(
        id: 'usage',
        title: 'Data Usage',
        content: '## Data Usage\n\nWe use your data to...',
      ),
    ],
  );

  final tTermsDocument = LegalDocument(
    id: 'terms-1.0-en',
    version: '1.0',
    type: 'terms',
    lang: 'en',
    effectiveDate: DateTime(2024, 1, 15),
    sections: const [
      LegalSection(
        id: 'intro',
        title: 'Introduction',
        content: '## Introduction\n\n**Welcome** to our terms',
      ),
    ],
  );

  setUp(() {
    mockGetLegalDocument = MockGetLegalDocumentUseCase();
    mockAppBloc = MockAppBloc();
    mockLocaleCubit = MockLocaleCubit();
    mockThemeCubit = MockThemeCubit();
    mockProfileBloc = MockProfileBloc();

    when(() => mockAppBloc.state).thenReturn(AppState.authenticated());
    when(() => mockAppBloc.stream).thenAnswer((_) => Stream.empty());
    when(() => mockLocaleCubit.state).thenReturn(null);
    when(() => mockLocaleCubit.stream).thenAnswer((_) => Stream.empty());
    when(() => mockThemeCubit.state).thenReturn(ThemeMode.system);
    when(() => mockThemeCubit.stream).thenAnswer((_) => Stream.empty());
    when(() => mockProfileBloc.state).thenReturn(ProfileInitial());
    when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.empty());

    di.sl.registerSingleton<GetLegalDocumentUseCase>(mockGetLegalDocument);
    di.sl.registerSingleton<AppBloc>(mockAppBloc);
    di.sl.registerSingleton<ProfileBloc>(mockProfileBloc);
  });

  tearDown(() {
    di.sl.reset();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AppBloc>.value(value: mockAppBloc),
          BlocProvider<LocaleCubit>.value(value: mockLocaleCubit),
          BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
        ],
        child: const SettingsPage(),
      ),
    );
  }

  testWidgets('should display Legal section in settings page', (
    WidgetTester tester,
  ) async {
    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // flush 400ms permission-check timer
    await tester.pumpAndSettle();

    // Assert
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == 'Legal',
      ),
      findsWidgets,
    );
  });

  testWidgets('should display Privacy Policy tile', (
    WidgetTester tester,
  ) async {
    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // flush 400ms permission-check timer
    await tester.pumpAndSettle();

    // Expand the Legal section first
    await tester.tap(find.text('Legal').first);
    await tester.pumpAndSettle();

    // Assert
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == 'Privacy Policy',
      ),
      findsWidgets,
    );
  });

  testWidgets('should display Terms of Use tile', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // flush 400ms permission-check timer
    await tester.pumpAndSettle();

    // Expand the Legal section first
    await tester.tap(find.text('Legal').first);
    await tester.pumpAndSettle();

    // Assert
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == 'Terms of Use',
      ),
      findsWidgets,
    );
  });

  testWidgets(
    'should open legal document modal when Privacy Policy is tapped',
    (WidgetTester tester) async {
      // Arrange
      when(
        () => mockGetLegalDocument(
          type: any(named: 'type'),
          lang: any(named: 'lang'),
        ),
      ).thenAnswer((_) async => Right(tPrivacyDocument));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(
        const Duration(milliseconds: 500),
      ); // flush 400ms permission-check timer
      await tester.pumpAndSettle();

      // Expand the Legal section first
      await tester.tap(find.text('Legal').first);
      await tester.pumpAndSettle();

      // Tap Privacy Policy
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ListTile &&
              (widget.title as Text?)?.data == 'Privacy Policy',
        ),
      );
      await tester.pumpAndSettle();

      // Assert - modal should be open
      expect(find.text('Privacy Policy'), findsWidgets);
    },
  );

  testWidgets('should fetch privacy document with correct parameters', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(
      () => mockGetLegalDocument(
        type: any(named: 'type'),
        lang: any(named: 'lang'),
      ),
    ).thenAnswer((_) async => Right(tPrivacyDocument));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // flush 400ms permission-check timer
    await tester.pumpAndSettle();

    // Expand the Legal section first
    await tester.tap(find.text('Legal').first);
    await tester.pumpAndSettle();

    // Tap Privacy Policy
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            (widget.title as Text?)?.data == 'Privacy Policy',
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    verify(
      () => mockGetLegalDocument(
        type: 'privacy',
        lang: any(named: 'lang'),
      ),
    ).called(1);
  });

  testWidgets('should open legal document modal when Terms of Use is tapped', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(
      () => mockGetLegalDocument(
        type: any(named: 'type'),
        lang: any(named: 'lang'),
      ),
    ).thenAnswer((_) async => Right(tTermsDocument));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // flush 400ms permission-check timer
    await tester.pumpAndSettle();

    // Expand the Legal section first
    await tester.tap(find.text('Legal').first);
    await tester.pumpAndSettle();

    // Tap Terms of Use
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            (widget.title as Text?)?.data == 'Terms of Use',
      ),
    );
    await tester.pumpAndSettle();

    // Assert - modal should be open
    expect(find.text('Terms of Use'), findsWidgets);
  });

  testWidgets('should fetch terms document with correct parameters', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(
      () => mockGetLegalDocument(
        type: any(named: 'type'),
        lang: any(named: 'lang'),
      ),
    ).thenAnswer((_) async => Right(tTermsDocument));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // flush 400ms permission-check timer
    await tester.pumpAndSettle();

    // Expand the Legal section first
    await tester.tap(find.text('Legal').first);
    await tester.pumpAndSettle();

    // Tap Terms of Use
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            (widget.title as Text?)?.data == 'Terms of Use',
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    verify(
      () => mockGetLegalDocument(
        type: 'terms',
        lang: any(named: 'lang'),
      ),
    ).called(1);
  });

  testWidgets('should display loading indicator while fetching document', (
    WidgetTester tester,
  ) async {
    // Arrange: use Completer to avoid a pending 5-second timer at test end
    final completer = Completer<Either<Failure, LegalDocument>>();
    when(
      () => mockGetLegalDocument(
        type: any(named: 'type'),
        lang: any(named: 'lang'),
      ),
    ).thenAnswer((_) async => completer.future);

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // flush 400ms permission-check timer
    await tester.pumpAndSettle();

    // Expand the Legal section first
    await tester.tap(find.text('Legal').first);
    await tester.pumpAndSettle();

    // Tap Privacy Policy
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            (widget.title as Text?)?.data == 'Privacy Policy',
      ),
    );
    await tester.pump();

    // Assert: loading spinner visible while document is pending
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // Resolve completer to avoid pending timers at test end
    completer.complete(Right(tPrivacyDocument));
    await tester.pumpAndSettle();
  });

  testWidgets('should display document content in modal after loading', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(
      () => mockGetLegalDocument(
        type: any(named: 'type'),
        lang: any(named: 'lang'),
      ),
    ).thenAnswer((_) async => Right(tPrivacyDocument));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // flush 400ms permission-check timer
    await tester.pumpAndSettle();

    // Expand the Legal section first
    await tester.tap(find.text('Legal').first);
    await tester.pumpAndSettle();

    // Tap Privacy Policy
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            (widget.title as Text?)?.data == 'Privacy Policy',
      ),
    );
    await tester.pumpAndSettle();

    // Assert - should show document content
    expect(find.text('Data Collection'), findsOneWidget);
    expect(find.text('Data Usage'), findsOneWidget);
  });

  testWidgets('should display error UI when document fetch fails', (
    WidgetTester tester,
  ) async {
    // Arrange
    const tFailure = ServerFailure(
      message: 'Failed to fetch privacy policy',
      statusCode: 500,
    );
    when(
      () => mockGetLegalDocument(
        type: any(named: 'type'),
        lang: any(named: 'lang'),
      ),
    ).thenAnswer((_) async => const Left(tFailure));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // flush 400ms permission-check timer
    await tester.pumpAndSettle();

    // Expand the Legal section first
    await tester.tap(find.text('Legal').first);
    await tester.pumpAndSettle();

    // Tap Privacy Policy
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            (widget.title as Text?)?.data == 'Privacy Policy',
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Error al cargar el documento'), findsOneWidget);
  });

  testWidgets('should allow retrying after error', (WidgetTester tester) async {
    // Arrange
    const tFailure = ServerFailure(message: 'Network error', statusCode: 0);
    when(
      () => mockGetLegalDocument(
        type: any(named: 'type'),
        lang: any(named: 'lang'),
      ),
    ).thenAnswer((_) async => const Left(tFailure));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // flush 400ms permission-check timer
    await tester.pumpAndSettle();

    // Expand the Legal section first
    await tester.tap(find.text('Legal').first);
    await tester.pumpAndSettle();

    // Tap Privacy Policy
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            (widget.title as Text?)?.data == 'Privacy Policy',
      ),
    );
    await tester.pumpAndSettle();

    // Verify error is shown
    expect(find.text('Error al cargar el documento'), findsOneWidget);

    // Change mock to return success
    when(
      () => mockGetLegalDocument(
        type: any(named: 'type'),
        lang: any(named: 'lang'),
      ),
    ).thenAnswer((_) async => Right(tPrivacyDocument));

    // Tap Reintentar button
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    // Assert - should now show content
    expect(find.text('Data Collection'), findsOneWidget);
  });

  testWidgets('should display all sections in modal', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(
      () => mockGetLegalDocument(
        type: any(named: 'type'),
        lang: any(named: 'lang'),
      ),
    ).thenAnswer((_) async => Right(tPrivacyDocument));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // flush 400ms permission-check timer
    await tester.pumpAndSettle();

    // Expand the Legal section first
    await tester.tap(find.text('Legal').first);
    await tester.pumpAndSettle();

    // Tap Privacy Policy
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            (widget.title as Text?)?.data == 'Privacy Policy',
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Data Collection'), findsOneWidget);
    expect(find.text('Data Usage'), findsOneWidget);
  });

  testWidgets('should be able to close modal with close button', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(
      () => mockGetLegalDocument(
        type: any(named: 'type'),
        lang: any(named: 'lang'),
      ),
    ).thenAnswer((_) async => Right(tPrivacyDocument));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // flush 400ms permission-check timer
    await tester.pumpAndSettle();

    // Expand the Legal section first
    await tester.tap(find.text('Legal').first);
    await tester.pumpAndSettle();

    // Tap Privacy Policy
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            (widget.title as Text?)?.data == 'Privacy Policy',
      ),
    );
    await tester.pumpAndSettle();

    // Verify modal is open
    expect(find.text('Data Collection'), findsOneWidget);

    // Tap close button
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Assert - modal should be closed
    expect(find.text('Data Collection'), findsNothing);
  });

  testWidgets('should display markdown content in sections', (
    WidgetTester tester,
  ) async {
    // Arrange
    final docWithMarkdown = LegalDocument(
      id: 'privacy-1.0-en',
      version: '1.0',
      type: 'privacy',
      lang: 'en',
      effectiveDate: DateTime(2024, 1, 15),
      sections: const [
        LegalSection(
          id: 'markdown',
          title: 'Markdown Test',
          content:
              '# Header\n**Bold text** and *italic text*\n- List item\n[Links](https://example.com)',
        ),
      ],
    );

    when(
      () => mockGetLegalDocument(
        type: any(named: 'type'),
        lang: any(named: 'lang'),
      ),
    ).thenAnswer((_) async => Right(docWithMarkdown));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // flush 400ms permission-check timer
    await tester.pumpAndSettle();

    // Expand the Legal section first
    await tester.tap(find.text('Legal').first);
    await tester.pumpAndSettle();

    // Tap Privacy Policy
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            (widget.title as Text?)?.data == 'Privacy Policy',
      ),
    );
    await tester.pumpAndSettle();

    // Assert - markdown should be rendered
    expect(find.byType(RichText), findsWidgets);
  });

  testWidgets('should scroll content when document is long', (
    WidgetTester tester,
  ) async {
    // Arrange
    final longDocument = LegalDocument(
      id: 'privacy-1.0-en',
      version: '1.0',
      type: 'privacy',
      lang: 'en',
      effectiveDate: DateTime(2024, 1, 15),
      sections: [
        LegalSection(
          id: 'section-1',
          title: 'Section 1',
          content: 'Section 1\n\n${'A' * 500}',
        ),
        LegalSection(
          id: 'section-2',
          title: 'Section 2',
          content: 'Section 2\n\n${'A' * 500}',
        ),
        LegalSection(
          id: 'section-3',
          title: 'Section 3',
          content: 'Section 3\n\n${'A' * 500}',
        ),
      ],
    );

    when(
      () => mockGetLegalDocument(
        type: any(named: 'type'),
        lang: any(named: 'lang'),
      ),
    ).thenAnswer((_) async => Right(longDocument));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // flush 400ms permission-check timer
    await tester.pumpAndSettle();

    // Expand the Legal section first
    await tester.tap(find.text('Legal').first);
    await tester.pumpAndSettle();

    // Tap Privacy Policy
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            (widget.title as Text?)?.data == 'Privacy Policy',
      ),
    );
    await tester.pumpAndSettle();

    // Assert - should find scrollable content
    expect(find.text('Section 1'), findsOneWidget);
  });
}
