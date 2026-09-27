/// Exponential backoff schedule (seconds).
const List<int> kRetryBackoffSeconds = [2, 5, 15, 30, 60];

int retryDelaySeconds(int attempt) {
  if (attempt <= 0) return kRetryBackoffSeconds.first;
  if (attempt >= kRetryBackoffSeconds.length) return kRetryBackoffSeconds.last;
  return kRetryBackoffSeconds[attempt];
}

const int kMaxRetries = 5;
