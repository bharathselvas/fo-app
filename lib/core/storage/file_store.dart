import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// App-private file storage for evidence and documents.
/// Paths: {appDocuments}/evidence/{visitId}/{evidenceId}.jpg
///        {appDocuments}/documents/{visitId}/{documentId}.{ext}
class FileStore {
  Future<Directory> _base() async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/field_data');
  }

  Future<String> saveEvidence({
    required String visitId,
    required String evidenceId,
    required List<int> bytes,
    String extension = 'jpg',
  }) async {
    final dir = Directory('${(await _base()).path}/evidence/$visitId');
    await dir.create(recursive: true);
    final path = '${dir.path}/$evidenceId.$extension';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return path;
  }

  Future<String> saveDocument({
    required String visitId,
    required String documentId,
    required List<int> bytes,
    String extension = 'pdf',
  }) async {
    final dir = Directory('${(await _base()).path}/documents/$visitId');
    await dir.create(recursive: true);
    final path = '${dir.path}/$documentId.$extension';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return path;
  }

  Future<void> deleteIfExists(String path) async {
    final f = File(path);
    if (await f.exists()) {
      await f.delete();
    }
  }

  Future<bool> exists(String path) => File(path).exists();

  Future<List<int>> readBytes(String path) => File(path).readAsBytes();
}
