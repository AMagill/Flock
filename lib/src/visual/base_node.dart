part of Flock;

abstract class BaseNode {
  Graph graph;
  RoundedRect _rect;
  List<Connector> connectors = new List<Connector>();
  Matrix4 modelProj = new Matrix4.identity();
  double width, height;
  Vector2 _pos;
  
  Vector2 get pos => _pos;
  set pos(Vector2 val) {
     _pos = val;
     modelProj.setTranslationRaw(val.x, val.y, 0.0);
     
     // Update connector lines
     for (var con in connectors) {
       for (var other in con.connections) {
         if (con.isOut) {
           var line = graph.connectionLines[other];
           line.fromPt = con.worldPos;
         } else {
           var line = graph.connectionLines[con];
           line.toPt = con.worldPos;
         }
       }
     }
  }

  BaseNode(this.graph, this.width, this.height,
           {double x:0.0, double y:0.0}) {
    var pickTable = new PickTable();
    var pickColor = pickTable.add(this);
    
    _rect = new RoundedRect(graph.gl)
      ..addRect(0.0, 0.0, width, height, pickColor: pickColor);
    _pos  = new Vector2(x, y);
    modelProj.setTranslationRaw(x, y, 0.0);
  }
  
  void draw(Matrix4 projection, [bool picking = false]) {
    var mvp = projection * modelProj;
    
    _rect.draw(mvp, picking);

  }
}