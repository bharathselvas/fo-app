import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bhoomi_setu_fo/core/database/database.dart';
import 'package:bhoomi_setu_fo/core/sync/wiring.dart';
import 'package:bhoomi_setu_fo/features/auth/auth_providers.dart';
import 'package:bhoomi_setu_fo/features/cases/case_card.dart';
import 'package:bhoomi_setu_fo/features/cases/case_detail_screen.dart';
import 'package:bhoomi_setu_fo/features/field_visit/wizard_screen.dart';
import 'package:bhoomi_setu_fo/features/home/home_shell.dart';
import 'package:bhoomi_setu_fo/features/tasks/tasks_screen.dart';
import 'package:bhoomi_setu_fo/services/fo_providers.dart';

void main() {
  testWidgets('dashboard renders derived stats and today\'s tasks', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeShell())),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('BHOOMI SETU'), findsOneWidget);
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

    expect(find.text('SECTION 1 — PARCEL'), findsOneWidget);
    expect(find.text('START FIELD VERIFICATION'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('SECTION 4 — ASSIGNED TASK'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('SECTION 4 — ASSIGNED TASK'), findsOneWidget);
  });

  testWidgets('verification wizard walks through all nine steps', (tester) async {
    // Widget tests have no path_provider channel — use an in-memory database.
    final db = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
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

    for (var step = 1; step <= 8; step++) {
      await tester.tap(find.text('Next'));
      // Each Next writes the visit back to SQLite, so let real async settle.
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
    expect(find.textContaining('${state.tasks.length} TOTAL'), findsOneWidget);
  });
}
