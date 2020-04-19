import 'package:flutter/material.dart';
import 'package:msm/main.dart';
import 'package:msm/models.dart';
import 'dart:convert';

class ScriptPage extends StatefulWidget {
  final basicDeatials;
  ScriptPage(this.basicDeatials);
  @override
  _ScriptPageState createState() => _ScriptPageState();
}

class _ScriptPageState extends State<ScriptPage> {
  final commandController = TextEditingController();
  final commandSaveController = TextEditingController();
  final commandNameController = TextEditingController();
  bool showOutput = false;
  bool liveShell = false;
  bool setup = true;
  bool showCmdOut = false;
  var cmdOutput = '';
  var output = '';
  var cmd = '';

  List<String> commandList;
  List<Map> commandJsonList = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    commandController.dispose();
    super.dispose();
  }

  SharedPref sharedPref = SharedPref();
  Command commandSave = Command();

  List<Widget> comandListGenerator(commandList) {
    List<Widget> commandTiles = [];
    List<Map> jsonList = [];
    if (commandList.isNotEmpty) {
      for (var i = 0; i < commandList.length; i++) {
        jsonList.add(json.decode(commandList[i]));
      }

      for (var i = 0; i < jsonList.length; i++) {
        commandTiles.add(ListTile(
          // leading: Icon(Icons.code),
          title: Text(jsonList[i]["name"]),
          subtitle: Text(jsonList[i]["command"]),
        ));
        commandTiles.add(ButtonBar(
          children: <Widget>[
            FlatButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                setState(() {
                  commandList.removeAt(i);
                  sharedPref.save(commandList);
                });
              },
            ),
            FlatButton(
              child: const Text('Edit'),
              onPressed: () async {
                commandNameController.text = jsonList[i]["name"];
                commandSaveController.text = jsonList[i]["command"];
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
                        title: Text('Edit command'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              TextFormField(
                                controller: commandNameController,
                                decoration: new InputDecoration(
                                  labelText: "Name",
                                  fillColor: Colors.green,
                                ),
                                style: new TextStyle(
                                  fontFamily: "Poppins",
                                ),
                              ),
                              TextFormField(
                                controller: commandSaveController,
                                decoration: new InputDecoration(
                                  labelText: "Command",
                                  fillColor: Colors.green,
                                ),
                                style: new TextStyle(
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ],
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
                            child: Text('Save'),
                            onPressed: () async {
                              setState(() {
                                setup = true;
                                commandList.removeAt(i);
                                commandSave.name = commandNameController.text;
                                commandSave.command =
                                    commandSaveController.text;
                                commandList.add(json.encode(commandSave));
                                sharedPref.save(commandList);
                              });
                              commandNameController.text = '';
                              commandSaveController.text = '';
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            FlatButton(
              child: const Text('Run'),
              onPressed: () async {
                cmdOutput = await widget.basicDeatials["client"]
                    .execute(jsonList[i]["command"]);
                setState(() {
                  showCmdOut = true;
                });
              },
            ),
          ],
        ));
      }
    }
    return commandTiles;
  }

  @override
  Widget build(BuildContext context) {
    print("s");
    if (setup) {
      Future<dynamic> savedCommands = sharedPref.getlist();
      savedCommands.then((val) {
        setState(() {
          commandList = val == null ? [] : val;
          setup = false;
        });
      }).catchError((error) => print(error));
    }

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
                    IconButton(
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
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          liveShell = false;
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
                                  title: Text('Add new command'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        TextFormField(
                                          controller: commandNameController,
                                          decoration: new InputDecoration(
                                            labelText: "Name",
                                            fillColor: Colors.green,
                                          ),
                                          style: new TextStyle(
                                            fontFamily: "Poppins",
                                          ),
                                        ),
                                        TextFormField(
                                          controller: commandSaveController,
                                          decoration: new InputDecoration(
                                            labelText: "Command",
                                            fillColor: Colors.green,
                                          ),
                                          style: new TextStyle(
                                            fontFamily: "Poppins",
                                          ),
                                        ),
                                      ],
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
                                      child: Text('Add'),
                                      onPressed: () async {
                                        setState(() {
                                          setup = true;
                                          commandSave.name =
                                              commandNameController.text;
                                          commandSave.command =
                                              commandSaveController.text;
                                          commandList
                                              .add(json.encode(commandSave));
                                          sharedPref.save(commandList);
                                        });
                                        commandNameController.text = '';
                                        commandSaveController.text = '';
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        });
                      },
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Colors.black,
                        size: 26.0,
                      ),
                    )
                  ]),
              resizeToAvoidBottomPadding: liveShell ? true : false,
              body: liveShell
                  ? Theme(
                      data: ThemeData(
                          primaryColor: Colors.green,
                          accentColor: Colors.orange,
                          hintColor: Colors.grey),
                      child: SingleChildScrollView(
                          child: Column(
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
                      )),
                    )
                  : SafeArea(
                      child: Column(children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height /
                            2.2, // Also Including Tab-bar height.
                        child: Card(
                          child: SingleChildScrollView(
                              child: Column(
                                  children: commandList == null
                                      ? [
                                          Align(
                                              alignment: Alignment.center,
                                              child: Text("No commands saved"))
                                        ]
                                      : comandListGenerator(commandList))),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              showCmdOut ? Text(cmdOutput) : Text(""),
                            ],
                          ),
                        ),
                      ),
                    ])),
            )));
  }
}
