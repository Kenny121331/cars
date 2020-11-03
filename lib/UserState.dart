import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_cars/Home.dart';
import 'package:flutter_app_cars/bill.dart';


class UserHired extends StatefulWidget {
  static final ROUTER = '/UserHird';
  @override
  _UserHiredState createState() => _UserHiredState();
}

class _UserHiredState extends State<UserHired> {
  String _email = '';
  CollectionReference userState = FirebaseFirestore.instance.collection('userState');
  final FirebaseAuth user = FirebaseAuth.instance;
  DateTime time = DateTime.now();
  int _addTime;
  String _newReturnDay, _newReturnHour, _newReturnMinute;
  Widget richText2(String text1, String text2) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: RichText(
        text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: text1, style: TextStyle(fontSize: 21, color: Colors.black)),
              TextSpan(text: text2, style: TextStyle(fontSize: 21, color: Colors.black)),
            ]
        ),
      ),
    );
  }
  Widget richText5(String text1, int num1, int num2, String text2, int num3) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: RichText(
        text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: text1, style: TextStyle(fontSize: 21, color: Colors.black)),
              TextSpan(text: '$num1:$num2  ', style: TextStyle(fontSize: 21, color: Colors.black)),
              TextSpan(text: text2, style: TextStyle(fontSize: 21, color: Colors.black)),
              TextSpan(text: '$num3', style: TextStyle(fontSize: 21, color: Colors.black)),
            ]
        ),
      ),
    );
  }
  Widget text(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: TextStyle(fontSize: 21),
      ),
    );
  }
  @override
  void initState() {
    _getInfor();
    super.initState();
  }
  _getInfor(){
    if (user.currentUser.email != null){
      setState(() {
        _email = user.currentUser.email;
      });
    }
  }
  _checkAddtime() async {
    userState
    .doc(user.currentUser.uid)
        .get()
        .then((value){
          print(value.data()['returnTime']['day'] < time.day);
       if (value.data()['returnTime']['day'] > time.day){
         _resultSuccess();
       } else {
         print(value.data()['returnTime']['hour'] > time.hour);
         print(value.data()['returnTime']['hour']);
         print(time.hour);
         if (value.data()['returnTime']['hour'] > time.hour){
           _resultSuccess();
         } else {
           if (value.data()['returnTime']['minute'] >= time.minute) {
             _resultSuccess();
           } else {
             _resultFaile();
           }
         }
       }
    });
  }
  _resultFaile() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Announce'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Sorry, you can\'t because it is overdue')
              ],
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              color: Colors.green,
              child: Text('ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
  _resultSuccess() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Fill distance time (hours)'),
          content: SingleChildScrollView(
            child: TextField(
              onChanged: (number){
                _addTime = int.parse(number);
              },
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(fontSize: 21),
              decoration: InputDecoration(
                  //errorText: _error ? _errorTime : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                          Radius.circular(20)
                      )
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(20)
                    ),
                  )
              ),
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              color: Colors.blue,
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            RaisedButton(
              color: Colors.yellow,
              child: Text('Apply'),
              onPressed: (){
                _saveTime();
              },
            ),
          ],
        );
      },
    );
  }
  _saveTime() async {
    userState
    .doc(user.currentUser.uid)
        .get()
        .then((value){
          _newReturnMinute = value.data()['returnTime']['minute'];
          if ((value.data()['returnTime']['hour'] + _addTime) >= 24){
            _newReturnDay = value.data()['returnTime']['day'] + ((value.data()['returnTime']['hour'] + _addTime) ~/ 24);
            _newReturnHour = (value.data()['returnTime']['hour'] + _addTime) % 24;
          } else {
            _newReturnDay = value.data()['returnTime']['day'];
            _newReturnHour = value.data()['returnTime']['hour'] + _addTime;
          }
    }).then((value2){
      userState
      .doc(user.currentUser.uid)
          .update({
        'returnTime' : {
          'day' : _newReturnDay,
          'hour' : _newReturnHour,
          'minute' : _newReturnMinute
        }
      }).then((value){
        Navigator.pushNamed(context, UserHired.ROUTER);
      });
    })
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My state'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () => Navigator.pushNamed(context, Home.ROUTER),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
          future: userState.doc(user.currentUser.uid).get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }
            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data = snapshot.data.data();
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: ListView(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          text(data['nameUser']),
                          text(_email),
                          richText2('Tên bãi đỗ : ', data['nameParkingLot']),
                          richText2('Địa chỉ: ', data['addressPL']),
                          richText2('Vị trí đỗ: ', data['vị trí']),
                          richText5('Thời gian thuê: ', data['rentTime']['hour'], data['rentTime']['minute'], 'Ngày: ', data['rentTime']['day']),
                          richText5('Thời hạn nhận xe: ', data['returnTime']['hour'], data['returnTime']['minute'], 'Ngày: ', data['returnTime']['day']),
                          Padding(
                            padding: const EdgeInsets.only(top: 100),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                RaisedButton(
                                  color: Colors.green,
                                  onPressed: () => Navigator.pushNamed(context, Bill.ROUTER),
                                  child: Text(
                                    'Get bill',
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: RaisedButton(
                                    color: Colors.green,
                                    onPressed: (){
                                      _checkAddtime();
                                    },
                                    child: Text(
                                      'Add time',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            }
            return Scaffold(
              body: Center(
                child: Text("loading", style: TextStyle(color: Colors.red, fontSize: 30),),
              ),
            );
          }
      ),
    );
  }
}



