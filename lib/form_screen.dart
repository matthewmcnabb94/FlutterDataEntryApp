import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flushbar/flushbar.dart';

String id;
List<String> _dropitems = ['A', 'B', 'C', 'D'];
String _selectedType;

class FormScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormScreenState();
  }
}

class FormScreenState extends State<FormScreen> {
  String _name;
  String _email;
  String _password;
  String _url;
  String _phoneNumber;
  String _calories;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildName() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Name'),
      maxLength: 10,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Name is Required';
        }

        return null;
      },
      onSaved: (String value) {
        _name = value;
      },
    );
  }

  Widget _buildEmail() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Email'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Email is Required';
        }

        if (!RegExp(
                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(value)) {
          return 'Please enter a valid email Address';
        }

        return null;
      },
      onSaved: (String value) {
        _email = value;
      },
    );
  }

  Widget _buildPassword() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Password'),
      keyboardType: TextInputType.visiblePassword,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Password is Required';
        }

        return null;
      },
      onSaved: (String value) {
        _password = value;
      },
    );
  }

  Widget _builURL() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Url'),
      keyboardType: TextInputType.url,
      validator: (String value) {
        if (value.isEmpty) {
          return 'URL is Required';
        }

        return null;
      },
      onSaved: (String value) {
        _url = value;
      },
    );
  }

  Widget _buildPhoneNumber() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Phone number'),
      keyboardType: TextInputType.phone,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Phone number is Required';
        }

        return null;
      },
      onSaved: (String value) {
        _url = value;
      },
    );
  }

  Widget _buildCalories() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Calories'),
      keyboardType: TextInputType.number,
      validator: (String value) {
        int calories = int.tryParse(value);

        if (calories == null || calories <= 0) {
          return 'Calories must be greater than 0';
        }

        return null;
      },
      onSaved: (String value) {
        _calories = value;
      },
    );
  }

  /* Widget _buildDropdown() {
    return DropdownButton<String>(
        items: _dropitems.map((String val) {
          return DropdownMenuItem<String>(
            value: val,
            child: new Text(val),
          );
        }).toList(),
        hint: Text(_selectedType),
        onChanged: (String val) {
          _selectedType = val;
          setState(() {});
        });
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Form Demo")),
      body: Container(
        margin: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildName(),
              _buildEmail(),
              _buildPassword(),
              _builURL(),
              _buildPhoneNumber(),
              _buildCalories(),
              // _buildDropdown(),
              SizedBox(height: 100),
              RaisedButton(
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                onPressed: () {
                  if (!_formKey.currentState.validate()) {
                    return;
                  }

                  _formKey.currentState.save();

                  print(_name);
                  print(_email);
                  print(_phoneNumber);
                  print(_url);
                  print(_password);
                  print(_calories);

                  print("Data sent");

                  checkIfSuccess(context);

                  //Send to API
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

checkIfSuccess(BuildContext context) async {
  var value = await sendData();

  if (value == true) {
    showSimpleFlushbarSuccess(context);
  } else {
    showSimpleFlushbarError(context);
  }

  print('value of send data is: ' + value.toString());
}

Future<bool> sendData() async {
  bool success;
  Socket socket;
  try {
    socket =
        await Socket.connect('77.68.122.181', 80).timeout(Duration(seconds: 5));
    print('connected');

    // listen to the received data event stream
    socket.listen((List<int> event) {
      //print(utf8.decode(event));
      print('received from JAVA server is: ' + utf8.decode(event));
      id = utf8.decode(event);
      if (id.length > 0) {
        success = true;
      } else {
        success = false;
      }
    });

    // send hello
    socket.add(utf8.encode('CREATE,' + 'testdata' + '\n'));

    print('sending to server');

    // wait 5 seconds
    await Future.delayed(Duration(seconds: 5));

    // .. and close the socket
    socket.close();
  } on Exception {
    print('Exception when trying to connect to socket');
    success = false;
  }

  return Future.value(success);
}

void showSimpleFlushbarSuccess(BuildContext context) {
  Flushbar(
    message: 'Your entry was a success!!',
    mainButton: FlatButton(
      child: Text(
        'ok',
      ),
      onPressed: () {},
    ),
    duration: Duration(seconds: 15),
    backgroundColor: Colors.green,
  )..show(context);
}

void showSimpleFlushbarError(BuildContext context) {
  Flushbar(
    message: 'Your entry was not successfull, please try again',
    mainButton: FlatButton(
      child: Text(
        'ok',
      ),
      onPressed: () {},
    ),
    duration: Duration(seconds: 15),
    backgroundColor: Colors.red,
  )..show(context);
}
