import 'package:flutter/material.dart';
import 'package:msm/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:filesize/filesize.dart';

class TvFilespage extends StatefulWidget {
  final basicDeatials;
  TvFilespage(this.basicDeatials);
  @override
  _TvFilespageState createState() => new _TvFilespageState();
}

class _TvFilespageState extends State<TvFilespage> {
  bool _notlisting = true;
  bool _movieListing = false;
  bool _tvListing = false;
  bool sizeSort = false;
  Future<List> _movieFolderFuture;
  Future<List> _tvfolderFuture;
  var _movieFoldersValues;
  var _tvFoldersValues;
  List<Widget> movieTileList = [];
  List<Widget> tvTileList = [];
  final renameController = TextEditingController();
  String oldName = '';
  bool changed = false;

  @override
  void initState() {
    super.initState();
    _tvfolderFuture = fetchTvFolders(widget.basicDeatials);
  }

  List<Widget> tvFolderNames(tvfolders) {
    tvfolders.sort((a, b) => a.toString().compareTo(b.toString()));
    tvTileList.clear();
    for (var i = 0; i < tvfolders.length; i++) {
      tvTileList.add(FlatButton(
        onPressed: () {
          print("ndc");
        },
        child: Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Container(
            color: Colors.white,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Text(tvfolders[i][0]),
                foregroundColor: Colors.white,
              ),
              title: Text(tvfolders[i]),
              // subtitle: Text(tvfolders[i].toString())),
            ),
          ),
          actions: <Widget>[
            IconSlideAction(
              caption: 'Edit',
              color: Colors.green,
              icon: Icons.edit,
              onTap: () {
                renameController.text = tvfolders[i];
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
                        title: Text('Edit folder name'),
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
                                oldName = tvfolders[i];
                                _tvFoldersValues[i] = renameController.text;
                              });
                              Navigator.of(context).pop();
                              var result = await widget.basicDeatials["client"]
                                  .connectSFTP();
                              if (result == "sftp_connected") {
                                await widget.basicDeatials["client"].sftpRename(
                                  oldPath: widget.basicDeatials["tvPath"] +
                                      '/' +
                                      oldName,
                                  newPath: widget.basicDeatials["tvPath"] +
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
              caption: 'More',
              color: Colors.green,
              icon: Icons.expand_more,
              onTap: () {
                print("ontap");
              },
            ),
            IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              closeOnTap: true,
              onTap: () async {
                setState(() {
                  changed = true;
                  oldName = tvfolders[i];
                  _tvFoldersValues.removeAt(i);
                });
                var execute = await widget.basicDeatials["client"].execute(
                    "rm -rf " + widget.basicDeatials["tvPath"] + "/" + oldName);
              },
            ),
          ],
        ),
      ));
    }
    return tvTileList;
  }

  @override
  Widget build(BuildContext context) {
    if (!changed) {
      _tvfolderFuture != null
          ? _tvfolderFuture.then((val) {
              setState(() {
                _tvFoldersValues = val;
                changed = true;
              });
            }).catchError((error) => print(error))
          : _tvFoldersValues = ["reload page"];
    }
    return new MaterialApp(
        title: "TV Files",
        home: new Scaffold(
            body: Center(
              child: SingleChildScrollView(
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _tvFoldersValues == null
                          ? CircularProgressIndicator(
                              backgroundColor: Colors.green,
                            )
                          : Column(children: tvFolderNames(_tvFoldersValues))
                    ]),
              ),
            ),
            floatingActionButton: _tvListing
                ? FloatingActionButton(
                    onPressed: () {
                      // Add your onPressed code here!
                      setState(() {
                        // _notlisting = false;
                        // _movieListing = true;
                        sizeSort = true;
                      });
                    },
                    child: Icon(Icons.sort),
                    backgroundColor: Colors.green,
                  )
                : SizedBox.shrink()));
  }
}
