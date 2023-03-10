// Project imports:
import 'package:msm/models/file_manager.dart';

class FileUploadData {
  List<FileOrDirectory> uploadData = [];
  FileUploadData();

  void get clear => uploadData.clear();

  void addOrRemove(FileOrDirectory data) {
    if (uploadData.contains(data)) {
      uploadData.remove(data);
    } else {
      uploadData.add(data);
    }
  }

  bool fileAdded(FileOrDirectory data) => uploadData.contains(data);
}
