part of Flock;

abstract class BaseNode {
  Graph graph;
  RoundedRect _rect;
  Map<String, Connector> connectors = new Map<String, Connector>();
  Matrix4 modelProj = new Matrix4.identity();
  double width, height;
  Vector2 _pos;
  
  Vector2 get pos => _pos;
  set pos(Vector2 val) {
     _pos = val;
     modelProj.setTranslationRaw(val.x, val.y, 0.0);
     
     // Update connector lines
     for (var con in connectors.values) {
       for (var connection in con.connections) {
         connection.update();
       }
     }
  }
  
  Set<Connection> get inputConnections {
    var result = new Set<Connection>();
    connectors.values.where((c)=>!c.isOut).forEach((c)=>result.addAll(c.connections));
    return result;
  }

  Set<Connection> get outputConnections {
    var result = new Set<Connection>();
    connectors.values.where((c)=>c.isOut).forEach((c)=>result.addAll(c.connections));
    return result;
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
  
  factory BaseNode.NamedType(Graph graph, String type, double x, double y) {
    switch (type.toLowerCase()) {
      case "addition":          return new AdditionNode(graph, x:x, y:y);
      case "subtraction":       return new SubtractionNode(graph, x:x, y:y);
      case "multiplication":    return new MultiplicationNode(graph, x:x, y:y);
      case "division":          return new DivisionNode(graph, x:x, y:y);
      case "birdinput":         return new BirdInput(graph, x:x, y:y);
      case "birdoutput":        return new BirdOutput(graph, x:x, y:y);
      default:                  return null;
    }
  }
  
  void draw(Matrix4 projection, [bool picking = false]) {
    var mvp = projection * modelProj;
    
    _rect.draw(mvp, picking);

  }
  
  getCompute() {
    void doCompute(Map state) {}  // No-op
    return doCompute;
  }
}