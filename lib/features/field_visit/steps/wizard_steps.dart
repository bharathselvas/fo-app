import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/land_case.dart';
import '../../../widgets/common.dart';
import '../../../widgets/motion.dart';
import '../wizard_state.dart';

/// Shared list chrome for the four data-collection steps.
///
/// Every one of those steps used an uncached `FutureBuilder` whose `future:` was
/// a method re-invoked on each build, and none of them inspected
/// `connectionState` — so a step in flight rendered "No Structures Recorded",
/// i.e. a confident claim that the officer had recorded nothing. The review step
/// went further: it read `0` out of a `[0,0,0,0]` fallback and manufactured a
/// "no evidence captured" blocker on every rebuild before the query resolved.
///
/// [StepScaffold] owns that distinction: shimmer while loading, an explicit
/// error card on failure, [EmptyState] only when the query genuinely returned
/// nothing.
/// Combines the four step queries into the review step's counts.
///
/// Returns null while any query is still in flight. The previous build
/// substituted a `[0, 0, 0, 0]` fallback, which meant the review step rendered
/// a fabricated "no evidence captured" blocker on every rebuild before the
/// query resolved.
AsyncValue<(int, int, int, int)>? combineCounts(
  AsyncValue<List<Structure>> structures,
  AsyncValue<List<Vegetation>> vegetation,
  AsyncValue<List<LocalDocument>> documents,
  AsyncValue<List<Evidence>> evidence,
) {
  if (structures.isLoading ||
      vegetation.isLoading ||
      documents.isLoading ||
      evidence.isLoading) {
    return null;
  }
  if (structures.hasError || vegetation.hasError || documents.hasError || evidence.hasError) {
    return const AsyncError('Could not read captured records', StackTrace.empty);
  }
  return AsyncData((
    structures.valueOrNull?.length ?? 0,
    vegetation.valueOrNull?.length ?? 0,
    documents.valueOrNull?.length ?? 0,
    evidence.valueOrNull?.length ?? 0,
  ));
}

class StepScaffold extends StatelessWidget {
  const StepScaffold({
    super.key,
    required this.title,
    required this.description,
    required this.children,
    this.trailing,
  });

  final String title;
  final String description;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      key: PageStorageKey('step-$title'),
      padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.lg, Insets.lg, Insets.xxl),
      children: [
        Text(title.toUpperCase(), style: theme.textTheme.labelSmall),
        const Gap(Insets.xs),
        Text(description, style: theme.textTheme.bodySmall),
        const Gap(Insets.lg),
        if (trailing != null) ...[trailing!, const Gap(Insets.md)],
        ...children,
      ],
    );
  }
}

/// Renders the three states of a drift query without ever conflating them.
class AsyncListView<T> extends StatelessWidget {
  const AsyncListView({
    super.key,
    required this.value,
    required this.itemBuilder,
    required this.empty,
    this.header,
  });

  final AsyncValue<List<T>> value;
  final Widget Function(BuildContext, T) itemBuilder;
  final Widget empty;
  final List<Widget>? header;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => Column(
        children: [
          ...?header,
          const _ListSkeleton(),
        ],
      ),
      error: (e, _) => Column(
        children: [
          ...?header,
          EmptyState(
            icon: Icons.error_outline,
            tone: EmptyTone.danger,
            title: 'Could not load records',
            message: '$e',
          ),
        ],
      ),
      data: (items) {
        if (items.isEmpty) {
          return Column(
            children: [
              ...?header,
              empty,
            ],
          );
        }
        return Column(
          children: [
            ...?header,
            for (final item in items) itemBuilder(context, item),
          ],
        );
      },
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: Insets.md),
            child: Card(
              child: Padding(
                padding: Insets.card,
                child: Row(
                  children: [
                    const SkeletonBox(width: 40, height: 40, radius: Radii.sm),
                    const Gap(Insets.md, horizontal: true),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 140, height: 12),
                          const Gap(Insets.sm),
                          const SkeletonBox(width: double.infinity, height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Location

class LocationStep extends ConsumerWidget {
  const LocationStep({super.key, required this.onCaptureGps});

  final Future<void> Function() onCaptureGps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(wizardControllerProvider);
    final loc = s.location;

    return StepScaffold(
      title: 'GPS location',
      description:
          'Capture your position at the parcel before recording observations. '
          'Every field record is GPS-tagged.',
      children: [
        SectionCard(
          title: 'Position fix',
          icon: Icons.my_location,
          children: [
            InfoRow(
              label: 'Latitude',
              value: loc?.latitude.toStringAsFixed(6) ?? '—',
              highlight: loc != null,
            ),
            InfoRow(
              label: 'Longitude',
              value: loc?.longitude.toStringAsFixed(6) ?? '—',
              highlight: loc != null,
            ),
            InfoRow(label: 'Accuracy', value: loc?.accuracyLabel ?? '—'),
            InfoRow(
              label: 'Timestamp',
              value: loc == null
                  ? '—'
                  : DateFormat('d MMM yyyy, h:mm a').format(loc.timestamp),
            ),
            InfoRow(
              label: 'Source',
              value: loc == null
                  ? '—'
                  : loc.isMock
                      ? 'DEMO FIX (near parcel)'
                      : 'DEVICE GPS',
            ),
          ],
        ),
        const Gap(Insets.lg),
        if (loc != null)
          Padding(
            padding: const EdgeInsets.only(bottom: Insets.lg),
            child: AppChip(
              label: loc.isMock ? 'GPS tagged (demo fix)' : 'GPS locked',
              color: loc.isMock ? AppColors.warning : AppColors.success,
              icon: Icons.check_circle_outline,
              uppercase: false,
            ),
          ),
        FilledButton.icon(
          onPressed: s.locating ? null : onCaptureGps,
          icon: s.locating
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.my_location),
          label: Text(
            s.locating
                ? 'Getting GPS…'
                : loc == null
                    ? 'CAPTURE GPS'
                    : 'RE-CAPTURE GPS',
          ),
        ),
        if (s.gpsNotice != null) ...[
          const Gap(Insets.lg),
          AppBanner(
            message: s.gpsNotice!,
            icon: Icons.info_outline,
            tone: AppBannerTone.warning,
          ),
        ],
      ],
    );
  }
}

// ------------------------------------------------------------------ Parcel

class ParcelStep extends StatelessWidget {
  const ParcelStep({super.key, required this.caseData});

  final LandCase caseData;

  @override
  Widget build(BuildContext context) {
    final c = caseData;

    return StepScaffold(
      title: 'Parcel under verification',
      description:
          'Read-only from the case file. Confirm you are at the right parcel '
          'before proceeding.',
      children: [
        SectionCard(
          title: 'Parcel details',
          icon: Icons.landscape_outlined,
          children: [
            InfoRow(label: 'Case', value: c.caseNo, highlight: true),
            InfoRow(label: 'Parcel ID', value: c.parcelId),
            InfoRow(label: 'Survey Number', value: c.surveyNo, highlight: true),
            InfoRow(label: 'Village', value: c.village),
            InfoRow(label: 'Taluk', value: c.taluk),
            InfoRow(label: 'District', value: c.district),
            InfoRow(label: 'Extent', value: c.extentLabel, highlight: true),
            InfoRow(label: 'Land type', value: c.landType),
          ],
        ),
        const Gap(Insets.lg),
        SectionCard(
          title: 'Landowner on record',
          icon: Icons.person_outline,
          children: [
            InfoRow(label: 'Name', value: c.landOwner.name, highlight: true),
            InfoRow(label: 'Ownership', value: c.landOwner.ownershipType),
            InfoRow(label: 'Verification', value: c.landOwner.verificationStatus),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Land use

class LandUseStep extends ConsumerStatefulWidget {
  const LandUseStep({super.key});

  @override
  ConsumerState<LandUseStep> createState() => _LandUseStepState();
}

class _LandUseStepState extends ConsumerState<LandUseStep> {
  late final TextEditingController _notes = TextEditingController(
    text: ref.read(wizardControllerProvider).notes,
  );

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(wizardControllerProvider);
    final ctl = ref.read(wizardControllerProvider.notifier);
    final theme = Theme.of(context);

    return StepScaffold(
      title: 'Land use verification',
      description: 'Confirm the recorded land use against what is on the ground.',
      children: [
        _choiceBlock(
          theme: theme.textTheme,
          label: 'Land use',
          options: kLandUses,
          selected: s.landUse,
          onSelect: ctl.setLandUse,
        ),
        const Gap(Insets.lg),
        _choiceBlock(
          theme: theme.textTheme,
          label: 'Irrigation',
          options: kIrrigationTypes,
          selected: s.irrigation,
          onSelect: ctl.setIrrigation,
        ),
        const Gap(Insets.lg),
        _binaryBlock(
          theme: theme.textTheme,
          label: 'Boundary confirmed on ground',
          selected: s.boundaryConfirmed,
          onSelect: ctl.setBoundaryConfirmed,
        ),
        const Gap(Insets.lg),
        TextField(
          controller: _notes,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          onChanged: ctl.setNotes,
          decoration: const InputDecoration(
            labelText: 'Land-use notes',
            hintText: 'Optional — irrigation source, cropping pattern…',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------- Structures

class StructuresStep extends ConsumerWidget {
  const StructuresStep({super.key, required this.structures, required this.onAdd});

  final AsyncValue<List<Structure>> structures;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StepScaffold(
      title: 'Structures',
      description: 'Record every building, wall or fixture found on the parcel.',
      children: [
        AsyncListView<Structure>(
          value: structures,
          header: [
            _AddRow(label: 'Add Structure', onTap: onAdd),
            const Gap(Insets.md),
          ],
          empty: const EmptyState(
            icon: Icons.home_work_outlined,
            title: 'No Structures Recorded',
            message: 'Add every building, wall or fixture found on the parcel.',
          ),
          itemBuilder: (context, s) => Padding(
            padding: const EdgeInsets.only(bottom: Insets.sm),
            child: _DataRow(
              title: s.type,
              subtitle: [
                if (s.areaValue != null) '${s.areaValue} ${s.areaUnit}',
                if (s.constructionType != null) s.constructionType!,
                if (s.condition != null) s.condition!,
                if (s.notes != null && s.notes!.isNotEmpty) s.notes!,
              ].join(' · '),
              syncLabel: s.syncStatus,
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------- Cultivation

class CultivationStep extends ConsumerWidget {
  const CultivationStep({super.key, required this.vegetation, required this.onAdd});

  final AsyncValue<List<Vegetation>> vegetation;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StepScaffold(
      title: 'Trees & crops',
      description: 'Record standing crops, trees and their extent on the parcel.',
      children: [
        AsyncListView<Vegetation>(
          value: vegetation,
          header: [
            _AddRow(label: 'Add Trees / Crops', onTap: onAdd),
            const Gap(Insets.md),
          ],
          empty: const EmptyState(
            icon: Icons.grass,
            title: 'No Cultivation Recorded',
            message: 'Record standing crops, trees and their extent on the parcel.',
          ),
          itemBuilder: (context, v) => Padding(
            padding: const EdgeInsets.only(bottom: Insets.sm),
            child: _DataRow(
              title: '${v.species} × ${v.count}',
              subtitle: [
                if (v.cropType != null) v.cropType!,
                if (v.areaHa != null) '${v.areaHa} ha',
                if (v.notes != null && v.notes!.isNotEmpty) v.notes!,
              ].join(' · '),
              syncLabel: v.syncStatus,
              accent: AppColors.success,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Occupant

class OccupantStep extends ConsumerStatefulWidget {
  const OccupantStep({super.key, required this.defaultOccupantName});

  final String defaultOccupantName;

  @override
  ConsumerState<OccupantStep> createState() => _OccupantStepState();
}

class _OccupantStepState extends ConsumerState<OccupantStep> {
  late final TextEditingController _observations =
      TextEditingController(text: ref.read(wizardControllerProvider).observations);
  late final TextEditingController _occupantName = TextEditingController(
    text: ref.read(wizardControllerProvider).occupantName.isEmpty
        ? widget.defaultOccupantName
        : ref.read(wizardControllerProvider).occupantName,
  );

  @override
  void dispose() {
    _observations.dispose();
    _occupantName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(wizardControllerProvider);
    final ctl = ref.read(wizardControllerProvider.notifier);
    final theme = Theme.of(context);

    return StepScaffold(
      title: 'Occupant & observations',
      description:
          'Record who was present and what you saw. Observations are mandatory.',
      children: [
        SectionCard(
          title: 'Person on record',
          icon: Icons.badge_outlined,
          children: [
            InfoRow(
              label: 'Landowner',
              value: widget.defaultOccupantName,
              highlight: true,
            ),
          ],
        ),
        const Gap(Insets.lg),
        _binaryBlock(
          theme: theme.textTheme,
          label: 'Is the occupant present at the site?',
          selected: s.occupantPresent,
          yesLabel: 'PRESENT',
          noLabel: 'ABSENT',
          onSelect: ctl.setOccupantPresent,
        ),
        const Gap(Insets.lg),
        TextField(
          controller: _occupantName,
          textCapitalization: TextCapitalization.words,
          onChanged: ctl.setOccupantName,
          decoration: const InputDecoration(
            labelText: 'Occupant / representative name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const Gap(Insets.lg),
        // The hot path. This used to be `onChanged: (_) => setState(() {})` on
        // the wizard's own state, rebuilding the Scaffold, AppBar, progress bar,
        // banner and both nav buttons on every single character.
        TextField(
          controller: _observations,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          onChanged: ctl.setObservations,
          onEditingComplete: ctl.persistObservations,
          decoration: const InputDecoration(
            labelText: 'Field observations *',
            hintText: 'Required. Note discrepancies in extent, encroachment, '
                'crop condition, disputes…',
            alignLabelWithHint: true,
          ),
        ),
        const Gap(Insets.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              s.hasObservations ? Icons.check_circle : Icons.info_outline,
              size: 14,
              color: s.hasObservations ? AppColors.success : AppColors.textTertiary,
            ),
            const Gap(Insets.sm, horizontal: true),
            Expanded(
              child: Text(
                s.hasObservations
                    ? 'Recorded. This will be saved when you leave the step.'
                    : 'Field observations are mandatory. Without them the record '
                        'is rejected at District review.',
                style: theme.textTheme.bodySmall!.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --------------------------------------------------------------- Documents

class DocumentsStep extends ConsumerWidget {
  const DocumentsStep({super.key, required this.documents, required this.onAdd});

  final AsyncValue<List<LocalDocument>> documents;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StepScaffold(
      title: 'Documents',
      description:
          'Attach field-collected records (Pattta, EC, 7/12 extract, photos of papers).',
      children: [
        AsyncListView<LocalDocument>(
          value: documents,
          header: [
            _AddRow(label: 'Add File', onTap: onAdd),
            const Gap(Insets.md),
          ],
          empty: const EmptyState(
            icon: Icons.folder_open,
            title: 'No Documents Captured',
            message: 'No field documents captured yet. Tap "Add File" to attach one.',
          ),
          itemBuilder: (context, d) => Padding(
            padding: const EdgeInsets.only(bottom: Insets.sm),
            child: _DataRow(
              title: d.type.replaceAll('_', ' ').toUpperCase(),
              subtitle: d.localFilePath.split('/').last,
              syncLabel: d.syncStatus,
              icon: Icons.description_outlined,
              accent: AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Evidence

class EvidenceStep extends ConsumerWidget {
  const EvidenceStep({
    super.key,
    required this.evidence,
    required this.onCapture,
  });

  final AsyncValue<List<Evidence>> evidence;
  final Future<void> Function() onCapture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(wizardControllerProvider);
    final ctl = ref.read(wizardControllerProvider.notifier);

    return StepScaffold(
      title: 'Field evidence',
      description:
          'Capture photographs of the boundary, land use, structures and survey '
          'stones from the field.',
      children: [
        Text('EVIDENCE TYPE', style: Theme.of(context).textTheme.labelSmall),
        const Gap(Insets.sm),
        Wrap(
          spacing: Insets.sm,
          runSpacing: Insets.sm,
          children: [
            for (final t in kEvidenceTypes)
              ChoiceChip(
                label: Text(t),
                selected: s.evidenceType == t,
                onSelected: (_) => ctl.setEvidenceType(t),
              ),
          ],
        ),
        const Gap(Insets.lg),
        AsyncListView<Evidence>(
          value: evidence,
          empty: const EmptyState(
            icon: Icons.photo_camera_outlined,
            title: 'No Evidence Yet',
            message: 'Capture photographs of the boundary, land use, structures '
                'and survey stones from the field.',
          ),
          itemBuilder: (context, e) => Padding(
            padding: const EdgeInsets.only(bottom: Insets.sm),
            child: _EvidenceCard(record: e),
          ),
        ),
        const Gap(Insets.lg),
        FilledButton.icon(
          onPressed: onCapture,
          icon: const Icon(Icons.camera_alt),
          label: Text('+ CAPTURE (${s.evidenceType})'),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ Review

class ReviewStep extends ConsumerWidget {
  const ReviewStep({
    super.key,
    required this.caseNo,
    required this.locationSummary,
    required this.counts,
    required this.blockers,
    required this.offline,
  });

  final String caseNo;
  final String locationSummary;

  /// Null while the counts query is still in flight. The previous build
  /// substituted `[0, 0, 0, 0]` here, which fabricated a "no evidence captured"
  /// blocker on every rebuild before the query resolved.
  final AsyncValue<(int, int, int, int)>? counts;
  final List<String> blockers;
  final bool offline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(wizardControllerProvider);
    final ctl = ref.read(wizardControllerProvider.notifier);

    return StepScaffold(
      title: 'Review & declaration',
      description: 'Confirm the record before submitting it to the District office.',
      children: [
        Card(
          child: Column(
            children: [
              _CheckRow(ok: s.hasLocation, label: 'GPS location captured'),
              _CheckRow(ok: s.boundaryConfirmed, label: 'Parcel boundary confirmed'),
              _CheckRow(ok: s.landUse.isNotEmpty, label: 'Land use verified (${s.landUse})'),
              _CheckRow(ok: s.hasObservations, label: 'Observations recorded'),
              if (counts == null)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.lg),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      Gap(Insets.md, horizontal: true),
                      Text('Checking captured records…'),
                    ],
                  ),
                )
              else ..._countChecks(counts!),
            ],
          ),
        ),
        const Gap(Insets.lg),
        AppBanner(
          tone: offline ? AppBannerTone.warning : AppBannerTone.success,
          icon: offline ? Icons.cloud_off_outlined : Icons.cloud_done_outlined,
          title: offline ? 'Network: offline' : 'Network: online',
          message: offline
              ? 'Your verification will be stored on the device and uploaded '
                  'automatically when connectivity returns.'
              : 'Submission will be queued and synchronized with the backend.',
        ),
        const Gap(Insets.lg),
        SectionCard(
          title: 'Record',
          icon: Icons.folder_outlined,
          children: [
            InfoRow(label: 'Case', value: caseNo, highlight: true),
            InfoRow(label: 'Position', value: locationSummary),
          ],
        ),
        const Gap(Insets.lg),
        TappableCard(
          onTap: () => ctl.setDeclared(!s.declared),
          padding: const EdgeInsets.all(Insets.md),
          color: s.declared ? AppColors.successSoft : AppColors.surface,
          borderColor: s.declared ? AppColors.success.withValues(alpha: 0.4) : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: s.declared,
                onChanged: (v) => ctl.setDeclared(v ?? false),
              ),
              const Gap(Insets.sm, horizontal: true),
              Expanded(
                child: Text(
                  'I declare that the observations recorded above are true to the '
                  'best of my knowledge, based on physical verification at the site.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(height: 1.45),
                ),
              ),
            ],
          ),
        ),
        if (blockers.isNotEmpty) ...[
          const Gap(Insets.lg),
          _BlockersCard(blockers: blockers),
        ],
        if (!s.declared)
          Padding(
            padding: const EdgeInsets.only(top: Insets.sm),
            child: Text(
              'Tick the declaration to enable submission.',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.danger),
            ),
          ),
      ],
    );
  }
}

/// Advisory counts. A case may legitimately have no structure or crop on
/// site, so those never gate submission.
List<Widget> _countChecks(AsyncValue<(int, int, int, int)> counts) {
  return counts.when(
    loading: () => const [LinearProgressIndicator(minHeight: 2)],
    error: (e, _) => [
        _CheckRow(
          ok: false,
          advisory: true,
          label: 'Captured counts unavailable',
        ),
      ],
    data: (c) => [
        _CheckRow(ok: c.$1 > 0, label: '${c.$1} structures', advisory: true),
        _CheckRow(ok: c.$2 > 0, label: '${c.$2} trees/crops', advisory: true),
        _CheckRow(ok: c.$3 > 0, label: '${c.$3} documents', advisory: true),
        _CheckRow(ok: c.$4 > 0, label: '${c.$4} evidence items'),
      ],
  );
}

class _BlockersCard extends StatelessWidget {
  const _BlockersCard({required this.blockers});

  final List<String> blockers;

  @override
  Widget build(BuildContext context) {
    return AppBanner(
      tone: AppBannerTone.danger,
      title: 'Verification incomplete — ${blockers.length} '
          'item${blockers.length == 1 ? '' : 's'}',
      message: '${blockers.map((b) => '• $b').join('\n')}\n\n'
          'Go back and complete these before submitting — an incomplete record '
          'is rejected at District review.',
      icon: Icons.error_outline,
    );
  }
}

// ------------------------------------------------------------- small parts

class _AddRow extends StatelessWidget {
  const _AddRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add, size: 18),
            label: Text(label),
          ),
        ),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.title,
    required this.subtitle,
    required this.syncLabel,
    this.icon = Icons.architecture_outlined,
    this.accent = AppColors.neutral,
  });

  final String title;
  final String subtitle;
  final String syncLabel;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.md),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: Radii.smAll,
              ),
              child: Icon(icon, size: 18, color: accent),
            ),
            const Gap(Insets.md, horizontal: true),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium!.copyWith(fontSize: 14),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall!.copyWith(fontSize: 12.5),
                    ),
                ],
              ),
            ),
            const Gap(Insets.sm, horizontal: true),
            AppChip(label: syncLabel, color: accent, dense: true),
          ],
        ),
      ),
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({required this.record});

  final Evidence record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final path = record.localFilePath;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            // Was `File(path).existsSync()` on the build path, with no
            // `errorBuilder` — a deleted file rendered the red framework error
            // box.
            child: path.isEmpty
                ? const _EvidenceFallback()
                : Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    cacheWidth: 200,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.low,
                    errorBuilder: (_, _, _) => const _EvidenceFallback(),
                  ),
          ),
          const Gap(Insets.md, horizontal: true),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.description ?? record.type,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium!.copyWith(fontSize: 14),
                ),
                const Gap(Insets.sm),
                AppChip(
                  label: record.syncStatus,
                  color: AppColors.info,
                  dense: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceFallback extends StatelessWidget {
  const _EvidenceFallback();

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: AppColors.neutralSoft,
        child: Center(
          child: Icon(Icons.image_outlined, color: AppColors.textTertiary),
        ),
      );
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.ok, required this.label, this.advisory = false});

  final bool ok;
  final String label;
  final bool advisory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = ok
        ? AppColors.success
        : advisory
            ? AppColors.warning
            : AppColors.danger;

    return ListTile(
      dense: true,
      leading: Icon(
        ok
            ? Icons.check_circle
            : advisory
                ? Icons.remove_circle_outline
                : Icons.error_outline,
        color: color,
        size: 20,
      ),
      title: Text(label, style: theme.textTheme.bodyLarge),
      subtitle: ok || advisory
          ? null
          : Text(
              'Required before submission',
              style: theme.textTheme.bodySmall!.copyWith(fontSize: 11.5, color: color),
            ),
    );
  }
}

Widget _choiceBlock({
  required TextTheme theme,
  required String label,
  required List<String> options,
  required String selected,
  required ValueChanged<String> onSelect,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label.toUpperCase(), style: theme.labelSmall),
      const Gap(Insets.sm),
      Wrap(
        spacing: Insets.sm,
        runSpacing: Insets.sm,
        children: [
          for (final o in options)
            ChoiceChip(
              label: Text(o),
              selected: selected == o,
              onSelected: (_) => onSelect(o),
            ),
        ],
      ),
    ],
  );
}

Widget _binaryBlock({
  required TextTheme theme,
  required String label,
  required bool selected,
  required ValueChanged<bool> onSelect,
  String yesLabel = 'YES',
  String noLabel = 'NO',
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: theme.titleMedium!.copyWith(fontSize: 15)),
      const Gap(Insets.sm),
      Row(
        children: [
          Expanded(
            child: ChoiceChip(
              label: Text(yesLabel),
              selected: selected,
              onSelected: (_) => onSelect(true),
            ),
          ),
          const Gap(Insets.sm, horizontal: true),
          Expanded(
            child: ChoiceChip(
              label: Text(noLabel),
              selected: !selected,
              onSelected: (_) => onSelect(false),
            ),
          ),
        ],
      ),
    ],
  );
}
