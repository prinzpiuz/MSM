import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:msm/file_utils.dart';
import 'package:msm/services.dart';
import 'package:msm/models.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => new _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  bool _hasValidMime = false;
  String _pickingType;
  int _folderValues;
  TextEditingController _controller = new TextEditingController();
  Future<TvFolders> folder;
  Widget val;
  List<String> selectedFiles = [];
  List<int> select = [];

  @override
  void initState() {
    super.initState();
    buildImages();
    folder = fetchTvFolders();
    _controller.addListener(() => _extension = _controller.text);
  }

  List<File> files;
  List<String> fileNames = [];
  Future buildImages() async {
    var root = await getExternalStorageDirectory();
    files = await listFiles(root.path + "/Download/",
        extensions: ["mp4", "mkv", "srt", "avi"]);
    return files;
  }

  void getFileNames() {
    for (var i = 0; i < files.length; i++) {
      fileNames.add(files[i].toString());
    }
  }

  void _openFileExplorer() async {
    // if (_pickingType != "2" || _hasValidMime) {
    //   setState(() => _loadingPath = true);
    //   try {
    //     if (_multiPick) {
    //       _path = null;
    //       _paths = await FilePicker.getMultiFilePath(
    //           type: FileType.ANY,
    //           fileExtension:
    //               _extension); //need to write a function here to validate file type
    //     } else {
    //       _paths = null;
    //       _path = await FilePicker.getFilePath(
    //           type: FileType.ANY, fileExtension: _extension);
    //     }
    //     print(_path);
    //   } on PlatformException catch (e) {
    //     print("Unsupported operation" + e.toString());
    //   }
    //   if (!mounted) return;
    //   setState(() {
    //     _loadingPath = false;
    //     _fileName = _path != null
    //         ? _path.split('/').last
    //         : _paths != null ? _paths.keys.toString() : '...';
    //   });
    // }
    setState(() {
      getFileNames();
    });
  }

  buidDropDown() {
    List<DropdownMenuItem> dropDown(data) {
      List<DropdownMenuItem> dropDownItems = [];
      dropDownItems.add(DropdownMenuItem(
        child: new Text('New Folder'),
        value: 0,
      ));
      for (var i = 0; i < data.length; i++) {
        dropDownItems.add(DropdownMenuItem(
            child: data[i].toString().length > 20
                ? new Text(data[i].toString().replaceRange(
                    data[i].toString().length - 10,
                    data[i].toString().length,
                    ''))
                : Text(data[i].toString()),
            value: i + 1));
      }
      return dropDownItems.toList();
    }

    return FutureBuilder<TvFolders>(
        future: folder,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: new DropdownButton(
                  hint: Text('Select TV Folder'),
                  items: dropDown(snapshot.data.folders),
                  value: _folderValues,
                  onChanged: (value) => setState(() {
                        _folderValues = value;
                      })),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
        });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        body: new Center(
            child: new SingleChildScrollView(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: new DropdownButton(
                    hint: new Text('Movie/TV'),
                    value: _pickingType,
                    items: <DropdownMenuItem>[
                      new DropdownMenuItem(
                        child: new Text('Movies'),
                        value: "1",
                      ),
                      new DropdownMenuItem(
                        child: new Text('Tv Series'),
                        value: "2",
                      ),
                    ],
                    onChanged: (value) => setState(() {
                          _pickingType = value;
                        })),
              ),
              _pickingType == "2"
                  ? buidDropDown()
                  :
                  // Text("dsnflds"):
                  Container(),
              new ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: 100.0),
                child: _folderValues == 0
                    ? new TextFormField(
                        maxLength: 15,
                        autovalidate: true,
                        controller: _controller,
                        decoration:
                            InputDecoration(labelText: 'New Folder Name'),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.none,
                        // validator: (value) {
                        //   RegExp reg = new RegExp(r'[^a-zA-Z0-9]');
                        //   if (reg.hasMatch(value)) {
                        //     _hasValidMime = false;
                        //     return 'Invalid format';
                        //   }
                        //   _hasValidMime = true;
                        //   return null;
                        // },
                      )
                    : new Container(),
              ),
              new ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: 200.0),
                child: new SwitchListTile.adaptive(
                  title: new Text('Pick multiple files',
                      textAlign: TextAlign.right),
                  onChanged: (bool value) => setState(() => _multiPick = value),
                  value: _multiPick,
                ),
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                child: RaisedButton(
                  color: Colors.green,
                  onPressed: () => _openFileExplorer(),
                  child: new Text("List Available Files"),
                ),
              ),
              new Builder(
                builder: (BuildContext context) => _loadingPath
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: const CircularProgressIndicator())
                    : fileNames != null || fileNames != null
                        ? new Container(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            height: MediaQuery.of(context).size.height * 0.50,
                            child: new Scrollbar(
                              child: new ListView.separated(
                                itemCount:
                                    fileNames != null && fileNames.isNotEmpty
                                        ? fileNames.length
                                        : 1,
                                itemBuilder: (BuildContext context, int index) {
                                  int itemNumber = index + 1;
                                  final bool isMultiPath =
                                      fileNames != null && fileNames.isNotEmpty;
                                  final String name = fileNames.isNotEmpty
                                      ? itemNumber.toString() +
                                          ' ' +
                                          fileNames[index]
                                      : '';
                                  final path = isMultiPath
                                      ? fileNames[index].toString()
                                      : "";

                                  return new ListTile(
                                    title: name != null
                                        ? new Text(
                                            name,
                                          )
                                        : Text(" "),
                                    subtitle: path != null
                                        ? new Text(path)
                                        : Text(" "),
                                    selected:
                                        select.contains(index) ? true : false,
                                    trailing: select.contains(index)
                                        ? Icon(Icons.radio_button_checked)
                                        : Icon(Icons.radio_button_unchecked),
                                    onLongPress: () {
                                      setState(() {
                                        select.remove(index);
                                      });
                                    },
                                    onTap: () {
                                      selectedFiles.add(name);

                                      setState(() {
                                        select.add(index);
                                      });
                                    },
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        new Divider(),
                              ),
                            ),
                          )
                        : new Container(),
              ),
              RaisedButton(
                  color: Colors.green,
                  onPressed: () {
                    print(selectedFiles);
                  },
                  child: Text("Upload")),
            ],
          ),
        )),
      ),
    );
  }
}
