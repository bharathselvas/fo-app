import 'package:terranex_fo/core/storage/file_store.dart';

/// In-memory [FileStore] for widget and unit tests.
///
/// Widget tests have no `path_provider` platform channel, so the real
/// `FileStore` cannot resolve its documents directory. Overriding
/// `fileStoreProvider` with this keeps the wizard's bootstrap path working
/// without touching the device plugins.
class MemoryFileStore extends FileStore {
  final Map<String, List<int>> files = {};

  @override
  Future<String> saveEvidence({
    required String visitId,
    required String evidenceId,
    required List<int> bytes,
    String extension = 'jpg',
  }) async {
    final path = '/mem/evidence/$visitId/$evidenceId.$extension';
    files[path] = bytes;
    return path;
  }

  @override
  Future<String> saveDocument({
    required String visitId,
    required String documentId,
    required List<int> bytes,
    String extension = 'pdf',
  }) async {
    final path = '/mem/documents/$visitId/$documentId.$extension';
    files[path] = bytes;
    return path;
  }

  @override
  Future<bool> exists(String path) async => files.containsKey(path);

  @override
  Future<List<int>> readBytes(String path) async {
    final bytes = files[path];
    if (bytes == null) throw StateError('missing $path');
    return bytes;
  }

  @override
  Future<void> deleteIfExists(String path) async {
    files.remove(path);
  }
}
