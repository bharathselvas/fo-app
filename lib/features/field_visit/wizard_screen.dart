import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';
import '../../core/network/connectivity_service.dart';
import '../../data/models/enums.dart';
import '../../data/models/evidence_record.dart';
import '../../data/models/land_case.dart';
import '../../services/field_location_service.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/status_widgets.dart';
import '../assignments/assigned_task_adapter.dart';
import '../auth/auth_providers.dart';
import '../evidence/camera_screen.dart';
import 'field_visit_controller.dart';
import 'verification_result_screen.dart';

/// 9-step field verification wizard with local auto-save and offline queueing:
/// Location → Parcel → Land Use → Structures → Cultivation → Occupant →
/// Documents → Evidence → Review & Declaration.
class FieldVisitWizardScreen extends ConsumerStatefulWidget {
  const FieldVisitWizardScreen({super.key, required this.caseData});

  final LandCase caseData;

  @override
  ConsumerState<FieldVisitWizardScreen> createState() => _FieldVisitWizardScreenState();
}

class _FieldVisitWizardScreenState extends ConsumerState<FieldVisitWizardScreen> {
  static const _steps = [
    'Location',
    'Parcel',
    'Land Use',
    'Structures',
    'Cultivation',
    'Occupant',
    'Documents',
    'Evidence',
    'Review',
  ];

  int _step = 0;
  FieldVisit? _visit;
  bool _init = false;
  bool _submitting = false;

  // Land-use form
  String _landUse = kLandUses.first;
  String _irrigation = 'Rain-fed';
  bool _boundaryConfirmed = true;
  final _notesCtrl = TextEditingController();

  // Occupant / observations (folded into visit notes on save)
  bool _occupantPresent = true;
  late final TextEditingController _occupantNameCtrl =
      TextEditingController(text: widget.caseData.landOwner.name);
  final _observationsCtrl = TextEditingController();

  // GPS
  FieldLocation? _location;
  bool _locating = false;
  String? _gpsError;

  // Evidence type for the next capture
  String _evidenceType = kEvidenceTypes.first;

  // Declaration
  bool _declared = false;

  AssignedTask get _task =>
      assignedTaskFromCase(widget.caseData, officerId: ref.read(currentUserProvider).id);

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _occupantNameCtrl.dispose();
    _observationsCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final user = ref.read(currentUserProvider);
    final controller = ref.read(fieldVisitControllerProvider);
    final visit = await controller.startVisit(task: _task, officerId: user.id);
    if (!mounted) return;
    setState(() {
      _visit = visit;
      _init = true;
      if (visit.landUse != null && kLandUses.contains(visit.landUse)) {
        _landUse = visit.landUse!;
      }
      if (visit.irrigation != null) _irrigation = visit.irrigation!;
      if (visit.boundaryConfirmed != null) _boundaryConfirmed = visit.boundaryConfirmed!;
      if (visit.notes != null) _notesCtrl.text = _stripOccupantBlock(visit.notes!);
    });
  }

  /// Removes the occupant/observation block previously folded into the notes
  /// so an edited visit never accumulates duplicate lines.
  String _stripOccupantBlock(String notes) => notes
      .split('\n')
      .where((l) =>
          !l.startsWith('Occupant present:') &&
          !l.startsWith('Occupant:') &&
          !l.startsWith('Observations:'))
      .join('\n')
      .trimRight();

  String _combinedNotes() {
    final lines = <String>[
      if (_notesCtrl.text.trim().isNotEmpty) _notesCtrl.text.trim(),
      'Occupant present: ${_occupantPresent ? 'Yes' : 'No'}',
      if (_occupantNameCtrl.text.trim().isNotEmpty)
        'Occupant: ${_occupantNameCtrl.text.trim()}',
      if (_observationsCtrl.text.trim().isNotEmpty)
        'Observations: ${_observationsCtrl.text.trim()}',
    ];
    return lines.join('\n');
  }

  Future<void> _autoSave() async {
    final visit = _visit;
    if (visit == null) return;
    await ref.read(fieldVisitControllerProvider).updateVisit(
          visit.id,
          landUse: _landUse,
          irrigation: _irrigation,
          boundaryConfirmed: _boundaryConfirmed,
          notes: _combinedNotes(),
        );
  }

  Future<void> _captureGps() async {
    setState(() {
      _locating = true;
      _gpsError = null;
    });
    final loc = await fieldLocationService.acquire(
      nearLat: widget.caseData.latitude,
      nearLng: widget.caseData.longitude,
    );
    if (!mounted) return;
    setState(() {
      _location = loc;
      _locating = false;
      _gpsError = loc.isMock
          ? 'No device fix available — a demo position near the parcel was used. '
              'The record is still GPS-tagged.'
          : null;
    });
    final visit = _visit;
    if (visit != null) {
      await ref.read(fieldVisitControllerProvider).updateVisit(
            visit.id,
            gpsLat: loc.latitude.toStringAsFixed(7),
            gpsLng: loc.longitude.toStringAsFixed(7),
            gpsAccuracy: loc.accuracy.toStringAsFixed(1),
            gpsTimestamp: loc.timestamp.toUtc().toIso8601String(),
          );
    }
  }

  Future<void> _captureEvidence() async {
    final visit = _visit;
    if (visit == null) return;
    final path = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
    );
    if (path == null || !mounted) return;
    final bytes = await File(path).readAsBytes();
    await ref.read(fieldVisitControllerProvider).addEvidence(
          visitId: visit.id,
          parcelId: widget.caseData.parcelId,
          officerId: visit.officerId,
          type: _evidenceType.toLowerCase().replaceAll(' ', '_'),
          bytes: bytes,
          description: _evidenceType,
          latitude: _location?.latitude,
          longitude: _location?.longitude,
          gpsAccuracy: _location?.accuracy,
          locationAvailable: _location != null,
        );
    // Mirror into the case dossier so the case detail screen shows it too.
    final state = ref.read(foStateProvider);
    ref.read(foStateProvider.notifier).addEvidence(
          EvidenceRecord(
            id: 'EV-${(state.evidence.length + 1).toString().padLeft(3, '0')}',
            caseNo: widget.caseData.caseNo,
            type: _evidenceType,
            caption: '$_evidenceType captured during field verification',
            capturedAt: DateTime.now(),
            latitude: _location?.latitude,
            longitude: _location?.longitude,
            accuracyMetres: _location?.accuracy,
            gpsTagged: _location != null,
            uploadStatus: UploadStatus.pending,
            filePath: path,
            officerId: visit.officerId,
          ),
        );
    setState(() {});
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
    setState(() {});
  }

  Future<List<Structure>> _structures() async {
    final visit = _visit;
    if (visit == null) return [];
    final db = ref.read(dbProvider);
    return (db.select(db.structures)..where((t) => t.visitId.equals(visit.id))).get();
  }

  Future<List<Vegetation>> _vegetation() async {
    final visit = _visit;
    if (visit == null) return [];
    final db = ref.read(dbProvider);
    return (db.select(db.vegetations)..where((t) => t.visitId.equals(visit.id))).get();
  }

  Future<List<LocalDocument>> _documents() async {
    final visit = _visit;
    if (visit == null) return [];
    final db = ref.read(dbProvider);
    return (db.select(db.localDocuments)..where((t) => t.visitId.equals(visit.id))).get();
  }

  Future<List<Evidence>> _evidence() async {
    final visit = _visit;
    if (visit == null) return [];
    final db = ref.read(dbProvider);
    return (db.select(db.evidences)..where((t) => t.visitId.equals(visit.id))).get();
  }

  Future<void> _submit() async {
    final visit = _visit;
    if (visit == null || _submitting) return;
    setState(() => _submitting = true);
    try {
      await _autoSave();
      await ref.read(fieldVisitControllerProvider).submitVisit(visit.id);

      final conn = ref.read(connectionProvider).valueOrNull ?? ConnectionStatus.offline;
      final queuedOffline = conn != ConnectionStatus.online;
      final state = ref.read(foStateProvider);
      final evidenceCount = state.evidenceFor(widget.caseData.caseNo).length;

      ref.read(foStateProvider.notifier).submitVerification(
            caseNo: widget.caseData.caseNo,
            evidenceCount: evidenceCount,
            gpsCaptured: _location != null,
            queuedOffline: queuedOffline,
          );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => VerificationResultScreen(
            caseNo: widget.caseData.caseNo,
            evidenceCount: evidenceCount,
            gpsCaptured: _location != null,
            gpsIsMock: _location?.isMock ?? false,
            queuedOffline: queuedOffline,
            visitId: visit.id,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_init || _visit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pending = ref.watch(pendingSyncCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_step + 1} of 9 — ${_steps[_step]}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (_step + 1) / 9,
            minHeight: 6,
            backgroundColor: Colors.white24,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ConnectionBanner(pendingCount: pending),
            Expanded(child: _buildStep()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await _autoSave();
                            setState(() => _step--);
                          },
                          child: const Text('Back'),
                        ),
                      ),
                    if (_step > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _step < 8
                          ? FilledButton(
                              onPressed: () async {
                                await _autoSave();
                                setState(() => _step++);
                              },
                              child: const Text('Next'),
                            )
                          : FilledButton(
                              onPressed: _submitting || !_declared ? null : _submit,
                              child: _submitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('SUBMIT VERIFICATION'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _locationStep();
      case 1:
        return _parcelStep();
      case 2:
        return _landUseStep();
      case 3:
        return _structuresStep();
      case 4:
        return _cultivationStep();
      case 5:
        return _occupantStep();
      case 6:
        return _documentsStep();
      case 7:
        return _evidenceStep();
      default:
        return _reviewStep();
    }
  }

  // ---------------------------------------------------------------- Location

  Widget _locationStep() {
    final loc = _location;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('GPS LOCATION',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(
          'Capture your position at the parcel before recording observations.',
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _kv('Latitude', loc?.latitude.toStringAsFixed(6) ?? '—'),
                _kv('Longitude', loc?.longitude.toStringAsFixed(6) ?? '—'),
                _kv('Accuracy', loc != null ? loc.accuracyLabel : '—'),
                _kv(
                  'Timestamp',
                  loc == null
                      ? '—'
                      : DateFormat('d MMM yyyy, h:mm a').format(loc.timestamp),
                ),
                _kv(
                  'Source',
                  loc == null
                      ? '—'
                      : loc.isMock
                          ? 'DEMO FIX (near parcel)'
                          : 'DEVICE GPS',
                ),
              ],
            ),
          ),
        ),
        if (loc != null) ...[
          const SizedBox(height: 12),
          StatusChip(
            label: loc.isMock ? 'GPS TAGGED (DEMO)' : 'GPS LOCKED',
            color: loc.isMock ? Colors.amber.shade800 : const Color(0xFF2E7D32),
            icon: Icons.my_location,
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _locating ? null : _captureGps,
          icon: _locating
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.my_location),
          label: Text(_locating ? 'Getting GPS…' : loc == null ? 'CAPTURE GPS' : 'RE-CAPTURE GPS'),
        ),
        if (_gpsError != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Text(_gpsError!, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ],
    );
  }

  // ------------------------------------------------------------------ Parcel

  Widget _parcelStep() {
    final c = widget.caseData;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('PARCEL UNDER VERIFICATION',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(
          'Read-only from the case file. Confirm you are at the right parcel before proceeding.',
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'PARCEL DETAILS',
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
        const SizedBox(height: 16),
        SectionCard(
          title: 'LANDOWNER ON RECORD',
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

  // ---------------------------------------------------------------- Land use

  Widget _landUseStep() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('LAND USE VERIFICATION', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        const Text('Land Use', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kLandUses
              .map((v) => ChoiceChip(
                    label: Text(v),
                    selected: _landUse == v,
                    onSelected: (_) {
                      setState(() => _landUse = v);
                      _autoSave();
                    },
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        const Text('Irrigation', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: kIrrigationTypes
              .map((v) => ChoiceChip(
                    label: Text(v),
                    selected: _irrigation == v,
                    onSelected: (_) {
                      setState(() => _irrigation = v);
                      _autoSave();
                    },
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        const Text('Boundary confirmed on ground',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('YES'),
                selected: _boundaryConfirmed,
                onSelected: (_) {
                  setState(() => _boundaryConfirmed = true);
                  _autoSave();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('NO'),
                selected: !_boundaryConfirmed,
                onSelected: (_) {
                  setState(() => _boundaryConfirmed = false);
                  _autoSave();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesCtrl,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Land-use notes',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _autoSave(),
        ),
      ],
    );
  }

  // -------------------------------------------------------------- Structures

  Widget _structuresStep() {
    return FutureBuilder<List<Structure>>(
      future: _structures(),
      builder: (context, snap) {
        final items = snap.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Text('STRUCTURES', style: TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: _addStructureDialog,
                  child: const Text('Add Structure'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const EmptyState(
                icon: Icons.home_work_outlined,
                title: 'No Structures Recorded',
                message: 'Add every building, wall or fixture found on the parcel.',
              ),
            ...items.map((s) => Card(
                  child: ListTile(
                    title: Text(s.type, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text([
                      if (s.areaValue != null) '${s.areaValue} ${s.areaUnit}',
                      if (s.constructionType != null) s.constructionType!,
                      if (s.condition != null) s.condition!,
                      if (s.notes != null && s.notes!.isNotEmpty) s.notes!,
                    ].join(' · ')),
                    trailing: StatusChip(label: s.syncStatus, color: Colors.blueGrey),
                  ),
                )),
          ],
        );
      },
    );
  }

  Future<void> _addStructureDialog() async {
    final typeCtrl = TextEditingController();
    final areaCtrl = TextEditingController();
    final constCtrl = TextEditingController();
    final condCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Structure'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: typeCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Type', hintText: 'Residential House')),
              TextField(
                  controller: areaCtrl,
                  decoration: const InputDecoration(labelText: 'Area (sq.ft)'),
                  keyboardType: TextInputType.number),
              TextField(
                  controller: constCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Construction Type', hintText: 'RCC')),
              TextField(
                  controller: condCtrl,
                  decoration: const InputDecoration(labelText: 'Condition', hintText: 'Good')),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final visit = _visit;
              if (visit == null || typeCtrl.text.trim().isEmpty) return;
              await ref.read(fieldVisitControllerProvider).addStructure(
                    visitId: visit.id,
                    type: typeCtrl.text.trim(),
                    areaValue: double.tryParse(areaCtrl.text),
                    constructionType:
                        constCtrl.text.trim().isEmpty ? null : constCtrl.text.trim(),
                    condition: condCtrl.text.trim().isEmpty ? null : condCtrl.text.trim(),
                    notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- Cultivation

  Widget _cultivationStep() {
    return FutureBuilder<List<Vegetation>>(
      future: _vegetation(),
      builder: (context, snap) {
        final items = snap.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Text('TREES / CROPS', style: TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: _addVegetationDialog,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const EmptyState(
                icon: Icons.grass,
                title: 'No Cultivation Recorded',
                message: 'Record standing crops, trees and their extent on the parcel.',
              ),
            ...items.map((v) => Card(
                  child: ListTile(
                    title: Text('${v.species} × ${v.count}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text([
                      if (v.cropType != null) v.cropType!,
                      if (v.areaHa != null) '${v.areaHa} ha',
                      if (v.notes != null && v.notes!.isNotEmpty) v.notes!,
                    ].join(' · ')),
                    trailing: StatusChip(label: v.syncStatus, color: Colors.green),
                  ),
                )),
          ],
        );
      },
    );
  }

  Future<void> _addVegetationDialog() async {
    final speciesCtrl = TextEditingController();
    final countCtrl = TextEditingController(text: '1');
    final cropCtrl = TextEditingController();
    final areaCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Trees / Crops'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: speciesCtrl,
                decoration: const InputDecoration(labelText: 'Species', hintText: 'Coconut')),
            TextField(
                controller: countCtrl,
                decoration: const InputDecoration(labelText: 'Count'),
                keyboardType: TextInputType.number),
            TextField(controller: cropCtrl, decoration: const InputDecoration(labelText: 'Crop Type')),
            TextField(
                controller: areaCtrl,
                decoration: const InputDecoration(labelText: 'Estimated Area (ha)'),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final visit = _visit;
              if (visit == null || speciesCtrl.text.trim().isEmpty) return;
              await ref.read(fieldVisitControllerProvider).addVegetation(
                    visitId: visit.id,
                    species: speciesCtrl.text.trim(),
                    count: int.tryParse(countCtrl.text) ?? 1,
                    cropType: cropCtrl.text.trim().isEmpty ? null : cropCtrl.text.trim(),
                    areaHa: double.tryParse(areaCtrl.text),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- Occupant

  Widget _occupantStep() {
    final owner = widget.caseData.landOwner;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('OCCUPANT & OBSERVATIONS',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 12),
        SectionCard(
          title: 'PERSON ON RECORD',
          icon: Icons.badge_outlined,
          children: [
            InfoRow(label: 'Landowner', value: owner.name, highlight: true),
            InfoRow(label: 'Ownership type', value: owner.ownershipType),
            InfoRow(label: 'Contact status', value: owner.contactStatus),
            InfoRow(label: 'Verification status', value: owner.verificationStatus),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Is the occupant present at the site?',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('PRESENT'),
                selected: _occupantPresent,
                onSelected: (_) {
                  setState(() => _occupantPresent = true);
                  _autoSave();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('ABSENT'),
                selected: !_occupantPresent,
                onSelected: (_) {
                  setState(() => _occupantPresent = false);
                  _autoSave();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _occupantNameCtrl,
          decoration: const InputDecoration(
            labelText: 'Occupant / representative name',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _autoSave(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _observationsCtrl,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Field observations',
            hintText: 'Discrepancies in extent, encroachment, crop condition, disputes…',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _autoSave(),
        ),
      ],
    );
  }

  // --------------------------------------------------------------- Documents

  Widget _documentsStep() {
    return FutureBuilder<List<LocalDocument>>(
      future: _documents(),
      builder: (context, snap) {
        final items = snap.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Text('DOCUMENTS', style: TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                FilledButton.tonal(onPressed: _pickDocument, child: const Text('Add File')),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Attach field-collected records (Pattta, EC, 7/12 extract, photos of papers).',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const EmptyState(
                icon: Icons.folder_open,
                title: 'No Documents Captured',
                message: 'No field documents captured yet. Tap "Add File" to attach one.',
              ),
            ...items.map((d) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(d.type.replaceAll('_', ' ').toUpperCase()),
                    subtitle: Text(d.localFilePath.split('/').last),
                    trailing: StatusChip(label: d.syncStatus, color: Colors.brown),
                  ),
                )),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------- Evidence

  Widget _evidenceStep() {
    return FutureBuilder<List<Evidence>>(
      future: _evidence(),
      builder: (context, snap) {
        final items = snap.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('FIELD EVIDENCE', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const Text('Evidence type', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kEvidenceTypes
                  .map((t) => ChoiceChip(
                        label: Text(t),
                        selected: _evidenceType == t,
                        onSelected: (_) => setState(() => _evidenceType = t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const EmptyState(
                icon: Icons.photo_camera_outlined,
                title: 'No Evidence Yet',
                message: 'Capture photographs of the boundary, land use, structures and '
                    'survey stones from the field.',
              )
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: items.map((e) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: e.localFilePath.isNotEmpty &&
                                  File(e.localFilePath).existsSync()
                              ? Image.file(File(e.localFilePath), fit: BoxFit.cover)
                              : const Center(child: Icon(Icons.image)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.description ?? e.type,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              StatusChip(label: e.syncStatus, color: Colors.teal),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _captureEvidence,
              icon: const Icon(Icons.camera_alt),
              label: Text('+ CAPTURE ($_evidenceType)'),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------------ Review

  Widget _reviewStep() {
    return FutureBuilder<List<Object>>(
      future: () async {
        final s = await _structures();
        final v = await _vegetation();
        final d = await _documents();
        final e = await _evidence();
        return [s.length, v.length, d.length, e.length];
      }(),
      builder: (context, snap) {
        final counts = snap.data ?? [0, 0, 0, 0];
        final conn = ref.watch(connectionProvider).valueOrNull ?? ConnectionStatus.offline;
        final offline = conn != ConnectionStatus.online;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('REVIEW & DECLARATION',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            Text(widget.caseData.caseNo,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(
              '${widget.caseData.village}, ${widget.caseData.taluk} · '
              'Survey ${widget.caseData.surveyNo}',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _check(_location != null, 'GPS location captured'),
                  _check(_landUse.isNotEmpty, 'Land use verified ($_landUse)'),
                  _check(_notesCtrl.text.trim().isNotEmpty || _observationsCtrl.text.trim().isNotEmpty,
                      'Observations recorded'),
                  _check((counts[0] as int) > 0, '${counts[0]} structures'),
                  _check((counts[1] as int) > 0, '${counts[1]} trees/crops'),
                  _check((counts[2] as int) > 0, '${counts[2]} documents'),
                  _check((counts[3] as int) > 0, '${counts[3]} evidence items'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: offline ? Colors.red.shade50 : Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offline ? 'Network: OFFLINE' : 'Network: ONLINE',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      offline
                          ? 'Your verification will be stored on the device and uploaded '
                              'automatically when connectivity returns.'
                          : 'Submission will be queued and synchronized with the backend.',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _declared,
              onChanged: (v) => setState(() => _declared = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'I declare that the observations recorded above are true to the best '
                'of my knowledge, based on physical verification at the site.',
                style: TextStyle(fontSize: 13.5, height: 1.4),
              ),
            ),
            if (!_declared)
              Text(
                'Tick the declaration to enable submission.',
                style: TextStyle(fontSize: 12.5, color: Colors.red.shade700),
              ),
          ],
        );
      },
    );
  }

  Widget _check(bool ok, String label) {
    return ListTile(
      dense: true,
      leading: Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
          color: ok ? Colors.green : Colors.grey),
      title: Text(label),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: TextStyle(color: Colors.grey[700])),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
