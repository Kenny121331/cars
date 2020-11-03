import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_cars/Home.dart';


class Bill extends StatefulWidget {
  static final ROUTER = '/Bill';
  @override
  _BillState createState() => _BillState();
}

class _BillState extends State<Bill> {

  CollectionReference userState = FirebaseFirestore.instance.collection('userState');
  CollectionReference parkingLots = FirebaseFirestore.instance.collection('parkingLot');
  final FirebaseAuth user = FirebaseAuth.instance;
  int _penaltyMoney,_payMoney, _overdueFinePrice, _totalPenaltyMoney;
  int _overdueHour, _overdueMinute;
  var _allPoints = {};
  Widget richText(String text1, String text2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
      padding: const EdgeInsets.only(bottom: 10),
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
  Widget richText3(String text1, int num1,String num2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: text1, style: TextStyle(fontSize: 21, color: Colors.black)),
              TextSpan(text: '$num1 giờ ', style: TextStyle(fontSize: 21, color: Colors.black)),
              TextSpan(text: '$num2 giút ', style: TextStyle(fontSize: 21, color: Colors.black)),
            ]
        ),
      ),
    );
  }
  Widget _penaltyText(int num1, int num2, int num3, int num4) {
    if (_overdueMinute == null){
      return Container();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          richText3('Bạn đã quá hạn: ', num1, num2.toString() ),
          richText('Tiền phạt quá hạn: ', '$num3 nghìn'),
          richText('Tổng số tiền: ', '$num4 nghìn')
        ],
      );
    }
  }
  DateTime time = DateTime.now();
  _countMoney(){
    userState
        .doc(user.currentUser.uid)
        .get()
        .then((value){
      parkingLots
          .doc(value.data()['idParkingLot'])
          .get()
          .then((valuePL){
        setState(() {
          _payMoney = valuePL.data()['Giá một giờ thuê'] * value.data()['distantTime'];
        });
        _penaltyMoney = valuePL.data()['Giá phạt quá hạn'];
        print(valuePL.data()['Giá phạt quá hạn']);
        print(valuePL.data()['Giá một giờ thuê']);
        print(_penaltyMoney);
      }).then((value2){
        print(_penaltyMoney);
        if(time.day > value.data()['returnTime']['day']){
          _countPenaltyOverdueDay(
              value.data()['returnTime']['day'],
              value.data()['returnTime']['hour'],
              value.data()['returnTime']['minute'],
              _penaltyMoney
          );
        } else if(time.day == value.data()['returnTime']['day']) {
          print(time.hour > value.data()['returnTime']['hour']);
          if (time.hour > value.data()['returnTime']['hour']){
            print(_penaltyMoney?? 'no value hour');
            _countPenaltyOverdueHour(
                value.data()['returnTime']['hour'],
                value.data()['returnTime']['minute'],
                _penaltyMoney
            );
          } else if (time.hour == value.data()['returnTime']['hour']) {
            //print(time.hour > value.data()['returnTime']['hour']);
            //print(time.minute > (value.data()['returnTime']['minute'] + 10));
            if (time.minute > (value.data()['returnTime']['minute'] + 10)){
              _countPenaltyOverdueMinute(
                  value.data()['returnTime']['minute'],
                  _penaltyMoney
              );
            } else {
              print('ok');
            }
          }
        }
      });
      //print(value.data()['returnTime']['day']);
      print(time.day > value.data()['returnTime']['day']);

    });
  }
  _countPenaltyOverdueDay(int returnDay, int returnHour, int returnMinute, int penaltyPrice){
    if (time.hour > returnHour){
      if(time.minute > returnMinute){
        setState(() {
          _overdueHour = (time.day - returnDay) * 24 + (time.hour - returnHour);
          _overdueMinute = (time.minute - returnMinute);
          _totalPenaltyMoney = (_overdueHour + ((_overdueMinute >= 10)? 1 :0)) * penaltyPrice;
          _overdueFinePrice = _totalPenaltyMoney + _payMoney;
        });
      } else {
        setState(() {
          _overdueHour = (time.day - returnDay) * 24 + (time.hour - returnHour) - 1 ;
          _overdueMinute = time.minute + 60 - returnMinute;
          _totalPenaltyMoney = (_overdueHour + ((_overdueMinute >= 10)? 1 :0)) * penaltyPrice;
          _overdueFinePrice = _totalPenaltyMoney + _payMoney;
        });
      }
    } else {
      setState(() {
        _overdueHour = (time.day - returnDay) * 24 + (time.hour - returnHour);
        _overdueMinute = time.minute - returnMinute;
        _totalPenaltyMoney = (_overdueHour + ((_overdueMinute >= 10)? 1 :0)) * penaltyPrice;
        _overdueFinePrice = _totalPenaltyMoney + _payMoney;
      });
    }
  }
  _countPenaltyOverdueHour(int returnHour, int returnMinute, int penaltyPrice){
    if (time.minute > returnMinute){
      setState(() {
        _overdueHour = time.hour - returnHour;
        _overdueMinute = time.minute - returnMinute;
        _totalPenaltyMoney = (_overdueHour + ((_overdueMinute >= 10) ? 1 : 0))*_penaltyMoney;
        _overdueFinePrice = _totalPenaltyMoney + _payMoney;
      });
    } else {
      setState(() {
        _overdueHour = time.hour - returnHour - 1;
        _overdueMinute = time.minute + 60 - returnMinute;
        _totalPenaltyMoney = (_overdueHour + ((_overdueMinute >= 10)? 1 :0)) * penaltyPrice;
        _overdueFinePrice = _totalPenaltyMoney + _payMoney;
      });
    }
  }
  _countPenaltyOverdueMinute(int returnMinute, int penaltyPrice){
    setState(() {
      _overdueHour = 0;
      _overdueMinute = time.minute - returnMinute;
      _totalPenaltyMoney = ((_overdueMinute >= 10) ? 1 :0) * penaltyPrice;
      _overdueFinePrice = _totalPenaltyMoney + _payMoney;
    });
  }

  @override
  void initState() {
    _countMoney();
    _addAllPoint();
    super.initState();
  }
  _addAllPoint(){
    userState
    .doc(user.currentUser.uid)
        .get()
        .then((value){
       parkingLots
       .doc(value.data()['idParkingLot'])
           .get()
           .then((valuePL){
             _allPoints = valuePL.data()['allPoints'];
       });
    });
  }

  _makePayment() async {
    userState
        .doc(user.currentUser.uid)
        .get()
        .then((value){
          _allPoints.forEach((key, valuePoint) {
            if (key == value.data()['vị trí']){
              _allPoints[key] = false;
            }
          });
          parkingLots
          .doc(value.data()['idParkingLot'])
          .update({
            'allPoints' : _allPoints
          }).then((value){
            userState.doc(user.currentUser.uid).delete().then((value){
              return showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Announce'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('Thank you for using our service')
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      RaisedButton(
                        color: Colors.green,
                        child: Text('Yes'),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil( Home.ROUTER, (Route<dynamic> route) => false);
                        },
                      ),
                    ],
                  );
                },
              );
            });
          })
          ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: userState.doc(user.currentUser.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data.data();
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(child: Text('Bill', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.blue),)),
                      richText('Tên khách hàng: ', data['nameUser']),
                      richText('Tên bãi đỗ: ', data['nameParkingLot']),
                      richText('Vị trí: ', data['vị trí']),
                      richText('Địa chỉ bãi đỗ: ', data['addressPL']),
                      richText('SĐT bãi đỗ: ', data['phonePL'].toString()),
                      richText5('Giờ đặt trước: ', data['reserveTime']['hour'], data['reserveTime']['minute'], 'Ngày: ', data['reserveTime']['day']),
                      richText5('Giờ thuê: ', data['rentTime']['hour'], data['rentTime']['minute'], 'Ngày: ', data['rentTime']['day']),
                      richText5('Hạn để xe: ', data['returnTime']['hour'], data['returnTime']['minute'], 'Ngày: ', data['returnTime']['day']),
                      richText5('Giờ nhận xe: ', time.hour, time.minute, 'Ngày: ', time.day),
                      richText('Tiền thuê xe: ', '$_payMoney nghìn'),
                      _penaltyText(_overdueHour, _overdueMinute, _totalPenaltyMoney, _overdueFinePrice),
                      Center(
                        child: RaisedButton(
                          color: Colors.green,
                          onPressed: (){
                            _makePayment();
                          },
                          child: Text(
                              'Make payment'
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          }
          return Text('Loading');
        }
        ,
      ),
    );
  }
}

