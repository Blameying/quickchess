import "package:flutter/material.dart";
import "package:quickchess/painter/boardPainter.dart";
import 'dart:async';
import 'package:quickchess/model/config.dart';
import 'package:quickchess/model/chessboard.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';

class ChessPage extends StatefulWidget{
  final String token;
  final String roomId;
  final int charactor;

  ChessPage(this.token,this.roomId,this.charactor);

  @override
  _ChessPageState createState()=>new _ChessPageState(token,roomId,charactor);
}

class _ChessPageState extends State<ChessPage>{
  final String token;
  final String roomId;
  final int charactor;
  bool actionStatus=false;
  ChessBoard chessInfo;
  Timer timer;
  List event=[];
  List currentPoint=[];
  List array=new List(15*15);

  Future<bool> fromEventToArray() async {
    for(var item in chessInfo.events){
      if(item[0]==Config.player_1){
        array[item[1]+item[2]*15]='@';
      }else if(item[0]==Config.player_2){
        array[item[1]+item[2]*15]='#';
      }
    }
    return true;
  }
  _ChessPageState(this.token,this.roomId,this.charactor);
  @override
  void initState(){
    super.initState();
    if(charactor==Config.player_1){
      actionStatus=true;
    }
    timer = new Timer.periodic(new Duration(milliseconds: 300), (Timer t) async {
      //try{
      chessInfo = await Config.getGameInfo(token, roomId);
      if(chessInfo.events.length>event.length){
        await fromEventToArray();
        setState(() {
          event=new List.from(chessInfo.events);
          if(charactor!=Config.visitor && event.isNotEmpty && event.last[0]!=charactor){
            actionStatus = true;
          }else{
            actionStatus = false;
          }
        });
      }
      //}catch(e){
      //  print(e);
      //}
    });
  }

  @override


  Size _sizecal(BuildContext context){
    var size = MediaQuery.of(context).size;
    var value = size.width<size.height? size.width:size.height;
    return Size(value,value);
  }

  Widget build(BuildContext context){
    if(!timer.isActive){

    }
    return new Material(
      child: new Container(
        color: Color.fromARGB(255, 234, 230, 230),
        child: new Column(
          children: <Widget>[
            new SizedBox(
                width: double.infinity,
                height: 50,
                child: new Container(
                  color: Color.fromARGB(255, 164, 137, 137),
                  child: new Row(
                    children: <Widget>[
                      new GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          timer.cancel();
                        },
                        child: new Image.asset(
                          "images/箭头.png",
                          width: 30,
                          fit: BoxFit.fill,
                        ),
                      ),
                      new Expanded(
                        child: Text(
                          "Chess Rome",
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                )
            ),
            new Expanded(
              child: new Column(
                  children: <Widget>[
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Expanded(
                          child: new Container(
                            height: 80,
                            margin: new EdgeInsets.fromLTRB(0, 0, 30, 0),
                            decoration: new BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                      "images/气泡.png",
                                    ),
                                    fit: BoxFit.fill
                                )
                            ),
                            padding: EdgeInsets.fromLTRB(40, 30, 0, 0),
                            child: new Text(
                              roomId,
                              textDirection: TextDirection.ltr,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        new Expanded(
                          child: new Container(
                            height: 45,
                            decoration: new BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8.0)
                                )
                            ),
                            margin: new EdgeInsets.fromLTRB(30, 0, 20, 0),
                            padding: EdgeInsets.fromLTRB(5, 10, 0, 0),
                            child: new Text(
                              chessInfo==null? "":(chessInfo.players.length+chessInfo.visitors.length).toString(),
                              textDirection: TextDirection.ltr,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        )
                      ],
                    ),
                    new Container(
                        child: new PositionedTapDetector(
                          child: new CustomPaint(
                              painter: new BoardPainter(array,currentPoint,chessInfo),
                              size: _sizecal(context)
                          ),
                          onTap: (position){
                            print("taped");
                            var size = _sizecal(context);
                            var width = size.width>size.height? size.height/16:size.width/16;
                            var x=(position.relative.dx/width+0.5)~/1;
                            var y=(position.relative.dy/width+0.5)~/1;
                            if(actionStatus && array[y*15+x]!='@' && array[y*15+x]!='#'){
                              setState(() {
                                currentPoint=[charactor,x,y];
                                print(currentPoint);
                              });
                            }else{
                              currentPoint=[];
                            }
                          },
                        )
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Expanded(
                          child: new Container(
                            margin: new EdgeInsets.only(left: 30,right: 80),
                            height: 45,
                            decoration: new BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8.0)
                                )
                            ),
                            padding: new EdgeInsets.only(left: 5,top: 10),
                            child: new Text(
                              "信息",
                              textDirection: TextDirection.ltr,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        new Container(
                          margin: new EdgeInsets.only(right: 30),
                          child: new RaisedButton(
                              child: new Text(
                                "确定",
                                textDirection: TextDirection.ltr,
                              ),

                              onPressed: actionStatus? ()async{
                                if(currentPoint.isNotEmpty){
                                  chessInfo=await Config.sendStepData(token, roomId, currentPoint);
                                  setState(() {

                                  });
                                }
                              }:null
                          ) ,
                        )
                      ],
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Container(
                          margin: new EdgeInsets.only(left: 130),
                          child: new RaisedButton(
                              child: new Text(
                                "过手",
                                textDirection: TextDirection.ltr,
                              ),

                              onPressed: actionStatus? ()async{

                                chessInfo=await Config.sendJumpData(token, roomId, currentPoint);
                                setState(() {

                                });


                              }:null
                          ) ,
                        ),
                        new Container(
                          margin: new EdgeInsets.only(right: 30),
                          child: new RaisedButton(
                              child: new Text(
                                "收子",
                                textDirection: TextDirection.ltr,
                              ),

                              onPressed: actionStatus? ()async{

                                chessInfo=await Config.sendCollectData(token, roomId, currentPoint);
                                setState(() {

                                });

                              }:null
                          ) ,
                        )
                      ],
                    ),
                  ]
              ),
            )
          ],
        ),
      ),
    );
  }
}