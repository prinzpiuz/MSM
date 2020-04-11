import 'package:flutter/material.dart';
import 'package:msm/main.dart';

class ScriptPage extends StatefulWidget {
  final basicDeatials;
  ScriptPage(this.basicDeatials);
  @override
  _ScriptPageState createState() => _ScriptPageState();
}

class _ScriptPageState extends State<ScriptPage> {
  final commandController = TextEditingController();
  bool showOutput = false;
  bool liveShell = false;
  var output = '';
  var cmd = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: MaterialApp(
            color: Colors.black,
            title: "Manage Server",
            home: Scaffold(
              appBar: AppBar(
                  title: Text("Manage Server",
                      style: TextStyle(color: Colors.black)),
                  elevation: 0,
                  backgroundColor: Colors.white,
                  leading: Container(
                      child: IconButton(
                    color: Colors.black,
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp()),
                      );
                    },
                  )),
                  actions: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              liveShell = true;
                            });
                          },
                          icon: Icon(
                            Icons.code,
                            color: Colors.black,
                            size: 26.0,
                          ),
                        )),
                    Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Icon(
                          Icons.add_circle_outline,
                          color: Colors.black,
                          size: 26.0,
                        ))
                  ]),
              body: Theme(
                data: ThemeData(
                    primaryColor: Colors.green,
                    accentColor: Colors.orange,
                    hintColor: Colors.grey),
                child: SingleChildScrollView(
                  child: liveShell
                      ? Column(
                          children: <Widget>[
                            showOutput
                                ? Text(
                                    cmd,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30),
                                  )
                                : SizedBox.shrink(),
                            showOutput ? Text(output) : SizedBox.shrink(),
                            Stack(
                                alignment: const Alignment(1.0, 1.0),
                                children: <Widget>[
                                  TextField(
                                      autocorrect: false,
                                      controller: commandController,
                                      decoration: InputDecoration(
                                          labelText: "Enter Commands",
                                          hintText:
                                              "eg:systemctl status emby-server.service",
                                          fillColor: Colors.green,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(60.0),
                                            borderSide: BorderSide(),
                                          ))),
                                  FlatButton(
                                      onPressed: () async {
                                        var result = await widget
                                            .basicDeatials["client"]
                                            .execute(commandController.text);
                                        setState(() {
                                          showOutput = true;
                                          cmd = commandController.text;
                                          output = result;
                                        });
                                        commandController.clear();
                                      },
                                      child: Icon(
                                        Icons.send,
                                        size: 40,
                                      ))
                                ])
                          ],
                        )
                      : Column(
                          children: <Widget>[],
                        ),
                ),
              ),
            )));
  }
}
