import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:terranex_fo/core/database/database.dart';
import 'package:terranex_fo/core/network/connectivity_service.dart';
import 'package:terranex_fo/core/network/health_service.dart';
import 'package:terranex_fo/core/sync/wiring.dart';
import 'package:terranex_fo/features/auth/auth_providers.dart';
import 'package:terranex_fo/features/cases/case_card.dart';
import 'package:terranex_fo/features/cases/case_detail_screen.dart';
import 'package:terranex_fo/features/field_visit/wizard_screen.dart';
import 'package:terranex_fo/features/home/home_shell.dart';
import 'package:terranex_fo/features/tasks/tasks_screen.dart';
import 'package:terranex_fo/services/fo_providers.dart';

import 'support/memory_file_store.dart';

/// Connectivity that always reports a usable network without touching the
/// platform channel.
class _OnlineConnectivity extends ConnectivityService {
  _OnlineConnectivity() : super(HealthService());

  @override
  ConnectionStatus get status => ConnectionStatus.online;

  @override
  Future<void> refresh() async {}

  @override
  void markSyncing() {}

  @override
  Stream<ConnectionStatus> get statusStream =>
      const Stream<ConnectionStatus>.empty();

  @override
  void dispose() {}
}

/// connectivity_plus raises `MissingPluginException` when its event channel is
/// activated with no engine behind it. Registering a handler keeps that from
/// surfacing as an unexpected test error.
void _stubConnectivityChannel() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity_status'),
    (_) => null,
  );
}


/// Finds a text field by its floating label.
///
/// The app uses `floatingLabelBehavior: always`, so a field's label is painted
/// by the `InputDecorator` as a sibling overlay rather than a child of the
/// `TextField` — `find.widgetWithText(TextField, ...)` no longer resolves.
Finder fieldWithLabel(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byType(TextField),
    );

void main() {
  setUp(_stubConnectivityChannel);
  testWidgets('dashboard renders derived stats and today\'s tasks', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeShell())),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('TERRANEX'), findsOneWidget);
    expect(find.text("TODAY'S TASKS"), findsOneWidget);

    final state = ProviderScope.containerOf(tester.element(find.byType(HomeShell)))
        .read(foStateProvider);
    // Derived stat tiles: cases / pending / completed / overdue.
    expect(find.text('${state.cases.length}'), findsWidgets);
  });

  testWidgets('cases tab lists the case dossier cards', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeShell())),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byIcon(Icons.folder_outlined));
    await tester.pump(const Duration(milliseconds: 300));

    final container = ProviderScope.containerOf(tester.element(find.byType(CasesTab)));
    final cases = container.read(filteredCasesProvider);
    // The list is lazily built — assert the count row and that real cards show.
    expect(find.text('${cases.length} CASES'), findsOneWidget);
    expect(find.byType(CaseCard), findsWidgets);
    expect(find.text(cases.first.caseNo), findsOneWidget);
  });

  testWidgets('case dossier opens with parcel section and verification action',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final caseNo = container.read(foStateProvider).cases.first.caseNo;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: CaseDetailScreen(caseNo: caseNo),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('START FIELD VERIFICATION'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('PARCEL'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('PARCEL'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('ASSIGNED TASK'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('ASSIGNED TASK'), findsOneWidget);
  });

  testWidgets('verification wizard walks through all nine steps', (tester) async {
    // Widget tests have no path_provider channel — use an in-memory database
    // and an in-memory file store so `startVisit` can resolve a visit row.
    final db = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
        fileStoreProvider.overrideWithValue(MemoryFileStore()),
        // connectivity_plus has no platform channel under `flutter test`; a
        // fake keeps the wizard's ONLINE/OFFLINE banner and SYNC NOW live
        // instead of throwing MissingPluginException.
        connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
      ],
    );
    addTearDown(() async {
      await db.close();
      container.dispose();
    });
    final caseData = container.read(foStateProvider).cases.first;
    wireDependencies(container);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: FieldVisitWizardScreen(caseData: caseData)),
      ),
    );
    // Visit record creation hits the local database — let real async settle.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('Step 1 of 9'), findsOneWidget);

    // Step 1 is Location and the wizard refuses to advance without a fix, so
    // capture GPS first — exactly what the officer must do in the field.
    await tester.tap(find.textContaining('CAPTURE GPS'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Step 1 of 9'), findsOneWidget,
        reason: 'stays on Location while GPS is missing');

    for (var step = 1; step <= 5; step++) {
      await tester.tap(find.text('Next'));
      // Each Next writes the visit back to SQLite, so let real async settle.
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('Step ${step + 1} of 9'), findsOneWidget);
    }

    // Step 6 (Occupant) requires field observations before it will advance.
    // The field may sit below the fold on a small test surface.
    await tester.scrollUntilVisible(
      fieldWithLabel('Field observations *'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      fieldWithLabel('Field observations *'),
      'Boundary stones intact; no encroachment observed.',
    );
    await tester.pump(const Duration(milliseconds: 200));

    for (var step = 6; step <= 8; step++) {
      await tester.tap(find.text('Next'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('Step ${step + 1} of 9'), findsOneWidget);
    }

    expect(find.text('REVIEW & DECLARATION'), findsOneWidget);
    expect(find.text('SUBMIT VERIFICATION'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Tick the declaration to enable submission.'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Tick the declaration to enable submission.'), findsOneWidget);

    final submit = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'SUBMIT VERIFICATION'));
    expect(submit.onPressed, isNull, reason: 'submission stays locked until declared');
  });

  testWidgets('tasks screen opens from the dashboard', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: TasksScreen())),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final state = ProviderScope.containerOf(tester.element(find.byType(TasksScreen)))
        .read(foStateProvider);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.textContaining('${state.tasks.length} total'), findsOneWidget);
  });
}
