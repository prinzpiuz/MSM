import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String username = "sdkjf";

  void _intial() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? 0;
    final ip = prefs.getString('ip') ?? 0;
    final password = prefs.getString('password') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _intial();
  }

  final usernameController = TextEditingController(text: "username");
  final ipController = TextEditingController();
  final passwordController = TextEditingController();
  final portController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    ipController.dispose();
    passwordController.dispose();
    portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text(
            'Settings',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Theme(
          data: new ThemeData(
              primaryColor: Colors.green,
              accentColor: Colors.orange,
              hintColor: Colors.grey),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              TextFormField(
                controller: usernameController,
                decoration: new InputDecoration(
                  labelText: "Enter Username",
                  fillColor: Colors.green,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(60.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length == 0) {
                    return "Username cannot be empty";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.emailAddress,
                style: new TextStyle(
                  fontFamily: "Poppins",
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: ipController,
                decoration: new InputDecoration(
                  labelText: "Enter IP Address",
                  fillColor: Colors.green,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(60.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length == 0) {
                    return "IP cannot be empty";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.numberWithOptions(),
                style: new TextStyle(
                  fontFamily: "Poppins",
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: portController,
                decoration: new InputDecoration(
                  labelText: "Enter Port Number",
                  fillColor: Colors.green,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(60.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length == 0) {
                    return "port cannot be empty";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.number,
                style: new TextStyle(
                  fontFamily: "Poppins",
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                decoration: new InputDecoration(
                  labelText: "Enter Password",
                  fillColor: Colors.green,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(60.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length == 0) {
                    return "Password cannot be empty";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.emailAddress,
                style: new TextStyle(
                  fontFamily: "Poppins",
                ),
              ),
              SizedBox(height: 10),
              FlatButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('username');
                  prefs.remove('ip');
                  prefs.remove('password');
                  prefs.remove('port');
                  prefs.setString('username', usernameController.text);
                  prefs.setString('ip', ipController.text);
                  prefs.setString('password', passwordController.text);
                  prefs.setString('port', portController.text);
                  return showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        // Retrieve the text the that user has entered by using the
                        // TextEditingController.
                        content: Text("settings saved succesfully"),
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.save,
                  color: Colors.green,
                  size: 70,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
