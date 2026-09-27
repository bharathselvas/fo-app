import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/database/database.dart';
import '../../core/network/connectivity_service.dart';
import '../../widgets/status_widgets.dart';
import '../auth/auth_providers.dart';
import '../evidence/camera_screen.dart';
import 'field_visit_controller.dart';

/// 7-step field visit wizard with local auto-save.
class FieldVisitWizardScreen extends ConsumerStatefulWidget {
  const FieldVisitWizardScreen({super.key, required this.task});

  final AssignedTask task;

  @override
  ConsumerState<FieldVisitWizardScreen> createState() => _FieldVisitWizardScreenState();
}

class _FieldVisitWizardScreenState extends ConsumerState<FieldVisitWizardScreen> {
  static const _steps = [
    'Location',
    'Land',
    'Structures',
    'Trees / Crops',
    'Documents',
    'Evidence',
    'Review',
  ];

  int _step = 0;
  FieldVisit? _visit;
  bool _init = false;
  bool _submitting = false;

  // Land form
  String _landUse = 'Agricultural';
  String _irrigation = 'Rain-fed';
  bool _boundaryConfirmed = true;
  final _notesCtrl = TextEditingController();

  // GPS
  Position? _position;
  bool _locating = false;
  String? _gpsError;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final controller = ref.read(fieldVisitControllerProvider);
    final visit = await controller.startVisit(task: widget.task, officerId: user.id);
    setState(() {
      _visit = visit;
      _init = true;
      if (visit.landUse != null) _landUse = visit.landUse!;
      if (visit.irrigation != null) _irrigation = visit.irrigation!;
      if (visit.boundaryConfirmed != null) _boundaryConfirmed = visit.boundaryConfirmed!;
      if (visit.notes != null) _notesCtrl.text = visit.notes!;
    });
  }

  Future<void> _autoSave() async {
    final visit = _visit;
    if (visit == null) return;
    await ref.read(fieldVisitControllerProvider).updateVisit(
          visit.id,
          landUse: _landUse,
          irrigation: _irrigation,
          boundaryConfirmed: _boundaryConfirmed,
          notes: _notesCtrl.text,
        );
  }

  Future<void> _captureGps() async {
    setState(() {
      _locating = true;
      _gpsError = null;
    });
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _gpsError = 'GPS permission denied');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() => _position = pos);
      final visit = _visit;
      if (visit != null) {
        await ref.read(fieldVisitControllerProvider).updateVisit(
              visit.id,
              gpsLat: pos.latitude.toStringAsFixed(7),
              gpsLng: pos.longitude.toStringAsFixed(7),
              gpsAccuracy: pos.accuracy.toStringAsFixed(1),
              gpsTimestamp: pos.timestamp.toUtc().toIso8601String(),
            );
      }
    } catch (_) {
      setState(() => _gpsError = 'GPS unavailable.\n\nYou can continue, but evidence will be '
          'marked as location unavailable.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _captureEvidence() async {
    final visit = _visit;
    if (visit == null) return;
    final path = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
    );
    if (path == null) return;
    final bytes = await File(path).readAsBytes();
    await ref.read(fieldVisitControllerProvider).addEvidence(
          visitId: visit.id,
          parcelId: widget.task.parcelId,
          officerId: visit.officerId,
          type: 'photo',
          bytes: bytes,
          description: 'Field evidence',
          latitude: _position?.latitude,
          longitude: _position?.longitude,
          gpsAccuracy: _position?.accuracy,
          locationAvailable: _position != null,
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
          caseId: widget.task.caseId,
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
      if (!mounted) return;
      Navigator.of(context).pop();
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('FIELD VISIT SAVED'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✓ Data stored on device', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(widget.task.caseNo, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Status: WAITING FOR SYNC'),
              const SizedBox(height: 8),
              const Text(
                'Internet connection is not required. The application will upload '
                'automatically when connectivity returns.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('DONE'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_init || _visit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_step + 1} of 7 — ${_steps[_step]}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(value: (_step + 1) / 7, minHeight: 6, backgroundColor: Colors.white24),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ConnectionBanner(pendingCount: 0),
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
                      child: _step < 6
                          ? FilledButton(
                              onPressed: () async {
                                await _autoSave();
                                setState(() => _step++);
                              },
                              child: const Text('Next'),
                            )
                          : FilledButton(
                              onPressed: _submitting ? null : _submit,
                              child: _submitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('SAVE & QUEUE FOR SYNC'),
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
        return _landStep();
      case 2:
        return _structuresStep();
      case 3:
        return _vegetationStep();
      case 4:
        return _documentsStep();
      case 5:
        return _evidenceStep();
      default:
        return _reviewStep();
    }
  }

  Widget _locationStep() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('GPS LOCATION', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _kv('Latitude', _position?.latitude.toStringAsFixed(6) ?? '—'),
                _kv('Longitude', _position?.longitude.toStringAsFixed(6) ?? '—'),
                _kv('Accuracy', _position != null ? '${_position!.accuracy.toStringAsFixed(1)} m' : '—'),
                _kv(
                  'Timestamp',
                  _position != null
                      ? '${_position!.timestamp.toLocal()}'.substring(0, 19)
                      : '—',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _locating ? null : _captureGps,
          icon: _locating
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.my_location),
          label: Text(_locating ? 'Getting GPS…' : 'CAPTURE GPS'),
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
            child: Text(_gpsError!),
          ),
        ],
      ],
    );
  }

  Widget _landStep() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('LAND VERIFICATION', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        const Text('Land Use', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Agricultural', 'Residential', 'Commercial', 'Industrial', 'Barren', 'Other']
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
          children: ['Irrigated', 'Rain-fed', 'Not Applicable']
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
        const Text('Boundary confirmed', style: TextStyle(fontWeight: FontWeight.w600)),
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
          decoration: const InputDecoration(labelText: 'Notes'),
          onChanged: (_) => _autoSave(),
        ),
      ],
    );
  }

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
                  onPressed: () => _addStructureDialog(),
                  child: const Text('Add Structure'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty) const Text('No structures recorded yet.'),
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
              TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Type', hintText: 'Residential House')),
              TextField(controller: areaCtrl, decoration: const InputDecoration(labelText: 'Area (sq.ft)'), keyboardType: TextInputType.number),
              TextField(controller: constCtrl, decoration: const InputDecoration(labelText: 'Construction Type', hintText: 'RCC')),
              TextField(controller: condCtrl, decoration: const InputDecoration(labelText: 'Condition', hintText: 'Good')),
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
                    constructionType: constCtrl.text.trim().isEmpty ? null : constCtrl.text.trim(),
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

  Widget _vegetationStep() {
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
                  onPressed: () => _addVegetationDialog(),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty) const Text('No vegetation recorded yet.'),
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
            TextField(controller: speciesCtrl, decoration: const InputDecoration(labelText: 'Species', hintText: 'Coconut')),
            TextField(controller: countCtrl, decoration: const InputDecoration(labelText: 'Count'), keyboardType: TextInputType.number),
            TextField(controller: cropCtrl, decoration: const InputDecoration(labelText: 'Crop Type')),
            TextField(controller: areaCtrl, decoration: const InputDecoration(labelText: 'Estimated Area (ha)'), keyboardType: TextInputType.number),
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
            const SizedBox(height: 12),
            if (items.isEmpty) const Text('No documents captured yet.'),
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
            if (items.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text('No evidence yet. Capture photos from the field.')),
                ),
              ),
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
                        child: e.localFilePath.isNotEmpty && File(e.localFilePath).existsSync()
                            ? Image.file(File(e.localFilePath), fit: BoxFit.cover)
                            : const Center(child: Icon(Icons.image)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.description ?? e.type,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
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
              label: const Text('+ CAPTURE EVIDENCE'),
            ),
          ],
        );
      },
    );
  }

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
            const Text('REVIEW FIELD VISIT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            Text(widget.task.caseNo, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _check(_position != null, 'Location'),
                  _check(_notesCtrl.text.isNotEmpty || _landUse.isNotEmpty, 'Land verification'),
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
                      offline ? 'Network: 🔴 Offline' : 'Network: 🟢 Online',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      offline
                          ? 'Your field visit will be stored locally and uploaded '
                              'automatically when internet connection returns.'
                          : 'Submission will be queued and synchronized with the backend.',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
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
