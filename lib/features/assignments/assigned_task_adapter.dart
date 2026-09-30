import '../../core/database/database.dart';
import '../../data/models/land_case.dart';

/// Case detail uses [LandCase] (rich dossier), while the field-visit workflow
/// and the local cache still speak `AssignedTask`. This adapter is the single
/// bridge between the two — no mock data is duplicated.
AssignedTask assignedTaskFromCase(LandCase c, {required String officerId}) =>
    AssignedTask(
      id: c.parcelId,
      clientId: c.parcelId,
      caseId: c.caseNo,
      parcelId: c.parcelId,
      projectId: c.projectId,
      caseNo: c.caseNo,
      surveyNo: c.surveyNo,
      village: c.village,
      tehsil: c.taluk,
      district: c.district,
      state: 'Tamil Nadu',
      areaHa: (c.extentAcres * 0.404686).toStringAsFixed(3),
      stage: c.stage,
      status: c.status.name,
      ownerName: c.landOwner.name,
      landType: c.landType,
      geometryWkt: c.geometryWkt,
      centroidLat: c.latitude.toStringAsFixed(6),
      centroidLng: c.longitude.toStringAsFixed(6),
      officerId: officerId,
      rawJson: '{}',
      cachedAt: DateTime.now().toUtc(),
    );
