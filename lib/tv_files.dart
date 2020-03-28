import 'package:flutter/material.dart';
import 'package:msm/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:filesize/filesize.dart';

class TvFilesPage extends StatefulWidget {
  final basicDeatials;
  final tvFolderName;
  TvFilesPage(this.basicDeatials, this.tvFolderName);
  @override
  _TvFilesPageState createState() => new _TvFilesPageState();
}

class _TvFilesPageState extends State<TvFilesPage> {
  bool nameSort = true;
  Future<List> _tvFilesFuture;
  var _tvFilesValues;
  List<Widget> tvTileList = [];
  final renameController = TextEditingController();
  String oldName = '';
  bool changed = false;

  @override
  void initState() {
    super.initState();
    _tvFilesFuture = tvFileList(widget.basicDeatials, widget.tvFolderName);
  }

  List<Widget> tvFileNames(tvFileNameList) {
    if (nameSort) {
      tvFileNameList.sort((a, b) => int.parse(a["size"].toString())
          .compareTo(int.parse(b["size"].toString())));
    } else {
      tvFileNameList.sort((a, b) =>
          a["filename"].toString().compareTo(b["filename"].toString()));
    }
    tvTileList.clear();
    for (var i = 0; i < tvFileNameList.length; i++) {
      tvTileList.add(Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(tvFileNameList[i]["filename"][0]),
              foregroundColor: Colors.white,
            ),
            title: Text(tvFileNameList[i]["filename"]),
            subtitle: Text(filesize(tvFileNameList[i]["size"].toString())),
          ),
        ),
        actions: <Widget>[
          IconSlideAction(
            caption: 'Edit',
            color: Colors.green,
            icon: Icons.edit,
            onTap: () {
              renameController.text = tvFileNameList[i]["filename"];
              showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return Theme(
                    data: new ThemeData(
                        primaryColor: Colors.green,
                        accentColor: Colors.orange,
                        hintColor: Colors.grey),
                    child: AlertDialog(
                      title: Text('Edit file name'),
                      content: TextFormField(
                        controller: renameController,
                        decoration: new InputDecoration(
                          fillColor: Colors.green,
                        ),
                        validator: (val) {
                          if (val.length == 0) {
                            return "name cannot be empty";
                          } else {
                            return null;
                          }
                        },
                        style: new TextStyle(
                          fontFamily: "Poppins",
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('Rename'),
                          onPressed: () async {
                            setState(() {
                              changed = true;
                              oldName = tvFileNameList[i]["filename"];
                              _tvFilesValues[i]["filename"] =
                                  renameController.text;
                            });
                            Navigator.of(context).pop();
                            var result = await widget.basicDeatials["client"]
                                .connectSFTP();
                            if (result == "sftp_connected") {
                              await widget.basicDeatials["client"].sftpRename(
                                oldPath: widget.basicDeatials["moviePath"] +
                                    '/' +
                                    oldName,
                                newPath: widget.basicDeatials["moviePath"] +
                                    '/' +
                                    renameController.text,
                              );
                              await widget.basicDeatials["client"]
                                  .disconnectSFTP();
                            }
                          },
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            closeOnTap: true,
            onTap: () async {
              setState(() {
                changed = true;
                oldName = tvFileNameList[i]["filename"];
                _tvFilesValues.removeAt(i);
              });
              var result = await widget.basicDeatials["client"].connectSFTP();
              if (result == "sftp_connected") {
                await widget.basicDeatials["client"]
                    .sftpRm(widget.basicDeatials["moviePath"] + '/' + oldName);
                await widget.basicDeatials["client"].disconnectSFTP();
              }
            },
          ),
        ],
      ));
    }
    return tvTileList;
  }

  @override
  Widget build(BuildContext context) {
    if (!changed) {
      _tvFilesFuture != null
          ? _tvFilesFuture.then((val) {
              setState(() {
                _tvFilesValues = val;
                changed = true;
              });
            }).catchError((error) => print(error))
          : _tvFilesValues = ["reload page"];
    }
    return new MaterialApp(
        title: "Files in " + widget.tvFolderName,
        home: new Scaffold(
            appBar: AppBar(
              title: Text(widget.tvFolderName,
                  style: TextStyle(color: Colors.black)),
              elevation: 0,
              backgroundColor: Colors.white,
            ),
            body: Center(
              child: SingleChildScrollView(
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _tvFilesValues == null
                          ? LinearProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.green),
                              backgroundColor: Colors.white,
                            )
                          : Column(children: tvFileNames(_tvFilesValues))
                    ]),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // Add your onPressed code here!
                if (nameSort) {
                  setState(() {
                    nameSort = false;
                  });
                } else {
                  setState(() {
                    nameSort = true;
                  });
                }
              },
              child: Icon(Icons.sort),
              backgroundColor: Colors.green,
            )));
  }
}
