import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

String id;
String _customerName, customerNameNew;
String _vehicleDetails, vehicleDetailsNew;
String _turboModel, turboModelNew;
String _price, priceNew;
String _payment, paymentNew;
String _fittingRequired, fittingRequiredNew;
String _timeStamp;
String c = ',';
String a = "'";
String fDate, _selectedDatePicked;
bool datePicked = false;

TimeOfDay selectedTime = TimeOfDay.now();

DateTime selectedDate = DateTime.now();

class FormScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormScreenState();
  }
}

class FormScreenState extends State<FormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildName() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Customer Name'),
      maxLength: 25,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Name is Required';
        }

        return null;
      },
      onSaved: (String value) {
        _customerName = value;
      },
    );
  }

  Widget _buildDate() {
    return RaisedButton(
        child: Text(
          'Select date order is due',
          style: TextStyle(color: Colors.blue, fontSize: 16),
        ),
        onPressed: () {
          _selectDate(context);
        });
  }

  Widget _buildVehicleDetails() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Vehilce Details'),
      keyboardType: TextInputType.visiblePassword,
      validator: (String value) {
        if (value.isEmpty) {
          return 'vehicle details are Required';
        }

        return null;
      },
      onSaved: (String value) {
        _vehicleDetails = value;
      },
    );
  }

  Widget _builTurboModel() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Turbo Part Number'),
      keyboardType: TextInputType.url,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Turbo model is required';
        }

        return null;
      },
      onSaved: (String value) {
        _turboModel = value;
      },
    );
  }

  Widget _buildPrice() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Price'),
      keyboardType: TextInputType.phone,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Price is required';
        }

        return null;
      },
      onSaved: (String value) {
        _price = value;
      },
    );
  }

  Widget _buildPayment() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Payment'),
      keyboardType: TextInputType.number,
      validator: (String value) {
        //int calories = int.tryParse(value);

        //if (calories == null || calories <= 0) {
        // return 'Calories must be greater than 0';
        //}

        if (value.isEmpty) {
          return 'payment information is requried';
        }

        return null;
      },
      onSaved: (String value) {
        _payment = value;
      },
    );
  }

  Widget _buildFittingRequired() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Fitting Required'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Fitting required needed';
        }

        return null;
      },
      onSaved: (String value) {
        _fittingRequired = value;
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
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildName(),
                _buildDate(),
                _buildVehicleDetails(),
                _builTurboModel(),
                _buildPrice(),
                _buildPayment(),
                _buildFittingRequired(),
                // _buildDropdown(),
                SizedBox(height: 100),
                RaisedButton(
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                  onPressed: () {
                    if (datePicked) {
                      if (!_formKey.currentState.validate()) {
                        return;
                      }

                      _formKey.currentState.save();

                      print(_customerName);

                      //turboModelNew =
                      //_turboModel.replaceAll(new RegExp(r"\s+"), "");

                      //caloriesNew = _calories.replaceAll(new RegExp(r"\s+"), "");

                      print("Data sent");

                      checkIfSuccess(context);
                    } else {
                      print('date not picked yet');
                      showSimpleFlushbarDateNotPicked(context);
                    }

                    //Send to API
                  },
                )
              ],
            ),
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

  var now = new DateTime.now();
  var formatter = new DateFormat('dd-MM-yyyy HH:mm:ss');
  _timeStamp = formatter.format(now);
  print(_timeStamp); // 2016-01-25

  try {
    socket =
        await Socket.connect('77.68.122.181', 80).timeout(Duration(seconds: 5));
    print('connected');

    // listen to the received data event stream
    socket.listen((List<int> event) {
      //print(utf8.decode(event));
      print('received from JAVA server is: ' + utf8.decode(event));
      id = utf8.decode(event);
      print('ID is: ' + id);
      if (id.length > 0) {
        success = true;
        print('reply received from server');
      } else {
        success = false;
      }
    });

    // send hello
    socket.add(utf8.encode(
        'CREATE,($a$_customerName$a $c $a$fDate$a $c $a$_vehicleDetails$a $c $a$_turboModel$a $c $a$_price$a $c $a$_payment$a' +
            '$c $a$_fittingRequired$a $c $a$_timeStamp$a' +
            ')' +
            '\n'));

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
    message: id,
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

void showSimpleFlushbarDateNotPicked(BuildContext context) {
  Flushbar(
    message: 'You have not selected order due date',
    mainButton: FlatButton(
      child: Text(
        'ok',
      ),
      onPressed: () {},
    ),
    duration: Duration(seconds: 3),
    backgroundColor: Colors.red,
  )..show(context);
}

Future<void> _selectDate(BuildContext context) async {
  final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101));

  if (picked != null && picked != selectedDate) {
    print(picked.toString());
    datePicked = true;
    var now1 = new DateTime.now();
    var formatter1 = new DateFormat('dd-MM-yyyy');

    fDate = formatter1.format(picked);
  }
}
