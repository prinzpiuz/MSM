import 'package:flutter/material.dart';
import 'package:msm/settings_page.dart';

void main() => runApp(MyApp());

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

class MyHome extends StatelessWidget {
  void pressed(index, context) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () => pressed(index, context),
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
                  child: const ListTile(
                      leading:
                          Icon(Icons.computer, size: 50, color: Colors.green),
                      title: Text('Druv 1.0')
                      // subtitle: is_server_live(),
                      ),
                ),
                new Flexible(
                  child: const ListTile(
                    leading: Icon(Icons.folder, size: 50),
                    title: Text('344'),
                    subtitle: Text('out of 500 GB'),
                  ),
                )
              ],
            )
          ],
        ));
  }
}
