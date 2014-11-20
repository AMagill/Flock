part of Flock;

class Graph {
  final fontSrc = ['/packages/Flock/fonts/font.png',
                   '/packages/Flock/fonts/font.json'];

  List<BaseNode> nodes = [];
  Map<Connector, ConnectorLine> connectionLines = {};
  
  final webgl.RenderingContext gl;
  final sdfText;
  
  Graph(gl) 
    : this.gl = gl,
      sdfText = new DistanceField(gl) {
    sdfText.loadUrl(fontSrc[0], fontSrc[1]);
  }
  
  void addNode(String type, {x:0.0, y:0.0, Vector2 position}) {
    switch (type.toLowerCase()) {
      case "entity":
        nodes.add(new EntityNode(this, x:x, y:y));
        break;
      case "addition":
        nodes.add(new AdditionNode(this, x:x, y:y));
        break;
      default:
    }
    
  }
  
  void draw(Matrix4 projection, [bool picking = false]) {
    for (var node in nodes) {
      node.draw(projection, picking);
    }
    
    if (!picking) {
      for (var line in connectionLines.values) {
        line.draw(projection, picking);
      }
    }
  }
  
  void connect(Connector outCon, Connector inCon) {
    disconnect(inCon);
    
    var newLine = new ConnectorLine(gl)
      ..fromPt = outCon.worldPos
      ..toPt   = inCon.worldPos;
    connectionLines[inCon] = newLine;
    outCon.connections.add(inCon);
    inCon.connections.add(outCon);
  }
  
  void disconnect(Connector inCon) {
    // There should never be more than one
    for (var other in inCon.connections) {
      connectionLines.remove(inCon);
      other.connections.remove(inCon);
    }
    inCon.connections.clear();
  }
}