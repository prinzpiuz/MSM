import 'package:flutter/material.dart';
import 'package:msm/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:filesize/filesize.dart';

class MediaFilesPage extends StatefulWidget {
  final basicDeatials;
  MediaFilesPage(this.basicDeatials);
  @override
  _MediaFilesPageState createState() => new _MediaFilesPageState();
}

class _MediaFilesPageState extends State<MediaFilesPage> {
  bool _notlisting = true;
  bool _movieListing = false;
  bool _tvListing = false;
  bool sizeSort = false;
  Future<List> _movieFolderFuture;
  var _movieFoldersValues;
  List<Widget> movieTileList = [];

  @override
  void initState() {
    super.initState();
    _movieFolderFuture = movieList(widget.basicDeatials);
  }

  List<Widget> movieNames(movieList) {
    if (sizeSort) {
      movieList.sort((a, b) => int.parse(a["size"].toString())
          .compareTo(int.parse(b["size"].toString())));
      print(movieList);
    } else {
      movieList.sort((a, b) =>
          a["filename"].toString().compareTo(b["filename"].toString()));
      print(movieList);
    }
    for (var i = 0; i < movieList.length; i++) {
      movieTileList.add(Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(movieList[i]["filename"][0]),
              foregroundColor: Colors.white,
            ),
            title: Text(movieList[i]["filename"]),
            subtitle: Text(filesize(movieList[i]["size"].toString())),
          ),
        ),
        actions: <Widget>[
          IconSlideAction(
            caption: 'Edit',
            color: Colors.green,
            icon: Icons.edit,
            onTap: () {
              print("ontap");
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
              var result = await widget.basicDeatials["client"].connectSFTP();
              if (result == "sftp_connected") {
                await widget.basicDeatials["client"].sftpRm(
                    widget.basicDeatials["moviePath"] +
                        '/' +
                        movieList[i]["filename"]);
              }
            },
          ),
        ],
      ));
    }
    return movieTileList;
  }

  @override
  Widget build(BuildContext context) {
    _movieFolderFuture != null
        ? _movieFolderFuture.then((val) {
            _movieFoldersValues = val;
          }).catchError((error) => print(error))
        : _movieFoldersValues = ["reload page"];
    return new MaterialApp(
        title: "Media Files",
        home: new Scaffold(
            body: Center(
              child: SingleChildScrollView(
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _notlisting ? "List Media" : "",
                        style: TextStyle(fontSize: 30),
                      ),
                      _notlisting
                          ? RaisedButton(
                              child: Text("List Movies"),
                              color: Colors.green,
                              onPressed: () {
                                setState(() {
                                  _notlisting = false;
                                  _movieListing = true;
                                });
                              },
                            )
                          : _movieFoldersValues == null
                              ? CircularProgressIndicator(
                                  backgroundColor: Colors.green,
                                )
                              : _movieListing || sizeSort
                                  ? Column(
                                      children: movieNames(_movieFoldersValues))
                                  : Container(),
                      _notlisting
                          ? RaisedButton(
                              child: Text("List TV"),
                              color: Colors.green,
                              onPressed: () {
                                setState(() {
                                  _notlisting = false;
                                  _tvListing = true;
                                });
                              },
                            )
                          : Container()
                    ]),
              ),
            ),
            floatingActionButton: _movieListing
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
