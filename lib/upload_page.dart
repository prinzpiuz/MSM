import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:msm/file_utils.dart';
import 'package:msm/services.dart';
import 'package:msm/models.dart';
import 'package:ssh/ssh.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) {
    print(task);
    print("Native called background task: " +
        inputData["selectedFiles"]); //simpleTask will be emitted here.
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
  Future<TvFolders> folder;
  Widget val;
  List<String> selectedFiles = [];
  List<int> select = [];
  bool upload = false;

  @override
  void initState() {
    super.initState();
    buildImages();
    folder = fetchTvFolders();
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
              _folderValues == 0
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
              new Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                child: RaisedButton(
                  color: Colors.green,
                  onPressed: () => _openFileExplorer(),
                  child: new Text("List Available Files"),
                ),
              ),
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
                        print(selectedFiles);
                        var connect =
                            await widget.basicDeatials["client"].connect();
                        print("connect $connect");
                        print(_controller.text);
                        Workmanager.initialize(
                            callbackDispatcher, // The top level function, aka callbackDispatcher
                            isInDebugMode:
                                true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
                            );
                        Workmanager.registerOneOffTask("1", "uploadFile",
                            tag: "tag",
                            inputData: {"selectedFiles": selectedFiles[0]});
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
