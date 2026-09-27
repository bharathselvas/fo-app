import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Client UUID generated once when a local record is created.
/// Never regenerate during retries — used as server idempotency key.
String newClientId() => _uuid.v4();
