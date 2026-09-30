import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../data/models/enums.dart';
import '../../services/field_location_service.dart';
import 'field_visit_controller.dart';

/// Form state for one field-visit wizard session.
///
/// This exists because the wizard was a single 1300-line `StatefulWidget` with
/// 24 `setState` calls. Typing one character into the mandatory observations
/// field ran `setState(() {})` on the parent, which rebuilt the whole
/// `Scaffold` — app bar, step progress bar, connection banner and both nav
/// buttons — on every keystroke.
///
/// Splitting the mutable form out means only the step widget that reads a given
/// field is invalidated when that field changes.

/// Const-friendly stand-ins for the first entries of the shared constant lists,
/// so [WizardState] can keep its const constructor.
const String defaultLandUse = 'Agricultural';
const String defaultEvidenceType = 'Boundary Photograph';

@immutable
class WizardState {
  const WizardState({
    this.step = 0,
    this.landUse = defaultLandUse,
    this.irrigation = 'Rain-fed',
    this.boundaryConfirmed = true,
    this.occupantPresent = true,
    this.observations = '',
    this.occupantName = '',
    this.notes = '',
    this.evidenceType = defaultEvidenceType,
    this.declared = false,
    this.location,
    this.locating = false,
    this.gpsNotice,
  });

  final int step;

  final String landUse;
  final String irrigation;
  final bool boundaryConfirmed;
  final bool occupantPresent;

  /// Trimmed comparison is what the blockers test, so store the raw text and
  /// expose [hasObservations].
  final String observations;
  final String occupantName;
  final String notes;
  final String evidenceType;
  final bool declared;

  final FieldLocation? location;
  final bool locating;
  final String? gpsNotice;

  bool get hasObservations => observations.trim().isNotEmpty;
  bool get hasLocation => location != null;

  WizardState copyWith({
    int? step,
    String? landUse,
    String? irrigation,
    bool? boundaryConfirmed,
    bool? occupantPresent,
    String? observations,
    String? occupantName,
    String? notes,
    String? evidenceType,
    bool? declared,
    FieldLocation? location,
    bool? locating,
    String? gpsNotice,
    bool clearGpsNotice = false,
  }) =>
      WizardState(
        step: step ?? this.step,
        landUse: landUse ?? this.landUse,
        irrigation: irrigation ?? this.irrigation,
        boundaryConfirmed: boundaryConfirmed ?? this.boundaryConfirmed,
        occupantPresent: occupantPresent ?? this.occupantPresent,
        observations: observations ?? this.observations,
        occupantName: occupantName ?? this.occupantName,
        notes: notes ?? this.notes,
        evidenceType: evidenceType ?? this.evidenceType,
        declared: declared ?? this.declared,
        location: location ?? this.location,
        locating: locating ?? this.locating,
        gpsNotice: clearGpsNotice ? null : (gpsNotice ?? this.gpsNotice),
      );

  /// Blocking requirement for [step], or null when the step may be left.
  ///
  /// Keeps the officer from submitting a record the District Authority would
  /// reject: a field verification without a fix, observations, or any evidence
  /// is not a verification.
  String? blockerFor(int step) => switch (step) {
        0 => hasLocation
            ? null
            : 'Capture GPS before leaving the Location step. Every field record '
                'must carry a position fix.',
        5 => hasObservations ? null : 'Record at least one field observation before continuing.',
        _ => null,
      };

  /// Requirements that must hold at submission time.
  List<String> submitBlockers(int evidenceCount) => [
        if (!hasLocation) 'GPS location not captured',
        if (!hasObservations) 'No field observations recorded',
        if (!boundaryConfirmed) 'Parcel boundary not confirmed',
        if (evidenceCount == 0) 'No evidence captured — add at least one item',
      ];

  /// Notes as persisted: the free-text note plus the occupant block, folded into
  /// one column. Stripped back apart on load so edits never duplicate lines.
  String get persistedNotes {
    final lines = <String>[
      if (notes.trim().isNotEmpty) notes.trim(),
      'Occupant present: ${occupantPresent ? 'Yes' : 'No'}',
      if (occupantName.trim().isNotEmpty) 'Occupant: ${occupantName.trim()}',
      if (observations.trim().isNotEmpty) 'Observations: ${observations.trim()}',
    ];
    return lines.join('\n');
  }

  static String stripOccupantBlock(String raw) => raw
      .split('\n')
      .where((l) =>
          !l.startsWith('Occupant present:') &&
          !l.startsWith('Occupant:') &&
          !l.startsWith('Observations:'))
      .join('\n')
      .trimRight();
}

class WizardController extends StateNotifier<WizardState> {
  WizardController(this._visitController) : super(const WizardState());

  final FieldVisitController _visitController;

  static const List<String> steps = [
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

  int get stepCount => steps.length;

  String get stepTitle => steps[state.step];

  void setStep(int step) => state = state.copyWith(step: step);

  void goNext() => setStep(state.step + 1);

  void goBack() => setStep(state.step - 1);

  void setLandUse(String v) {
    state = state.copyWith(landUse: v);
    _autoSave();
  }

  void setIrrigation(String v) {
    state = state.copyWith(irrigation: v);
    _autoSave();
  }

  void setBoundaryConfirmed(bool v) {
    state = state.copyWith(boundaryConfirmed: v);
    _autoSave();
  }

  void setOccupantPresent(bool v) {
    state = state.copyWith(occupantPresent: v);
    _autoSave();
  }

  void setNotes(String v) {
    state = state.copyWith(notes: v);
    _autoSave();
  }

  /// The hot path. Called on every keystroke of the observations field; it must
  /// not touch the database.
  void setObservations(String v) => state = state.copyWith(observations: v);

  void setOccupantName(String v) {
    state = state.copyWith(occupantName: v);
    _autoSave();
  }

  void setEvidenceType(String v) => state = state.copyWith(evidenceType: v);

  void setDeclared(bool v) => state = state.copyWith(declared: v);

  void setLocating(bool v) => state = state.copyWith(locating: v);

  void setLocation(FieldLocation loc, {String? notice}) => state =
      state.copyWith(location: loc, locating: false, gpsNotice: notice);

  /// Seeds the form from a resumed visit.
  void hydrate(FieldVisit visit) {
    state = state.copyWith(
      landUse: visit.landUse != null && kLandUses.contains(visit.landUse)
          ? visit.landUse!
          : null,
      irrigation: visit.irrigation,
      boundaryConfirmed: visit.boundaryConfirmed,
      notes: visit.notes != null ? WizardState.stripOccupantBlock(visit.notes!) : null,
    );
  }

  Future<void> persist() => _autoSave();

  Future<void> _autoSave() async {
    final visit = _visitController.currentVisit;
    if (visit == null) return;
    await _visitController.updateVisit(
      visit.id,
      landUse: state.landUse,
      irrigation: state.irrigation,
      boundaryConfirmed: state.boundaryConfirmed,
      notes: state.persistedNotes,
    );
  }

  Future<void> persistObservations() => _autoSave();
}

final wizardControllerProvider =
    StateNotifierProvider<WizardController, WizardState>((ref) {
  return WizardController(ref.watch(fieldVisitControllerProvider));
});
