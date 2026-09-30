import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_routes.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/enums.dart';
import '../../data/models/evidence_record.dart';
import '../../data/models/land_case.dart';
import '../../services/field_location_service.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../assignments/assigned_task_adapter.dart';
import '../auth/auth_providers.dart';
import '../evidence/camera_screen.dart';
import 'field_visit_controller.dart';
import 'steps/wizard_steps.dart';
import 'verification_result_screen.dart';
import 'wizard_state.dart';

/// Nine-step field verification wizard with local auto-save and offline queueing:
/// Location → Parcel → Land Use → Structures → Cultivation → Occupant →
/// Documents → Evidence → Review & Declaration.
///
/// The shell owns chrome and navigation only. Each step is an isolated
/// `ConsumerWidget` (see `steps/wizard_steps.dart`) and the mutable form lives in
/// [WizardController], so editing a text field no longer rebuilds the app bar,
/// the progress bar, the connection banner or the nav buttons.
class FieldVisitWizardScreen extends ConsumerStatefulWidget {
  const FieldVisitWizardScreen({super.key, required this.caseData});

  final LandCase caseData;

  @override
  ConsumerState<FieldVisitWizardScreen> createState() => _FieldVisitWizardScreenState();
}

class _FieldVisitWizardScreenState extends ConsumerState<FieldVisitWizardScreen> {
  /// Id of the visit being edited. Empty until the visit row is created, which
  /// is why the step queries guard on it.
  String get _visitId => _visit?.id ?? '';
  FieldVisit? _visit;
  Object? _bootstrapError;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  // The per-step queries. Declared once here rather than re-invoked inside each
  // build via `FutureBuilder(future: _structures())` — which re-ran the drift
  // query on every rebuild of the step.
  late final _structuresProvider = FutureProvider<List<Structure>>(
    (_) => _queryStructures(),
  );
  late final _vegetationProvider = FutureProvider<List<Vegetation>>(
    (_) => _queryVegetation(),
  );
  late final _documentsProvider = FutureProvider<List<LocalDocument>>(
    (_) => _queryDocuments(),
  );
  late final _evidenceProvider = FutureProvider<List<Evidence>>(
    (_) => _queryEvidence(),
  );

  late final AppDatabase db = ref.watch(dbProvider);

  Future<List<Structure>> _queryStructures() async {
    if (_visitId.isEmpty) return [];
    final query = db.select(db.structures)
      ..where((t) => t.visitId.equals(_visitId));
    return query.get();
  }

  Future<List<Vegetation>> _queryVegetation() async {
    if (_visitId.isEmpty) return [];
    final query = db.select(db.vegetations)
      ..where((t) => t.visitId.equals(_visitId));
    return query.get();
  }

  Future<List<LocalDocument>> _queryDocuments() async {
    if (_visitId.isEmpty) return [];
    final query = db.select(db.localDocuments)
      ..where((t) => t.visitId.equals(_visitId));
    return query.get();
  }

  Future<List<Evidence>> _queryEvidence() async {
    if (_visitId.isEmpty) return [];
    final query = db.select(db.evidences)
      ..where((t) => t.visitId.equals(_visitId));
    return query.get();
  }

  Future<void> _bootstrap() async {
    try {
      final user = ref.read(currentUserProvider);
      final controller = ref.read(fieldVisitControllerProvider);
      final visit = await controller.startVisit(
        task: assignedTaskFromCase(widget.caseData, officerId: user.id),
        officerId: user.id,
      );
      if (!mounted) return;
      ref.read(wizardControllerProvider.notifier).hydrate(visit);
      setState(() => _visit = visit);
    } catch (e) {
      // Previously uncaught: a drift failure here left the officer staring at a
      // spinner with no way forward.
      if (mounted) setState(() => _bootstrapError = e);
    }
  }

  Future<void> _captureGps() async {
    final ctl = ref.read(wizardControllerProvider.notifier);
    ctl.setLocating(true);
    final loc = await fieldLocationService.acquire(
      nearLat: widget.caseData.latitude,
      nearLng: widget.caseData.longitude,
    );
    if (!mounted) return;
    ctl.setLocation(
      loc,
      notice: loc.isMock
          ? 'No device fix available — a demo position near the parcel was used. '
              'The record is still GPS-tagged.'
          : null,
    );
    await ctl.persist();
    final visit = _visit;
    if (visit == null) return;
    await ref.read(fieldVisitControllerProvider).updateVisit(
          visit.id,
          gpsLat: loc.latitude.toStringAsFixed(7),
          gpsLng: loc.longitude.toStringAsFixed(7),
          gpsAccuracy: loc.accuracy.toStringAsFixed(1),
          gpsTimestamp: loc.timestamp.toUtc().toIso8601String(),
        );
  }

  Future<void> _captureEvidence() async {
    final visit = _visit;
    if (visit == null) return;
    final type = ref.read(wizardControllerProvider).evidenceType;

    final useCamera = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, Insets.sm),
              child: Text('ADD EVIDENCE', style: Theme.of(context).textTheme.labelSmall),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Use camera'),
              subtitle: const Text('Capture a new GPS-tagged photograph'),
              onTap: () => Navigator.of(sheetCtx).pop(true),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Log evidence without camera'),
              subtitle: const Text(
                'Records a GPS-tagged entry with no photo — for emulators and '
                'camera-less devices. Stored and uploaded like any capture.',
              ),
              onTap: () => Navigator.of(sheetCtx).pop(false),
            ),
            const Gap(Insets.sm),
          ],
        ),
      ),
    );
    if (useCamera == null || !mounted) return;

    final recordId = ref.read(foStateProvider.notifier).nextEvidenceId();
    final capturedAt = DateTime.now();
    final location = ref.read(wizardControllerProvider).location;

    /// Writes the same record to both stores: Drift (durable, queued for
    /// upload) and the in-memory dossier the case screens render. Both are
    /// keyed off the same visit, so nothing can drift apart.
    Future<void> persistCapture({
      required String? localPath,
      required bool placeholder,
    }) async {
      await ref.read(fieldVisitControllerProvider).addEvidence(
            visitId: visit.id,
            parcelId: widget.caseData.parcelId,
            officerId: visit.officerId,
            type: type.toLowerCase().replaceAll(' ', '_'),
            bytes: placeholder
                ? base64Decode(kPlaceholderEvidencePng)
                : await File(localPath!).readAsBytes(),
            description: type,
            latitude: location?.latitude,
            longitude: location?.longitude,
            gpsAccuracy: location?.accuracy,
            locationAvailable: location != null,
          );
      ref.read(foStateProvider.notifier).addEvidence(
            EvidenceRecord(
              id: recordId,
              caseNo: widget.caseData.caseNo,
              type: type,
              caption: '$type captured during field verification',
              capturedAt: capturedAt,
              latitude: location?.latitude,
              longitude: location?.longitude,
              accuracyMetres: location?.accuracy,
              gpsTagged: location != null,
              uploadStatus: UploadStatus.pending,
              filePath: localPath,
              officerId: visit.officerId,
            ),
          );
    }

    if (!useCamera) {
      await persistCapture(localPath: null, placeholder: true);
      _invalidateEvidenceQueries();
      _toast('$type logged — GPS ${location == null ? 'not' : ''} tagged');
      return;
    }

    final path = await Navigator.of(context).push<String>(
      AppRoutes.zoom(const CameraCaptureScreen()),
    );
    if (path == null || !mounted) return;
    if (path == kUsePlaceholder) {
      await persistCapture(localPath: null, placeholder: true);
      _invalidateEvidenceQueries();
      _toast('$type logged — camera unavailable, GPS tag kept');
      return;
    }
    await persistCapture(localPath: path, placeholder: false);
    _invalidateEvidenceQueries();
  }

  void _invalidateEvidenceQueries() {
    ref.invalidate(_evidenceProvider);
  }

  Future<void> _pickDocument() async {
    final visit = _visit;
    if (visit == null) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final ext = file.extension ?? 'pdf';
    final mimeType = switch (ext.toLowerCase()) {
      'pdf' => 'application/pdf',
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      _ => 'application/octet-stream',
    };
    await ref.read(fieldVisitControllerProvider).addDocument(
          visitId: visit.id,
          caseId: widget.caseData.caseNo,
          type: 'land_record',
          bytes: bytes,
          filename: file.name,
          mimeType: mimeType,
          extension: ext,
        );
    if (mounted) ref.invalidate(_documentsProvider);
  }

  Future<void> _addStructure() async {
    final result = await showDialog<_StructureDraft>(
      context: context,
      builder: (_) => const _StructureDialog(),
    );
    if (result == null) return;
    await ref.read(fieldVisitControllerProvider).addStructure(
          visitId: _visitId,
          type: result.type,
          areaValue: result.area,
          constructionType: result.construction,
          condition: result.condition,
          notes: result.notes,
        );
    if (mounted) ref.invalidate(_structuresProvider);
  }

  Future<void> _addVegetation() async {
    final result = await showDialog<_VegetationDraft>(
      context: context,
      builder: (_) => const _VegetationDialog(),
    );
    if (result == null) return;
    await ref.read(fieldVisitControllerProvider).addVegetation(
          visitId: _visitId,
          species: result.species,
          count: result.count,
          cropType: result.cropType,
          areaHa: result.areaHa,
        );
    if (mounted) ref.invalidate(_vegetationProvider);
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    final visit = _visit;
    if (visit == null || _submitting) return;
    setState(() => _submitting = true);
    try {
      final state = ref.read(foStateProvider);
      final evidenceCount = state.evidenceFor(widget.caseData.caseNo).length;
      final blockers =
          ref.read(wizardControllerProvider).submitBlockers(evidenceCount);
      if (blockers.isNotEmpty) {
        if (mounted) {
          setState(() => _submitting = false);
          _toast('Incomplete: ${blockers.join(' · ')}');
        }
        return;
      }

      await ref.read(wizardControllerProvider.notifier).persist();
      await ref.read(fieldVisitControllerProvider).submitVisit(visit.id);

      final conn = ref.read(connectionProvider).valueOrNull ?? ConnectionStatus.offline;
      final queuedOffline = conn != ConnectionStatus.online;
      final location = ref.read(wizardControllerProvider).location;

      ref.read(foStateProvider.notifier).submitVerification(
            caseNo: widget.caseData.caseNo,
            evidenceCount: evidenceCount,
            gpsCaptured: location != null,
            queuedOffline: queuedOffline,
          );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        AppRoutes.fadeUp(
          VerificationResultScreen(
            caseNo: widget.caseData.caseNo,
            evidenceCount: evidenceCount,
            gpsCaptured: location != null,
            gpsIsMock: location?.isMock ?? false,
            queuedOffline: queuedOffline,
            visitId: visit.id,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        _toast('Could not submit: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bootstrapError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Field verification')),
        body: EmptyState(
          icon: Icons.error_outline,
          tone: EmptyTone.danger,
          title: 'Could not start the visit',
          message: '$_bootstrapError',
          action: OutlinedButton(
            onPressed: () => setState(() {
              _bootstrapError = null;
              _bootstrap();
            }),
            child: const Text('RETRY'),
          ),
        ),
      );
    }

    if (_visit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Field verification')),
        body: const LoadingState(label: 'Preparing field visit…'),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 34 + 4),
        child: _WizardHeader(
          subtitle: widget.caseData.caseNo,
          child: _ProgressBar(step: ref.watch(wizardControllerProvider).step),
        ),
      ),
      // Keyed on the step so each step keeps its own scroll position, and so the
      // incoming step's ListView starts fresh rather than inheriting the
      // previous step's offset.
      body: KeyedSubtree(
        key: ValueKey(ref.watch(wizardControllerProvider).step),
        child: _buildStep(),
      ),
      bottomNavigationBar: _WizardNavBar(
        submitting: _submitting,
        onSubmit: _submit,
      ),
    );
  }

  Widget _buildStep() {
    final step = ref.watch(wizardControllerProvider).step;
    final counts = _visit == null
        ? null
        : combineCounts(
            ref.watch(_structuresProvider),
            ref.watch(_vegetationProvider),
            ref.watch(_documentsProvider),
            ref.watch(_evidenceProvider),
          );

    // Blockers must agree with the check rows directly above them, so both read
    // the durable Drift set the officer just wrote to. The previous build
    // derived the blockers from the in-memory dossier while the check rows read
    // Drift, which meant the two could contradict each other on screen.
    final evidenceCount = counts?.valueOrNull?.$4 ??
        ref.read(foStateProvider).evidenceFor(widget.caseData.caseNo).length;

    return switch (step) {
      0 => LocationStep(onCaptureGps: _captureGps),
      1 => ParcelStep(caseData: widget.caseData),
      2 => const LandUseStep(),
      3 => StructuresStep(
          structures: ref.watch(_structuresProvider),
          onAdd: _addStructure,
        ),
      4 => CultivationStep(
          vegetation: ref.watch(_vegetationProvider),
          onAdd: _addVegetation,
        ),
      5 => OccupantStep(defaultOccupantName: widget.caseData.landOwner.name),
      6 => DocumentsStep(
          documents: ref.watch(_documentsProvider),
          onAdd: _pickDocument,
        ),
      7 => EvidenceStep(
          evidence: ref.watch(_evidenceProvider),
          onCapture: _captureEvidence,
        ),
      _ => ReviewStep(
          caseNo: widget.caseData.caseNo,
          locationSummary: _locationSummary,
          counts: counts,
          blockers:
              ref.watch(wizardControllerProvider).submitBlockers(evidenceCount),
          offline:
              (ref.watch(connectionProvider).valueOrNull ?? ConnectionStatus.offline) !=
                  ConnectionStatus.online,
        ),
    };
  }

  String get _locationSummary {
    final loc = ref.read(wizardControllerProvider).location;
    if (loc == null) return 'Not captured';
    return '${loc.latitude.toStringAsFixed(5)}, '
        '${loc.longitude.toStringAsFixed(5)} · ${loc.accuracyLabel}';
  }
}

class _WizardHeader extends ConsumerWidget implements PreferredSizeWidget {
  const _WizardHeader({required this.subtitle, required this.child});

  final String subtitle;
  final Widget child;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 34 + 4);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(wizardControllerProvider);
    final theme = Theme.of(context);
    final stepCount = WizardController.steps.length;

    return Material(
      color: AppColors.brand,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: kToolbarHeight,
              child: IconTheme.merge(
                data: const IconThemeData(color: AppColors.textOnBrand, size: 22),
                child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step ${s.step + 1} of $stepCount — ${WizardController.steps[s.step]}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium!
                              .copyWith(color: AppColors.textOnBrand),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall!.copyWith(
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Insets.lg),
                ],
              ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final stepCount = WizardController.steps.length;
    return SizedBox(
      height: 4,
      child: LinearProgressIndicator(
        value: (step + 1) / stepCount,
        minHeight: 4,
        backgroundColor: Colors.white24,
        valueColor: const AlwaysStoppedAnimation(Colors.white),
      ),
    );
  }
}

/// The persistent Back / Next bar.
///
/// Split into its own widget so a keystroke in a step's text field rebuilds
/// only this small subtree, never the whole scaffold.
class _WizardNavBar extends ConsumerWidget {
  const _WizardNavBar({
    required this.submitting,
    required this.onSubmit,
  });

  final bool submitting;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepCount = WizardController.steps.length;
    final s = ref.watch(wizardControllerProvider);
    final ctl = ref.read(wizardControllerProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.md),
          child: Row(
            children: [
              if (s.step > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await ctl.persist();
                      ctl.goBack();
                    },
                    child: const Text('Back'),
                  ),
                ),
                const Gap(Insets.sm, horizontal: true),
              ],
              Expanded(
                flex: 2,
                child: s.step < stepCount - 1
                    ? FilledButton(
                        onPressed: () async {
                          final blocker = s.blockerFor(s.step);
                          if (blocker != null) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(content: Text(blocker)));
                            return;
                          }
                          await ctl.persist();
                          ctl.goNext();
                        },
                        child: const Text('Next'),
                      )
                    : FilledButton.icon(
                        onPressed: submitting || !s.declared ? null : onSubmit,
                        icon: submitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.cloud_upload_outlined, size: 18),
                        label: Text(submitting ? 'SUBMITTING…' : 'SUBMIT VERIFICATION'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ add dialogs

class _StructureDraft {
  const _StructureDraft({
    required this.type,
    required this.area,
    required this.construction,
    required this.condition,
    required this.notes,
  });

  final String type;
  final double? area;
  final String? construction;
  final String? condition;
  final String? notes;
}

class _VegetationDraft {
  const _VegetationDraft({
    required this.species,
    required this.count,
    required this.cropType,
    required this.areaHa,
  });

  final String species;
  final int count;
  final String? cropType;
  final double? areaHa;
}

class _StructureDialog extends StatefulWidget {
  const _StructureDialog();

  @override
  State<_StructureDialog> createState() => _StructureDialogState();
}

class _StructureDialogState extends State<_StructureDialog> {
  final _type = TextEditingController();
  final _area = TextEditingController();
  final _construction = TextEditingController();
  final _condition = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    for (final c in [_type, _area, _construction, _condition, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Structure'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _type,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Type *',
                hintText: 'Residential House',
              ),
            ),
            const Gap(Insets.sm),
            TextField(
              controller: _area,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Area (sq.ft)'),
            ),
            const Gap(Insets.sm),
            TextField(
              controller: _construction,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Construction Type',
                hintText: 'RCC',
              ),
            ),
            const Gap(Insets.sm),
            TextField(
              controller: _condition,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Condition',
                hintText: 'Good',
              ),
            ),
            const Gap(Insets.sm),
            TextField(
              controller: _notes,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_type.text.trim().isEmpty) return;
            String? orNull(String v) => v.trim().isEmpty ? null : v.trim();
            Navigator.pop(
              context,
              _StructureDraft(
                type: _type.text.trim(),
                area: double.tryParse(_area.text),
                construction: orNull(_construction.text),
                condition: orNull(_condition.text),
                notes: orNull(_notes.text),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _VegetationDialog extends StatefulWidget {
  const _VegetationDialog();

  @override
  State<_VegetationDialog> createState() => _VegetationDialogState();
}

class _VegetationDialogState extends State<_VegetationDialog> {
  final _species = TextEditingController();
  final _count = TextEditingController(text: '1');
  final _crop = TextEditingController();
  final _area = TextEditingController();

  @override
  void dispose() {
    for (final c in [_species, _count, _crop, _area]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Trees / Crops'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _species,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Species *',
                hintText: 'Coconut',
              ),
            ),
            const Gap(Insets.sm),
            TextField(
              controller: _count,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Count'),
            ),
            const Gap(Insets.sm),
            TextField(
              controller: _crop,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Crop Type'),
            ),
            const Gap(Insets.sm),
            TextField(
              controller: _area,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Estimated Area (ha)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_species.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              _VegetationDraft(
                species: _species.text.trim(),
                count: int.tryParse(_count.text) ?? 1,
                cropType: _crop.text.trim().isEmpty ? null : _crop.text.trim(),
                areaHa: double.tryParse(_area.text),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
