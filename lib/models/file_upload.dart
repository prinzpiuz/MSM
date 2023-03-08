// Package imports:
import 'package:dartssh2/dartssh2.dart';

// Project imports:
import 'package:msm/models/file_manager.dart';

class FileUpload {
  late SSHClient? client;
  List<FileOrDirectory> uploadData = [];
  FileUpload(SSHClient client);

  void get clear => uploadData.clear();

  void addOrRemove(FileOrDirectory data) {
    if (uploadData.contains(data)) {
      uploadData.remove(data);
    } else {
      uploadData.add(data);
    }
  }

  bool fileAdded(FileOrDirectory data) => uploadData.contains(data);

  void upload() {
    if (client != null && uploadData.isNotEmpty) {
      for (FileOrDirectory data in uploadData) {
        print(data);
      }
    }
  }
}
