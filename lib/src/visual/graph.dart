part of Flock;

class Graph {
  final fontSrc = ['/packages/Flock/fonts/font.png',
                   '/packages/Flock/fonts/font.json'];

  List<BaseNode> nodes = [];
  Map<Connector, Connection> connections = {};
  
  final webgl.RenderingContext gl;
  final sdfText;
  
  Graph(gl) 
    : this.gl = gl,
      sdfText = new DistanceField(gl) {
    sdfText.loadUrl(fontSrc[0], fontSrc[1]);
  }
  
  BaseNode addNode(String type, {x:0.0, y:0.0}) {
    BaseNode newNode;
    switch (type.toLowerCase()) {
      case "entity":
        newNode = new EntityNode(this, x:x, y:y);
        break;
      case "addition":
        newNode = new AdditionNode(this, x:x, y:y);
        break;
      case "subtraction":
        newNode = new SubtractionNode(this, x:x, y:y);
        break;
      case "multiplication":
        newNode = new MultiplicationNode(this, x:x, y:y);
        break;
      case "division":
        newNode = new DivisionNode(this, x:x, y:y);
        break;
      case "birdinput":
        newNode = new BirdInput(this, x:x, y:y);
        break;
      case "birdoutput":
        newNode = new BirdOutput(this, x:x, y:y);
        break;
      default:
    }

    if (newNode != null)
      nodes.add(newNode);
    
    return newNode;
  }
  
  void draw(Matrix4 projection, [bool picking = false]) {
    for (var node in nodes) {
      node.draw(projection, picking);
    }
    
    if (!picking) {
      for (var line in connections.values) {
        line.draw(projection, picking);
      }
    }
  }
  
  void connect(Connector outCon, Connector inCon) {
    disconnect(inCon);
    
    var newConnection = new Connection(gl, outCon, inCon);
    connections[inCon] = newConnection;
    outCon.connections.add(newConnection);
    inCon.connections.add(newConnection);
  }
  
  void disconnect(Connector inCon) {
    // There should never be more than one
    for (var connection in inCon.connections) {
      connection.conFrom.connections.remove(connection);
    }
    connections.remove(inCon);
    inCon.connections.clear();
  }
  
  void sort() {
    
  }
}