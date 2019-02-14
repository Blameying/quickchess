import "package:flutter/material.dart";
import 'package:flutter/foundation.dart';
import "package:quickchess/painter/boardPainter.dart";
import 'dart:async';
import 'dart:core';
import 'package:quickchess/model/config.dart';
import 'package:quickchess/model/chessboard.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';



String judgeResult(List params){
  List array = params[0];
  int x=params[1];
  int y=params[2];

  int count=0;
  for(int i=x;i>=0;i--){
    if(array[15*y+x]==array[15*y+i]){
      count++;
    }else{
      break;
    }
  }
  count-=1;
  for(int i=x;i<15;i++){
    if(array[15*y+x]==array[15*y+i]){
      count++;
    }else{
      break;
    }
  }
  if(count>=5){
    return array[y*15+x];
  }

  count=0;
  for(int j=y;j>=0;j--){
    if(array[j*15+x]==array[y*15+x]){
      count++;
    }else{
      break;
    }
  }
  count-=1;
  for(int j=y;j<15;j++){
    if(array[j*15+x]==array[y*15+x]){
      count++;
    }else{
      break;
    }
  }
  if(count>=5){
    return array[y*15+x];
  }

  count=0;
  for(int i=x,j=y;i>=0&&j>=0;i--,j--){
    if(array[j*15+i]==array[y*15+x]){
      count++;
    }else{
      break;
    }
  }
  count-=1;
  for(int i=x,j=y;i<15&&j<15;i++,j++){
    if(array[j*15+i]==array[y*15+x]){
      count++;
    }else{
      break;
    }
  }
  if(count>=5){
    return array[y*15+x];
  }

  count=0;
  for(int i=x,j=y;i>=0&&j<15;i--,j++){
    if(array[j*15+i]==array[y*15+x]){
      count++;
    }else{
      break;
    }
  }
  count-=1;
  for(int i=x,j=y;i<15&&j>=0;i++,j--){
    if(array[j*15+i]==array[y*15+x]){
      count++;
    }else{
      break;
    }
  }
  if(count>=5){
    return array[y*15+x];
  }

  return "";
  
}


class ChessPage extends StatefulWidget{
  final String token;
  final String roomId;

  ChessPage(this.token,this.roomId);

  @override
  _ChessPageState createState()=>new _ChessPageState(token,roomId);
}

class _ChessPageState extends State<ChessPage>{
  final String token;
  final String roomId;
  int charactor;
  int numberOfPeople = 0;
  bool actionStatus=false;
  ChessBoard chessInfo;
  Timer timer;
  List event=[];
  List currentPoint=[];
  List array=new List(15*15);

  void calculator() async {
    String result = await compute(judgeResult,[array,chessInfo.events.last[1],chessInfo.events.last[2]]);
    if(result.isNotEmpty){
      if(result=='@'){
        Fluttertoast.showToast(
            msg: "执黑者 胜",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white
          );
      }else if(result=='#'){
        Fluttertoast.showToast(
            msg: "执白者 胜",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white
          );
      }
    }
  }

  int changeCharactor(){
    int index = chessInfo.players.indexOf(token);
    if(index==0){
      return Config.player_1;
    }else if(index==1){
      return Config.player_2;
    }else{
      index=chessInfo.visitors.indexOf(token);
      if(index!=-1){
        return Config.visitor;
      }
    }

    return Config.empty;
  }

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
  _ChessPageState(this.token,this.roomId);
  @override
  void initState(){
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    charactor = Config.empty;
    timer = new Timer.periodic(new Duration(milliseconds: 300), (Timer t) async {
      bool changed = false;
      try{
        chessInfo = await Config.getGameInfo(token, roomId);
      }catch(e){
        return;
      }
      
      if(chessInfo!=null){
        int temp = changeCharactor();
        if(temp!=charactor){
          charactor=temp;
          changed=true;
        }

        int number;
        if((number=chessInfo.players.length+chessInfo.visitors.length)!=numberOfPeople){
          numberOfPeople=number;
          changed=true;
        }

        if(event.length>2 && chessInfo.events.length==0){
          event=[];
          currentPoint=[];
          array=new List(15*15);
          changed=true;
        }

        if(chessInfo.events.length>event.length){
          await fromEventToArray();
          calculator();
          event=new List.from(chessInfo.events);
          changed=true;
        }

        if((charactor==Config.player_1 || charactor==Config.player_2) 
          && ((chessInfo.events.isEmpty && charactor==Config.player_1)
          || chessInfo.events.isNotEmpty && charactor!=chessInfo.events.last[0])
          ){
            if(actionStatus!=true){
              actionStatus=true;
              changed=true;
            }
          }else{
            if(actionStatus!=false){
              actionStatus=false;
              changed=true;
            }
          }

          if(changed){
            setState(() {

            });
          }
      }
    });
  }

  Size _sizecal(BuildContext context){
    var size = MediaQuery.of(context).size;
    var value = size.width<size.height? size.width:size.height;
    return Size(value,value);
  }
  @override
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Container(
                        margin: new EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: new GestureDetector(
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
                      ),
                      new Container(
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
                      ),
                      new Container(
                        margin: new EdgeInsets.fromLTRB(0, 0, 20, 0),
                        child: new GestureDetector(
                          onTap: () async {
                            Config.restartGame(token, roomId);
                          },
                          child: new Image.asset(
                            "images/flash.png",
                            width: 30,
                            fit: BoxFit.fill,
                          ),
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
                            child: new GestureDetector(
                              child: new Text(
                                roomId,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(fontSize: 20),
                              ),
                              onLongPress: () async {
                                Clipboard.setData(new ClipboardData(text: roomId));
                                Fluttertoast.showToast(
                                  msg: "已复制！",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIos: 2,
                                  backgroundColor: Colors.lightBlue,
                                  textColor: Colors.white
                                );
                              },
                            )
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
                              numberOfPeople.toString(),
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
                            var x=(position.relative.dx/width-1+0.5)~/1;
                            var y=(position.relative.dy/width+0.5)~/1;
                            if(actionStatus &&x>=0 && x<15 && y>=0 && y<15 && array[y*15+x]!='@' && array[y*15+x]!='#'){
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
                  ]
              ),
            )
          ],
        ),
      ),
    );
  }
}