import 'package:flutter/material.dart';
import 'package:msm/settings_page.dart';
import 'package:msm/upload_page.dart';
import 'package:msm/models.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());
var basicDeatials;

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Media Server Manager';
    return MaterialApp(
      title: title,
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  Map<PermissionGroup, PermissionStatus> permissions;
  void pressed(index, context, basicDeatials) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    }
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UploadPage(basicDeatials)),
      );
    }
  }

  setPermissions() async {
    permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }

  @override
  Widget build(BuildContext context) {
    setPermissions();
    final data = BasicServerDetails().basicDetails();
    data.then((val) {
      basicDeatials = val;
    }).catchError((error) => print(error));
    var headings = ['Upload', 'Server', 'Files', 'Settings'];
    return Scaffold(
        backgroundColor: Colors.white,
        body: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Flexible(
                child: GridView.count(
              crossAxisCount: 2,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.all(5.0),
                  child: RaisedButton(
                      onPressed: () => pressed(index, context, basicDeatials),
                      color: Colors.green,
                      child: Center(
                          child: Text(headings[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 30)))),
                );
              }),
            )),
            new Row(
              children: <Widget>[
                new Flexible(
                  child: ListTile(
                    leading: IconButton(
                        icon: Icon(Icons.computer,
                            size: 50,
                            color: basicDeatials != null
                                ? Colors.green
                                : Colors.black),
                        onPressed: () {
                          setState(() {
                            final data = BasicServerDetails().basicDetails();
                            data.then((val) {
                              basicDeatials = val;
                            }).catchError((error) => print(error));
                          });
                        }),
                    // Icon(Icons.computer, size: 50, color: Colors.green),
                    title: basicDeatials != null
                        ? Text(basicDeatials["hostname"])
                        : Text("Check Connection"),
                    subtitle:
                        basicDeatials == null ? Text("press") : Text("live"),
                  ),
                ),
                new Flexible(
                  child: basicDeatials == null
                      ? Container()
                      : ListTile(
                          leading: Icon(Icons.folder, size: 50),
                          title: Text(
                              basicDeatials["usedSpace"].replaceAll('\n', '')),
                          subtitle: Text('out of ' +
                              basicDeatials["totalSize"].replaceAll(' ', '')),
                        ),
                )
              ],
            )
          ],
        ));
  }
}
