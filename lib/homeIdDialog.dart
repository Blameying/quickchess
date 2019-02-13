import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quickchess/chessPage.dart';
import 'package:quickchess/model/config.dart';


class HomeIdDialog extends Dialog{
  TextEditingController controller;
  final DataStore dataStore = new DataStore(text: "");
  final String token;

  HomeIdDialog({Key key,@required String text,@required this.token}):super(key: key){
    this.dataStore.text = text;
    controller=new TextEditingController();
  }

  @override
  Widget build(BuildContext context){
    return new Material(
      type: MaterialType.transparency,
      child: new Center(
        child: new SizedBox(
          width: 240.0,
          height: 148.0,
          child: new Container(
            padding: EdgeInsets.all(20),
            decoration: ShapeDecoration(
              color: Color.fromARGB(255, 230, 230, 230),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            ),
            child: new Column(
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      this.dataStore.text,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: "FangZhengHanZhen",
                        fontSize: 14,
                        color: Color.fromARGB(255, 138, 127, 127)
                        ),
                    ),
                    new SizedBox(
                      width: 80,
                    ),
                    new GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: new Image.asset(
                        "images/no.png",
                        width: 30,
                        height: 25,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
                new Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: new TextField(
                    controller: controller,
                    maxLength: 6,
                    maxLines: 1,
                    autofocus: true,
                    obscureText: false,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(5.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0)
                      )
                    ),
                    onChanged: (String s){
                      print(s);
                      print(controller.value);
                      print(controller.text);
                    },
                  ),
                ),
                new Expanded(
                  child: new RaisedButton(
                    onPressed: () async {
                      if(controller.text.length==6){
                        //加入房间请求
                        if(token.isNotEmpty){
                          int id=0;
                          try{
                            id = await Config.joinGame(token, controller.text);
                          }catch(e){
                            print("network error when join room");
                          }
                          if(id==0){
                            return;
                          }
                          Navigator.pop(context);
                          Navigator.push(context, new MaterialPageRoute(
                            builder: (context)=>new ChessPage(token,controller.text,id)
                          ));
                        }
                      }else{
                        Fluttertoast.showToast(
                          msg: "错误的房间号格式",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIos: 1,
                          backgroundColor: Colors.lightBlue,
                          textColor: Colors.black
                        );
                      }
                    },
                    child:Text(
                      "加入",
                      textDirection: TextDirection.ltr,   
                    ),
                    color: Color.fromARGB(255, 255, 255, 255),
                    shape: new RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0))
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DataStore{
  String text;
  DataStore({this.text});
}