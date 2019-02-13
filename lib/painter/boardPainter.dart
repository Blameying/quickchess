import 'package:flutter/material.dart';
import 'package:quickchess/model/chessboard.dart';

class BoardPainter extends CustomPainter{

  final List event;
  final List currentPoint;
  //final List lastPoint;
  final ChessBoard chessInfo;
  BoardPainter(this.event,this.currentPoint,this.chessInfo);

  @override
  void paint(Canvas canvas,Size size){
    Paint pen = Paint()
      ..color = Color.fromARGB(255, 252, 152, 0)
      ..isAntiAlias = true
      ..strokeWidth = 2;
    var width = size.width>size.height? size.height/16:size.width/16;
    for(int i=0;i<15;++i){
      canvas.drawLine(Offset((i+1)*width, 0*width), Offset((i+1)*width,14*width), pen);
      canvas.drawLine(Offset(1*width, (i)*width),Offset(15*width, (i)*width),pen);
    }
    canvas.drawCircle(Offset(8*width,7*width), 4, pen);
    canvas.drawCircle(Offset(4*width,3*width), 4, pen);
    canvas.drawCircle(Offset(12*width,3*width), 4, pen);
    canvas.drawCircle(Offset(4*width,11*width), 4, pen);
    canvas.drawCircle(Offset(12*width,11*width), 4, pen);

    Paint whitePen = Paint()
      ..color = Color.fromARGB(255, 255, 255, 255)
      ..isAntiAlias=true
      ..strokeWidth=2;
    Paint blackPen = Paint()
      ..color = Color.fromARGB(255, 0, 0, 0)
      ..isAntiAlias=true
      ..strokeWidth=2;
    Paint redPen = Paint()
      ..color = Color.fromARGB(255, 225, 0, 0)
      ..isAntiAlias=true
      ..strokeWidth=2;

    for(int i=0;i<15;++i){
      for(int j=0;j<15;j++){
        if(event[i*15+j]=='@'){
          canvas.drawCircle(Offset((j+1)*width,i*width), 8, blackPen);
        }else if(event[i*15+j]=='#'){
          canvas.drawCircle(Offset((j+1)*width,i*width), 8, whitePen);
        }
      }
    }
    /*List lastPoint;
    lastPoint=chessInfo.events.last;*/
    if(chessInfo!=null && chessInfo.events.length>0) {
     canvas.drawCircle(Offset((chessInfo.events.last[1]+1)*width,chessInfo.events.last[2]*width), 3, redPen);
    }

    if(currentPoint.isNotEmpty){
      var tmp = event[currentPoint[2]*15+currentPoint[1]];
      if(tmp!='@' && tmp != '#'){
        canvas.drawCircle(Offset((currentPoint[1]+1)*width,currentPoint[2]*width), 8, redPen);
      }
    }
  }

  @override
  bool shouldRepaint(BoardPainter op){
    if(chessInfo==null){
      return false;
    }
    if(currentPoint.isNotEmpty && op.currentPoint.isNotEmpty){
      return (op.chessInfo==null)||(chessInfo.events.length!=op.chessInfo.events.length)||currentPoint[1]!=op.currentPoint[1]||currentPoint[2]!=op.currentPoint[2];
    }
    else{
      return (currentPoint.isNotEmpty && op.currentPoint.isEmpty)||(op.chessInfo==null)||(chessInfo.events.length!=op.chessInfo.events.length);
    }
  }
}