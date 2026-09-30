/// Exponential backoff schedule (seconds).
///
/// Locked by `test/sync_engine_test.dart` — do not reorder.
const List<int> kRetryBackoffSeconds = [2, 5, 15, 30, 60];

/// Delay before attempt number `attempt` (1-based) may be retried.
int retryDelaySeconds(int attempt) {
  if (attempt <= 0) return kRetryBackoffSeconds.first;
  if (attempt >= kRetryBackoffSeconds.length) return kRetryBackoffSeconds.last;
  return kRetryBackoffSeconds[attempt];
}

/// Attempts allowed before a queue row is parked as `FAILED`.
const int kMaxRetries = 5;

/// Whether a failed queue row is due another attempt at [now].
///
/// A row's `updatedAt` is its last-attempt timestamp, so the backoff window
/// opens `retryDelaySeconds(retryCount)` after that. Rows that have never
/// failed are always eligible — a fresh submission must not be delayed.
bool isRetryDue({
  required int retryCount,
  required DateTime lastAttemptAt,
  required DateTime now,
}) {
  if (retryCount <= 0) return true;
  final dueAt = lastAttemptAt.add(Duration(seconds: retryDelaySeconds(retryCount)));
  return !now.isBefore(dueAt);
}

/// Human-readable wait until a row becomes eligible again, or `null` if it
/// already is.
Duration? retryWait({
  required int retryCount,
  required DateTime lastAttemptAt,
  required DateTime now,
}) {
  if (isRetryDue(
    retryCount: retryCount,
    lastAttemptAt: lastAttemptAt,
    now: now,
  )) {
    return null;
  }
  final dueAt = lastAttemptAt.add(Duration(seconds: retryDelaySeconds(retryCount)));
  return dueAt.difference(now);
}
