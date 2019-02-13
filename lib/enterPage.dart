import 'package:flutter/material.dart';
import 'package:quickchess/homeIdDialog.dart';
import 'package:quickchess/chessPage.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:async';
import 'package:quickchess/model/config.dart';
import 'package:fluttertoast/fluttertoast.dart';


class EnterPage extends StatefulWidget{
  @override
  _EnterPageState createState() => new _EnterPageState();
}

class _EnterPageState extends State<EnterPage>{
  String mac_address="";
  String token="";
  Timer timer;

  @override
  void initState(){
    super.initState();
    timer = new Timer.periodic(new Duration(milliseconds: 300), (Timer t) async {
      if(mac_address.isEmpty){
        mac_address= await Config.getDeviceId();
      }else if(token.isEmpty){
        token = await Config.getToken(mac_address);
        setState(() {
        });
      }else{
        Config.keepAlive(token);
      }
    });
  }

  @override
  Widget build(BuildContext context){

    return new Material(
      color: Color.fromARGB(255, 255, 252, 252),
      child: new Column(
        children: <Widget>[
          new Container(
            padding: new EdgeInsets.symmetric(vertical: 120),
            child: new Column(
              children: <Widget>[
                new Text(
                  "Quick",
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:70,
                    color: Color.fromARGB(255, 200, 126, 126),
                    fontFamily: "times"
                  ),
                ),
                new Text(
                  "Chess",
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:70,
                    color: Color.fromARGB(255, 200, 126, 126),
                    fontFamily: "times"
                  ),
                ),
              ],
            ),          
          ),
          new Container(
            padding: new EdgeInsets.fromLTRB(0, 40, 0, 0),
            child: new Column(
              children: <Widget>[
                new RaisedButton(
                  child: Text("加入"),
                  onPressed: (){
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context){
                        return new HomeIdDialog(
                          text:"请输入房间号:",
                          token: token,
                        );
                      }
                    );
                    },
                  color: Color.fromARGB(255, 255, 255, 255),
                  highlightColor: Color.fromARGB(255, 255, 110, 151),
                  shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))
                  )
                ),   
                new RaisedButton(
                  child: Text("创建"),
                  onPressed: () async {
                    var roomId = await Config.createRoom(token);
                    if(roomId.isNotEmpty){
                        timer.cancel();
                        Navigator.push(
                        context, 
                        new MaterialPageRoute(
                          builder: (context) => new ChessPage(token,roomId,Config.player_1)
                        )
                      );
                    }else{
                      Fluttertoast.showToast(
                          msg: "请求失败，请检查网络",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIos: 1,
                          backgroundColor: Colors.lightBlue,
                          textColor: Colors.black
                        );
                    }
                  },
                  color: Color.fromARGB(255, 255, 255, 255),
                  highlightColor: Color.fromARGB(255, 255, 110, 151),
                  shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))
                  )
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
} 
