import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_cars/Home.dart';
import 'package:flutter_app_cars/UserState.dart';


class Reservation extends StatefulWidget {
  static final ROUTER = '/Reservation';
  @override
  _ReservationState createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {

  CollectionReference userState = FirebaseFirestore.instance.collection('userState');
  CollectionReference parkingLots = FirebaseFirestore.instance.collection('parkingLot');
  String _timeHire, _errorTime;
  int dayReturn, hourReturn, minuteReturn, hireTime;
  bool _error = false;
  var allPoints = {};
  DateTime time = DateTime.now();
  String point;
  final FirebaseAuth user = FirebaseAuth.instance;
  Widget richText(String text1, String text3) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: RichText(
        text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: text1, style: TextStyle(fontSize: 21, color: Colors.black)),
              TextSpan(text: text3, style: TextStyle(fontSize: 21, color: Colors.black)),
            ]
        ),
      ),
    );
  }
  Widget richText2(String text1, int num1, int num2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: RichText(
        text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: text1, style: TextStyle(fontSize: 21, color: Colors.black)),
              TextSpan(text: '$num1 giờ ', style: TextStyle(fontSize: 21, color: Colors.black)),
              TextSpan(text: '$num2 phút', style: TextStyle(fontSize: 21, color: Colors.black)),
            ]
        ),
      ),
    );
  }
   cancelPoint ()async {
      try{
        allPoints.forEach((key, value) {
          if(key == point){
            allPoints[key] = false;
            print(key);
          }
        });
        final value = await userState
        .doc(user.currentUser.uid)
        .get();
        parkingLots
        .doc(value['idParkingLot'])
        .update({
          'allPoints' : allPoints
        }).then((value2){
          userState
          .doc(user.currentUser.uid)
              .delete().then((_) =>
              Navigator.pushNamed(context, Home.ROUTER));
        });
      } catch (e){
        print('Error: $e');
      }
  }

  Future<void> hirePoint () async {
    try{
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Điền thời gian thuê (giờ)'),
            content: SingleChildScrollView(
                child: TextField(
                  onChanged: (number){
                    _timeHire = number;
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(fontSize: 21),
                  decoration: InputDecoration(
                    errorText: _error ? _errorTime : null,
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
                onPressed: fillTime,
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> fillTime() async {
    try {
      hireTime = int.parse(_timeHire);
      await countTime();
      userState
          .doc(user.currentUser.uid)
          .update({
        'distantTime' : int.parse(_timeHire),
        'rentTime' : {
          'day' : time.day,
          'hour' : time.hour,
          'minute' : time.minute
        },
        'returnTime' : {
          'day' : dayReturn,
          'hour' : hourReturn,
          'minute' : minuteReturn
        }
      }).then((value) => Navigator.pushNamed(context, UserHired.ROUTER));
    } catch (e) {
      _errorTime = 'Please enter number';
      setState(() {
        _error = true;
      });
      print(e);
    }
  }
  countTime(){
    minuteReturn = time.minute;
    if ((time.hour + hireTime) >= 24){
      hourReturn = (time.hour + hireTime) % 24;
      dayReturn = time.day + ((time.hour + hireTime) ~/ 24);
    } else {
      hourReturn = time.hour + hireTime;
      dayReturn = time.day;
    }
  }

  @override
  void initState() {
    getInfor();
    super.initState();
  }

  getInfor(){
    userState
        .doc(user.currentUser.uid)
        .get()
        .then((value){
      parkingLots
          .doc(value.data()['idParkingLot'])
          .get()
          .then((value2){
        allPoints = value2.data()['allPoints'];
        print('all Point2: $allPoints');
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: userState.doc(user.currentUser.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data.data();
          point = data['vị trí'];
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text('Reservation'),
              leading: IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.pushNamed(context, Home.ROUTER);
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  richText('Name: ', data['nameUser']),
                  richText('Bãi Đỗ: ', data['nameParkingLot']),
                  richText('Địa chỉ: ', data['addressPL']),
                  richText('Vị trí đỗ: ', data['vị trí']),
                  richText('SĐT bãi đỗ: ', data['phonePL'].toString()),
                  richText2('Thời gian bắt đầu đặt: ', data['reserveTime']['hour'], data['reserveTime']['minute']),
                  richText2('Thời gian hủy chỗ: ', data['cancelTime']['hour'], data['cancelTime']['minute']),
                  Padding(
                    padding: const EdgeInsets.only(top: 70, left: 70),
                    child: Row(
                      children: [
                        RaisedButton(
                          color: Colors.green,
                          onPressed: cancelPoint,
                          child: Text(
                              'Hủy chỗ'
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: RaisedButton(
                            color: Colors.green,
                            onPressed: hirePoint,
                            child: Text(
                                'Thuê chỗ'
                            ),
                          ),
                        )
                      ],
                    ),
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
      },
    );
  }
}
