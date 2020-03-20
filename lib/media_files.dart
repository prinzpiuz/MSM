import 'package:flutter/material.dart';
import 'package:msm/services.dart';

class MediaFilesPage extends StatefulWidget {
  final basicDeatials;
  MediaFilesPage(this.basicDeatials);
  @override
  _MediaFilesPageState createState() => new _MediaFilesPageState();
}

class _MediaFilesPageState extends State<MediaFilesPage> {
  bool _notlisting = true;
  Future<List> _folderFuture;
  var _foldersValues;

  @override
  void initState() {
    super.initState();
    _folderFuture = movieList(widget.basicDeatials);
  }

  @override
  Widget build(BuildContext context) {
    _folderFuture != null
        ? _folderFuture.then((val) {
            _foldersValues = val;
          }).catchError((error) => print(error))
        : _foldersValues = ["reload page"];
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
                            });
                          },
                        )
                      : _foldersValues == null
                          ? CircularProgressIndicator(
                              backgroundColor: Colors.green,
                            )
                          : Builder(
                              builder: (BuildContext context) => Container(
                                  padding: const EdgeInsets.only(bottom: 30.0),
                                  // height: MediaQuery.of(context).size.height * 0.50,
                                  child: new Scrollbar(
                                      child: new ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: _foldersValues.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ListTile(
                                          title: Text(_foldersValues[index]));
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            new Divider(),
                                  )))),
                  _notlisting
                      ? RaisedButton(
                          child: Text("List TV"),
                          color: Colors.green,
                          onPressed: () {
                            setState(() {
                              _notlisting = false;
                            });
                          },
                        )
                      : Container()
                ]),
          ),
        )));
  }
}
