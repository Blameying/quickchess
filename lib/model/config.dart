import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:core';
import 'package:quickchess/model/chessboard.dart';
class Config{

  static final int player_1 = 1;
  static final int player_2 = 2;
  static final int visitor = 3;
  static final int empty = 100;

  Config();

  static String getLoginUrl(){
    return "http://47.100.124.210:4567/api/login";
  }

  static String getKeepAliveUrl(){
    return "http://47.100.124.210:4567/api/keepalive";
  }

  static String createRoomUrl(){
    return "http://47.100.124.210:4567/api/create/game";
  }

  static String getGameInfoUrl(){
    return "http://47.100.124.210:4567/api/get/gameinfo";
  }

  static String getJoinGameUrl(){
    return "http://47.100.124.210:4567/api/join/game";
  }

  static String getSendStepUrl(){
    return "http://47.100.124.210:4567/api/send/gamestep";
  }

  static String getRestartGameUrl(){
    return "http://47.100.124.210:4567/api/restart/game";
  }

  static Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfoPlugin=DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo=await deviceInfoPlugin.androidInfo;
    return androidDeviceInfo.androidId;
  }

  static void keepAlive(String token) async {
    Dio dio = new Dio();
    Response response=await dio.post(getKeepAliveUrl(),data: {"token":token});
  }

  static Future<String> getToken(String mac) async {
    Dio dio = new Dio();
    Response response=await dio.post(getLoginUrl(),data:{"MAC":mac});
    var data = json.decode(response.data);
    if(data["status"]==true){
      print("yes recieved token: "+data["token"]);
      return data["token"];
    }else{
      return "";
    }
  }

  static Future<String> createRoom(String token) async{
    Dio dio = new Dio();
    String result="";
    Response response=await dio.post(createRoomUrl(),data: {"token":token});
    var data = json.decode(response.data);
    if(data["status"]==true){
      result=data['message'];
      print("room was created successfully");
    }
    return result;
  }

  static Future<int> joinGame(String token,String room) async {
    Dio dio=new Dio();
    Response response=await dio.post(getJoinGameUrl(),data: {"token":token,"game_id":room});
    var data = json.decode(response.data);
    if(data["status"]){
      ChessBoard chessBoard = await getGameInfo(token, room);
      if(chessBoard!=null){
        if(chessBoard.players.contains(token)){
          return player_2;
        }else if(chessBoard.visitors.contains(token)){
          return visitor;
        }
      }else{
        return 0;
      }
    }else{
      print(data);
      return 0;
    }
  }

  static Future<ChessBoard> getGameInfo(String token,String room) async {
    Dio dio = new Dio();
    Response response=await dio.post(getGameInfoUrl(),data:{"token":token,"game_id":room});
    var data = json.decode(response.data);
    if(data["status"]==true){
      ChessBoard chessInfo=new ChessBoard.fromJson(jsonDecode(data["message"]));
      print("yes recieved chessInfo: "+json.encode(chessInfo));
      return chessInfo;
    }else{
      return null;
    }
  }

  static Future<ChessBoard> sendStepData(String token,String room,List step) async {
    Dio dio = new Dio();
    Response response=await dio.post(getSendStepUrl(),data:{"token":token,"game_id":room,"step":step});
    var data = json.decode(response.data);
    if(data["status"]==true){
      ChessBoard chessInfo=new ChessBoard.fromJson(jsonDecode(data["message"]));
      print("yes recieved chessInfo: "+json.encode(chessInfo));
      return chessInfo;
    }else{
      return null;
    }
  }

  static Future<ChessBoard> restartGame(String token,String room) async {
    Dio dio = new Dio();
    Response response=await dio.post(getRestartGameUrl(),data:{"token":token,"game_id":room});
    var data = json.decode(response.data);
    if(data["status"]==true){
      ChessBoard chessInfo=new ChessBoard.fromJson(jsonDecode(data["message"]));
      print("yes recieved chessInfo: "+json.encode(chessInfo));
      return chessInfo;
    }else{
      return null;
    }
  }

  static Future<ChessBoard> sendJumpData(String token,String room,List step) async {


  }

  static Future<ChessBoard> sendCollectData(String token,String room,List step) async {


  }


}