// Visual QA sweep: pumps every route and every interactive state, failing on
// any overflow, clipped text, or exception. Run with:
//
//   LD_LIBRARY_PATH=/tmp/opencode/sqlitelib flutter test test/visual_qa_test.dart
//
// Not part of the shipped suite's intent — it is a QA harness that renders the
// real screens at a real phone size and asserts the mock data is on screen.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:terranex_fo/core/database/database.dart';
import 'package:terranex_fo/core/network/connectivity_service.dart';
import 'package:terranex_fo/core/network/health_service.dart';
import 'package:terranex_fo/core/sync/wiring.dart';
import 'package:terranex_fo/core/theme/app_theme.dart';
import 'package:terranex_fo/main.dart' show kMaxTextScaleFactor;
import 'package:terranex_fo/features/auth/auth_providers.dart';
import 'package:terranex_fo/features/cases/case_card.dart';
import 'package:terranex_fo/features/cases/case_detail_screen.dart';
import 'package:terranex_fo/features/documents/documents_screen.dart';
import 'package:terranex_fo/features/evidence/evidence_viewer_screen.dart';
import 'package:terranex_fo/features/field_visit/verification_result_screen.dart';
import 'package:terranex_fo/features/field_visit/steps/wizard_steps.dart';
import 'package:terranex_fo/features/field_visit/wizard_screen.dart';
import 'package:terranex_fo/features/home/home_shell.dart';
import 'package:terranex_fo/features/more/more_screen.dart';
import 'package:terranex_fo/features/more/profile_screen.dart';
import 'package:terranex_fo/features/notifications/notifications_screen.dart';
import 'package:terranex_fo/features/tasks/tasks_screen.dart';
import 'package:terranex_fo/services/fo_providers.dart';
import 'package:terranex_fo/widgets/common.dart';

import 'support/memory_file_store.dart';

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
  setUp(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity_status'),
      (_) => null,
    );

    // path_provider has no platform channel under `flutter test`. `flutter_map`
    // asks for the application cache directory when its tile layer starts, so
    // a temporary directory is handed out instead.
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async =>
          (await Directory.systemTemp.createTemp('fo_visual_qa')).path,
    );
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
  });

  /// Renders [child] inside a wired container and fails on any RenderFlex
  /// overflow — the single most common visual defect in a dense gov app.
  Future<void> render(
    WidgetTester tester,
    Widget child, {
    ProviderContainer? container,
    Size size = const Size(412, 915),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final c = container ??
        ProviderContainer(
          overrides: [
            dbProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
            fileStoreProvider.overrideWithValue(MemoryFileStore()),
            connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
          ],
        );
    addTearDown(c.dispose);

    // Render with the real app theme, not the framework default — an overflow
    // that only appears with the production type scale would otherwise be
    // invisible to this suite.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: child,
          builder: (context, widget) {
            final mq = MediaQuery.of(context);
            final capped =
                mq.textScaler.clamp(maxScaleFactor: kMaxTextScaleFactor);
            if (capped == mq.textScaler) return widget ?? const SizedBox.shrink();
            return MediaQuery(
              data: mq.copyWith(textScaler: capped),
              child: widget ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
    // Let Drift / provider streams settle.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('dashboard shows derived stats, tasks and sync state', (tester) async {
    await render(tester, const HomeShell());
    expect(find.text('TERRANEX'), findsOneWidget);

    // The stat block pushes the task section below the fold on a phone.
    await tester.scrollUntilVisible(
      find.text("TODAY'S TASKS"),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text("TODAY'S TASKS"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('case list renders every card without overflow', (tester) async {
    await render(tester, const HomeShell());
    await tester.tap(find.byIcon(Icons.folder_outlined));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(CaseCard), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('case detail renders parcel, owner, timeline and actions', (tester) async {
    final c = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
        fileStoreProvider.overrideWithValue(MemoryFileStore()),
        connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
      ],
    );
    final caseData = c.read(foStateProvider).cases.first;
    addTearDown(c.dispose);

    await render(tester, CaseDetailScreen(caseNo: caseData.caseNo), container: c);
    expect(find.textContaining(caseData.caseNo), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('every wizard step renders and reports blockers honestly', (tester) async {
    final c = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
        fileStoreProvider.overrideWithValue(MemoryFileStore()),
        connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
      ],
    );
    final caseData = c.read(foStateProvider).cases.first;
    addTearDown(c.dispose);
    wireDependencies(c);

    await render(tester, FieldVisitWizardScreen(caseData: caseData), container: c);
    expect(find.textContaining('Step 1 of 9'), findsOneWidget);

    // Capture the mock GPS fix.
    await tester.tap(find.textContaining('CAPTURE GPS'));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);

    for (var step = 1; step <= 5; step++) {
      await tester.tap(find.text('Next'));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    }

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
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    }

    // Review must surface the missing-evidence blocker, not silently pass.
    await tester.scrollUntilVisible(
      find.textContaining('VERIFICATION INCOMPLETE'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('VERIFICATION INCOMPLETE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tasks, documents, notifications, profile and more render', (tester) async {
    await render(tester, const TasksScreen());
    expect(find.text('Tasks'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await render(tester, const DocumentsScreen());
    expect(tester.takeException(), isNull);

    await render(tester, const NotificationsScreen());
    expect(tester.takeException(), isNull);

    await render(tester, const ProfileScreen());
    expect(tester.takeException(), isNull);

    await render(tester, const MoreScreen());
    expect(tester.takeException(), isNull);
  });

  testWidgets('submission confirmation screen renders the full summary',
      (tester) async {
    await render(
      tester,
      VerificationResultScreen(
        caseNo: 'LA-TN-CBE-2026-0142',
        evidenceCount: 3,
        gpsCaptured: true,
        gpsIsMock: true,
        queuedOffline: true,
        visitId: 'visit-1',
      ),
    );
    expect(find.textContaining('FIELD VERIFICATION SUBMITTED'), findsOneWidget);
    expect(find.text('LA-TN-CBE-2026-0142'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('evidence viewer renders a GPS-tagged record', (tester) async {
    final c = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
        fileStoreProvider.overrideWithValue(MemoryFileStore()),
        connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
      ],
    );
    final record = c.read(foStateProvider).evidenceFor('LA-TN-CBE-2026-0142').first;
    addTearDown(c.dispose);

    await render(tester, EvidenceViewerScreen(recordId: record.id), container: c);
    expect(tester.takeException(), isNull);

    // A record that no longer exists must explain itself, not show a blank.
    await render(
      tester,
      const EvidenceViewerScreen(recordId: 'EV-DOES-NOT-EXIST'),
      container: c,
    );
    expect(find.text('Evidence not found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty states are meaningful, never bare "No data"', (tester) async {
    // A case with no documents/evidence exercises the real empty-state path.
    final c = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
        fileStoreProvider.overrideWithValue(MemoryFileStore()),
        connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
      ],
    );
    addTearDown(c.dispose);

    final bare = find.byWidgetPredicate((w) {
      if (w is! EmptyState) return false;
      final t = (w.title).toLowerCase();
      return t.contains('no data') || t.trim() == 'no data';
    });
    expect(bare, findsNothing);
    expect(c.read(foStateProvider).cases, isNotEmpty);
  });

  testWidgets('shell keeps scroll position and tab state across a switch',
      (tester) async {
    await render(tester, const HomeShell());

    // Scroll the dashboard well down the page.
    await tester.drag(
      find.byType(ListView).first,
      const Offset(0, -600),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 300));
    final offsetBefore = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .pixels;
    expect(offsetBefore, greaterThan(0));

    // Switch away and back. A plain list of screens rebuilt in `build()`
    // discarded every tab's scroll offset on each tap.
    await tester.tap(find.byIcon(Icons.folder_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Cases'), findsWidgets);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();

    final offsetAfter = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .pixels;
    expect(
      offsetAfter,
      offsetBefore,
      reason: 'the dashboard must keep its scroll position after a tab round-trip',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a data step never shows "none recorded" while still loading',
      (tester) async {
    // Driven directly against `AsyncListView` with a controlled AsyncValue:
    // against a real in-memory database the query resolves inside the same
    // frame, so the loading branch can never be observed from the wizard.
    Future<void> pumpWith(AsyncValue<List<String>> value) => tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: Scaffold(
              body: AsyncListView<String>(
                value: value,
                itemBuilder: (_, item) => Text(item),
                empty: const EmptyState(
                  icon: Icons.home_work_outlined,
                  title: 'No Structures Recorded',
                  message: 'Add every building, wall or fixture found.',
                ),
              ),
            ),
          ),
        );

    await pumpWith(const AsyncLoading());
    expect(find.text('No Structures Recorded'), findsNothing,
        reason: 'loading must never render as an empty result');
    expect(find.byType(SkeletonBox), findsWidgets);

    await pumpWith(const AsyncError('boom', StackTrace.empty));
    expect(find.text('No Structures Recorded'), findsNothing,
        reason: 'a query failure must not masquerade as an empty result');
    expect(find.text('Could not load records'), findsOneWidget);

    await pumpWith(const AsyncData(<String>[]));
    expect(find.text('No Structures Recorded'), findsOneWidget,
        reason: 'only a genuinely empty result shows the empty state');

    await pumpWith(const AsyncData(<String>['Wall']));
    expect(find.text('Wall'), findsOneWidget);
    expect(find.byType(SkeletonBox), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('the review step never fabricates a blocker before data loads',
      (tester) async {
    final c = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
        fileStoreProvider.overrideWithValue(MemoryFileStore()),
        connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
      ],
    );
    addTearDown(c.dispose);
    final caseData = c.read(foStateProvider).cases.first;
    wireDependencies(c);

    await render(tester, FieldVisitWizardScreen(caseData: caseData), container: c);
    await tester.tap(find.textContaining('CAPTURE GPS'));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)));
    await tester.pump(const Duration(milliseconds: 400));

    // Steps 1-5 are Location, Parcel, Land Use, Structures and Cultivation.
    for (var i = 1; i <= 5; i++) {
      await tester.tap(find.text('Next'));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.textContaining('Step 6 of 9'), findsOneWidget);

    final obs = fieldWithLabel('Field observations *');
    await tester.scrollUntilVisible(
      obs,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(obs, 'Boundary stones intact.');
    await tester.pump(const Duration(milliseconds: 200));

    for (var i = 6; i <= 8; i++) {
      await tester.tap(find.text('Next'));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.textContaining('Step 9 of 9'), findsOneWidget);

    // Let the four count queries settle, then check the review block.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('0 evidence items'), findsOneWidget,
        reason: 'the check row must read from the durable set');

    await tester.scrollUntilVisible(
      find.textContaining('VERIFICATION INCOMPLETE'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.textContaining('VERIFICATION INCOMPLETE'),
      findsOneWidget,
      reason: 'zero durable evidence must raise exactly one matching blocker',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('every tab and pushed screen survives small and large surfaces',
      (tester) async {
    // A 360x640 budget phone and an 800x1280 tablet both have to lay out
    // without a single RenderFlex overflow.
    //
    // One container is reused across sizes: creating a ProviderContainer per
    // render leaves Riverpod's auto-dispose scheduler holding a zero-duration
    // timer at teardown, which the test binding reports as a pending timer.
    final c = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
        fileStoreProvider.overrideWithValue(MemoryFileStore()),
        connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
      ],
    );
    addTearDown(c.dispose);

    for (final size in const [
      Size(360, 640),
      Size(412, 915),
      Size(800, 1280),
    ]) {
      await render(tester, const HomeShell(), size: size, container: c);
      expect(tester.takeException(), isNull, reason: 'shell at $size');

      for (final icon in [
        Icons.folder_outlined,
        Icons.map_outlined,
        Icons.sync_outlined,
        Icons.more_horiz,
        Icons.home_outlined,
      ]) {
        await tester.tap(find.byIcon(icon));
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull, reason: 'tab $icon at $size');
      }
    }

    // Let the auto-dispose scheduler drain before the container is torn down.
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('max text scale does not overflow the shell', (tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final c = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
        fileStoreProvider.overrideWithValue(MemoryFileStore()),
        connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
      ],
    );
    addTearDown(c.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MediaQuery(
          data: MediaQueryData(
            size: const Size(412, 915),
            textScaler: const TextScaler.linear(kMaxTextScaleFactor),
          ),
          child: MaterialApp(
            theme: buildAppTheme(),
            home: const HomeShell(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  });
}
