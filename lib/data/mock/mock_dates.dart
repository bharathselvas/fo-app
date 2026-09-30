/// Calendar-day helper shared by every mock dataset so due dates, SLA labels
/// and timelines stay relative to the day the prototype is demonstrated.
DateTime day(int offset) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day).add(Duration(days: offset));
}
