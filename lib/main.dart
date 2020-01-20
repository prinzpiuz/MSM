import 'package:flutter/material.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {

  void pressed() {
    print("pressed");
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Media Server Manager';
    var headings = ['Upload', 'Server', 'Files', 'Settings'];
    return MaterialApp(
      title: title,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: GridView.count(
          crossAxisCount: 2,
          children: List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.all(5.0),
              child: RaisedButton(
              onPressed: pressed,
              color: Colors.green,
              child: Center(
                child: Text(
                headings[index] ,
                textAlign: TextAlign.center,
                style:TextStyle(color: Colors.white, fontSize: 30)
                )
              )
              ),
            );
          }),
        ),
      ),
    );
  }
}