import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_cars/Reservation.dart';
import 'package:flutter_app_cars/addParkingLots.dart';
import 'UserState.dart';


class Points extends StatefulWidget {
  static final ROUTER = '/Points';
  final String documentId;
  Points({this.documentId});
  @override
  _PointsState createState() => _PointsState(documentId: documentId);
}

class _PointsState extends State<Points> {
  var addParkingLot = AddParkingLots();
  final FirebaseAuth user = FirebaseAuth.instance;
  CollectionReference parkingLots = FirebaseFirestore.instance.collection('parkingLot');
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference userState = FirebaseFirestore.instance.collection('userState');
  final String documentId;
  String nameUser, namePL, namePoint, addressPL, phonePL;
  int hourCancel, minuteCancel, dayCancel;
  final DateTime time = DateTime.now();
  _PointsState({this.documentId});
  List<String> points = [];
  Map<dynamic, dynamic> allPoints = {};
  Map<dynamic, dynamic> allPointsCheck = {};

  Future<void> _choosePoint(String name) async {
    try {
      if((time.minute + 30) >= 60){
        minuteCancel = time.minute - 60 + 30;
        if ((time.hour + 1) >= 24){
          hourCancel = time.hour + 1 -24;
          dayCancel = time.day + 1;
        } else {
          hourCancel = time.hour + 1;
          dayCancel = time.day ;
        }
      } else {
        minuteCancel = time.minute +30;
        hourCancel = time.hour;
        dayCancel = time.day;
      }
      print(allPoints);
      print(name);
      allPoints.forEach((key, value) {
        print(key);
        if(key == name){
          allPoints[key] = true;
          print(key);
        }
      });
      parkingLots
          .doc(documentId)
          .update({
        'allPoints' : allPoints
      });
      userState
          .doc(user.currentUser.uid)
          .set({
        'idUser' : user.currentUser.uid
      }).then((value){
        userState
            .doc(user.currentUser.uid)
            .update({
          'addressPL' : addressPL,
          'nameUser' : nameUser,
          'idParkingLot' : documentId,
          'nameParkingLot' : namePL,
          'phonePL' : phonePL,
          'vị trí' : name,
          'reserveTime' : {
            'day' : time.day,
            'hour' : time.hour,
            'minute' : time.minute
          },
          'cancelTime' : {
            'day' : dayCancel,
            'hour' : hourCancel,
            'minute' : minuteCancel
          }
        }).then((value){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Reservation())
          );
        });
      });
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> _checkUserState(String name) async {
    await addParkingLot.deleteReservation();
    userState
    .doc(user.currentUser.uid)
        .get()
        .then((value){
       if(value.data() == null) {
         _choosePoint(name);
       } else {
         if (value.data()['rentTime'] == null){
           return showDialog<void>(
             context: context,
             barrierDismissible: false, // user must tap button!
             builder: (BuildContext context) {
               return AlertDialog(
                 title: Text('Announce'),
                 content: SingleChildScrollView(
                     child: Text('Sorry! You booked.')
                 ),
                 actions: <Widget>[
                   RaisedButton(
                     color: Colors.green,
                     child: Text('ok'),
                     onPressed: () {
                       Navigator.pushNamed(context, Reservation.ROUTER);
                     },
                   ),
                 ],
               );
             },
           );
         } else {
           return showDialog<void>(
             context: context,
             barrierDismissible: false, // user must tap button!
             builder: (BuildContext context) {
               return AlertDialog(
                 title: Text('Announce'),
                 content: SingleChildScrollView(
                     child: Text('Sorry! You hired another point.')
                 ),
                 actions: <Widget>[
                   RaisedButton(
                     color: Colors.green,
                     child: Text('ok'),
                     onPressed: () {
                       Navigator.pushNamed(context, UserHired.ROUTER);
                     },
                   ),
                 ],
               );
             },
           );
         }
       }
    });
  }
  Future<void> _checkParkingLot(String name) async{
    parkingLots
    .doc(documentId)
        .get()
        .then((value){
          allPointsCheck = value.data()['allPoints'];
          if(allPointsCheck[name] == false){
            _checkUserState(name);
          } else {
            return showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Announce'),
                  content: SingleChildScrollView(
                      child: Text('Sorry! This point has been hired.')
                  ),
                  actions: <Widget>[
                    RaisedButton(
                      color: Colors.green,
                      child: Text('ok'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Points(
                            documentId: documentId,
                          ))
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }
    });
  }
  @override
  void initState() {
    getInfor();
    super.initState();
  }
  getInfor(){
    users
        .doc(user.currentUser.uid)
        .get()
        .then((value){
      nameUser = value.data()['name'];
    });
    parkingLots
        .doc(documentId)
        .get()
        .then((valuePL){
      namePL = valuePL.data()['namePL'];
      addressPL = valuePL.data()['address'];
      phonePL = valuePL.data()['numberPhone'].toString();
      allPoints = valuePL.data()['allPoints'];
    });
  }




  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: parkingLots.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data.data()['allPoints'];
          data.forEach((key, value) {
            print(value);
            if(value == false){
              points.add(key);
              print(key);
            }
          });
          if (points.length == 0){
            return Scaffold(
              appBar: AppBar(
                title: Text('Wrong'),
                actions: [
                  IconButton(
                    onPressed: (){
                      print(allPoints);
                    },
                    icon: Icon(Icons.search)
                  )
                ],
              ),
              body: Center(
                child: Text(
                  'Sorry , this parking lot hasn\'t now any point.',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 21),
                ),
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text('point'),
              ),
              body: ListView.builder(
                  itemCount: points.length,
                  itemBuilder: (BuildContext context, int index){
                    return Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: RaisedButton(
                        onPressed: (){
                          return showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Announce'),
                                content: SingleChildScrollView(
                                    child: Text('Do you want to get ${points[index]} point?')
                                ),
                                actions: <Widget>[
                                  RaisedButton(
                                    color: Colors.blue,
                                    onPressed: (){
                                      Navigator.pop(context);
                                    },
                                    child: Text('No'),
                                  ),
                                  RaisedButton(
                                    color: Colors.yellow,
                                    child: Text('Yes'),
                                    onPressed: (){
                                      _checkParkingLot(points[index]);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          points[index],
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  }
              ),
            );
          }
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
