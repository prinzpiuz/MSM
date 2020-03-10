import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:msm/file_utils.dart';
import 'package:msm/services.dart';
import 'package:ssh/ssh.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    var client = SSHClient(
      host: inputData["ip"],
      port: int.parse(inputData["port"]),
      username: inputData["username"],
      passwordOrKey: inputData["password"],
    );
    try {
      String result = await client.connect();
      if (result == "session_connected") {
        result = await client.connectSFTP();
        if (result == "sftp_connected") {}
      }
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
    // print("Native called background task: " +
    //     inputData["selectedFiles"]); //simpleTask will be emitted here.
    await client.sftpUpload(
      path: inputData["selectedFiles"],
      toPath: inputData["path"],
      callback: (progress) {
        print(progress); // read upload progress
      },
    );
    return Future.value(true);
  });
}

class UploadPage extends StatefulWidget {
  final basicDeatials;
  UploadPage(this.basicDeatials);
  @override
  _UploadPageState createState() => new _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String _pickingType;
  int _folderValues;
  TextEditingController _controller = new TextEditingController();
  Future<List> folderFuture;
  Widget val;
  List<String> selectedFiles = [];
  List<int> select = [];
  bool upload = false;
  String path;
  bool picked = false;
  var foldersValues;
  @override
  void initState() {
    super.initState();
    buildImages();
    folderFuture = fetchTvFolders(widget.basicDeatials);
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
      fileNames.add(files[i].path.toString());
    }
  }

  void _openFileExplorer() async {
    setState(() {
      upload = true;
      getFileNames();
    });
  }

  buidDropDown(foldersValues) {
    List<DropdownMenuItem> dropDown(data) {
      print(data);
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

    if (folderFuture != null) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: new DropdownButton(
            hint: Text('Select TV Folder'),
            items: dropDown(foldersValues),
            value: _folderValues,
            onChanged: (value) => setState(() {
                  _folderValues = value;
                })),
      );
    } else {
      return Text("{snapshot.error}");
    }
  }

  @override
  Widget build(BuildContext context) {
    folderFuture != null
        ? folderFuture.then((val) {
            foldersValues = val;
          }).catchError((error) => print(error))
        : foldersValues = ["reload page"];
    Workmanager.initialize(
        callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode:
            true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
        );
    return new MaterialApp(
      title: "kd",
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
                          picked = true;
                          _pickingType = value;
                        })),
              ),
              _pickingType == "2" ? buidDropDown(foldersValues) : Container(),
              _folderValues == 0 && _pickingType == "2"
                  ? new TextFormField(
                      maxLength: 15,
                      autovalidate: true,
                      controller: _controller,
                      decoration:
                          InputDecoration(labelText: 'Enter New Folder Name'),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.none,
                    )
                  : new Container(),
              picked
                  ? new Padding(
                      padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                      child: RaisedButton(
                        color: Colors.green,
                        onPressed: () => _openFileExplorer(),
                        child: new Text("List Available Files"),
                      ),
                    )
                  : Container(),
              new Builder(
                  builder: (BuildContext context) => Container(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        height: MediaQuery.of(context).size.height * 0.50,
                        child: new Scrollbar(
                          child: new ListView.separated(
                            itemCount: fileNames != null && fileNames.isNotEmpty
                                ? fileNames.length
                                : 1,
                            itemBuilder: (BuildContext context, int index) {
                              final bool isMultiPath =
                                  fileNames != null && fileNames.isNotEmpty;
                              final String name =
                                  fileNames.isNotEmpty ? fileNames[index] : '';
                              final path = isMultiPath
                                  ? fileNames[index].toString()
                                  : "";

                              return name != ''
                                  ? ListTile(
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
                                    )
                                  : Container();
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    new Divider(),
                          ),
                        ),
                      )),
              upload
                  ? RaisedButton(
                      color: Colors.green,
                      onPressed: () async {
                        print("pressed");
                        // print(selectedFiles);
                        // var connect =
                        //     await widget.basicDeatials["client"].connect();
                        // print("connect $connect");
                        // print(_controller.text);
                        if (_pickingType == "1") {
                          path = widget.basicDeatials["moviePath"];
                        } else {
                          path = widget.basicDeatials["tvPath"];
                        }

                        for (var i = 0; i < selectedFiles.length; i++) {
                          Workmanager.registerOneOffTask("1", "uploadFile",
                              tag: selectedFiles[i],
                              inputData: {
                                "selectedFiles": selectedFiles[i],
                                "path": path,
                                "ip": widget.basicDeatials["ip"],
                                "port": widget.basicDeatials["port"],
                                "password": widget.basicDeatials["password"],
                                "username": widget.basicDeatials["username"]
                              });
                        }
                      },
                      child: Text("Upload"))
                  : Container(),
            ],
          ),
        )),
      ),
    );
  }
}
