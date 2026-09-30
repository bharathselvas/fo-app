/// Signed-in field officer (demonstration data — not a real person).
class FieldOfficer {
  const FieldOfficer({
    required this.officerId,
    required this.name,
    required this.role,
    required this.designation,
    required this.department,
    required this.district,
    required this.state,
    required this.assignedArea,
    required this.phone,
    required this.office,
    required this.email,
  });

  final String officerId;
  final String name;
  final String role;
  final String designation;
  final String department;
  final String district;
  final String state;
  final String assignedArea;
  final String phone;
  final String office;
  final String email;

  /// Same as [officerId] — kept for call sites that expect an `id`.
  String get id => officerId;

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? name : parts.first;
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
