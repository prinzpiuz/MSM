import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:msm/file_utils.dart';
import 'package:msm/services.dart';
import 'package:ssh/ssh.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
        if (result == "sftp_connected") {
          if (inputData["tv"]) {
            await client.sftpMkdir(inputData["path"]);
          }
          await client.sftpUpload(
            path: inputData["selectedFiles"],
            toPath: inputData["path"],
            callback: (progress) async {
              await _showNotification(progress, inputData["selectedFiles"]);
            },
          );
        }
      }
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
    // print("Native called background task: " +
    //     inputData["selectedFiles"]); //simpleTask will be emitted here.
    return Future.value(true);
  });
}

Future<void> _showNotification(progress, data) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'progress channel', 'progress channel', 'progress channel description',
      channelShowBadge: false,
      importance: Importance.Max,
      priority: Priority.High,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: progress);
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(0, 'Upload', data, platformChannelSpecifics, payload: 'item x');
}

class UploadPage extends StatefulWidget {
  final basicDeatials;
  UploadPage(this.basicDeatials);
  @override
  _UploadPageState createState() => new _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String _pickingType;
  String _folderValues;
  TextEditingController _controller = new TextEditingController();
  Future<List> folderFuture;
  Widget val;
  List<String> selectedFiles = [];
  List<int> select = [];
  bool upload = false;
  String path;
  bool picked = false;
  var foldersValues;
  bool tv = false;
  bool listed = false;
  bool proceed = true;
  List<File> files;
  List<String> fileNames = [];

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    buildImages();
    folderFuture = fetchTvFolders(widget.basicDeatials);
  }

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
      listed = true;
      getFileNames();
    });
  }

  buidDropDown(foldersValues) {
    List<DropdownMenuItem> dropDown(data) {
      List<DropdownMenuItem> dropDownItems = [];
      dropDownItems.add(DropdownMenuItem(
        child: new Text('New Folder'),
        value: "0",
      ));
      for (var i = 0; i < data.length; i++) {
        dropDownItems.add(DropdownMenuItem(
            child: data[i].toString().length > 20
                ? new Text(data[i].toString().replaceRange(
                    data[i].toString().length - 10,
                    data[i].toString().length,
                    ''))
                : Text(data[i].toString()),
            value: data[i].toString()));
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
            false // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
        );
    return new MaterialApp(
      title: "Upload Page",
      home: new Scaffold(
        body: new Center(
            child: new SingleChildScrollView(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Upload Media",
                style: TextStyle(fontSize: 20),
              ),
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
              _folderValues == "0" && _pickingType == "2"
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
                        onPressed: () {
                          !listed ? _openFileExplorer() : print("");
                        },
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
                                          upload = false;
                                          select.remove(index);
                                        });
                                      },
                                      onTap: () {
                                        selectedFiles.add(name);

                                        setState(() {
                                          upload = true;
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
                        if (_pickingType == "2" && _folderValues == null) {
                          proceed = false;
                          Flushbar(
                            backgroundColor: Colors.green,
                            title: "folder missing",
                            isDismissible: true,
                            message: "select TV folder to upload",
                            duration: Duration(seconds: 5),
                          )..show(context);
                        }
                        if (_pickingType == "2" &&
                            _folderValues == "0" &&
                            _controller.text.isEmpty) {
                          proceed = false;
                          Flushbar(
                            backgroundColor: Colors.green,
                            title: "folder missing",
                            isDismissible: true,
                            message: "Enter new folder name",
                            duration: Duration(seconds: 5),
                          )..show(context);
                        }
                        if (_pickingType == "1") {
                          path = widget.basicDeatials["moviePath"];
                        } else {
                          if (_folderValues != "0" && _pickingType == "2") {
                            path = widget.basicDeatials["tvPath"] +
                                "/" +
                                _folderValues.toString();
                          } else {
                            tv = true;

                            path = widget.basicDeatials["tvPath"] +
                                "/" +
                                _controller.text;
                          }
                        }
                        if (proceed) {
                          for (var i = 0; i < selectedFiles.length; i++) {
                            Workmanager.registerOneOffTask(
                                "1", "uploadFile" + i.toString(),
                                existingWorkPolicy: ExistingWorkPolicy.append,
                                tag: selectedFiles[i],
                                inputData: {
                                  "selectedFiles": selectedFiles[i],
                                  "path": path,
                                  "ip": widget.basicDeatials["ip"],
                                  "port": widget.basicDeatials["port"],
                                  "password": widget.basicDeatials["password"],
                                  "username": widget.basicDeatials["username"],
                                  "tv": tv
                                });
                          }
                          Flushbar(
                            backgroundColor: Colors.green,
                            title: "Upload Started",
                            isDismissible: true,
                            message:
                                "upload started in background,will get notification once finished",
                            duration: Duration(seconds: 10),
                          )..show(context);
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
