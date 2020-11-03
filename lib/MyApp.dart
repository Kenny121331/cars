import 'package:flutter/material.dart';
import 'file:///D:/AndroidStudioProjects/flutter_app_cars/lib/InformationUser/ChangeInfor.dart';
import 'file:///D:/AndroidStudioProjects/flutter_app_cars/lib/InformationUser/ChangePassword.dart';
import 'package:flutter_app_cars/DetailsPL.dart';
import 'package:flutter_app_cars/GetPassword.dart';
import 'package:flutter_app_cars/Home.dart';
import 'package:flutter_app_cars/Login.dart';
import 'package:flutter_app_cars/Register.dart';
import 'package:flutter_app_cars/Reservation.dart';
import 'package:flutter_app_cars/Splash.dart';
import 'package:flutter_app_cars/UserState.dart';
import 'package:flutter_app_cars/addParkingLots.dart';
import 'package:flutter_app_cars/bill.dart';
import 'package:flutter_app_cars/choosePoint.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        Login.ROUTER: (context) => Login(),
        Register.ROUTER: (context) => Register(),
        SplashScreen.ROUTER: (context) => SplashScreen(),
        ChangeInfor.ROUTER: (context) => ChangeInfor(),
        Home.ROUTER: (context) => Home(),
        GetPassword.ROUTER: (context) => GetPassword(),
        ChangePassword.ROUTER: (context) => ChangePassword(),
        Reservation.ROUTER: (context) => Reservation(),
        Details.ROUTER: (context) => Details(),
        UserHired.ROUTER: (context) => UserHired(),
        Bill.ROUTER: (context) => Bill(),
        Points.ROUTER: (context) => Points(),
        AllParkingLots.ROUTER: (context) => AllParkingLots()
      },
      home: Login(),
    );
  }
}
