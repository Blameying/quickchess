
class ChessBoard{
  var players = List<dynamic>();
  var visitors = List<dynamic>();
  var events=List<dynamic>();
  
  ChessBoard.fromJson(Map<String,dynamic> json)
    :players = json["players"],
    visitors = json["visitors"],
    events=json["event"];
  
  void addPlayer(String id){
    if(players.length<2){
      players.add(id);
    }
  }

  void addVisitor(String id){
    visitors.add(id);
  }

  void addEvent(String id,int x,int y){
    if(players.contains(id)){
      var event = List();
      event.add(id);
      event.add(x);
      event.add(y);
      events.add(event);
    }
  }

  List lastEvent(){
    return events.last;
  }

  Map<String,dynamic> toJson()=>
    {
      'players': players,
      'visitors': visitors,
      'event': events
    };
}