part of Flock;

class Graph {
  final fontSrc = ['/packages/Flock/fonts/font.png',
                   '/packages/Flock/fonts/font.json'];

  BaseNode outputNode;
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
    BaseNode newNode = new BaseNode.NamedType(this, type, x, y);

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
    disconnect(inCon);    // Inputs should never have more than one connection.
    
    var newConnection = new Connection(gl, outCon, inCon);
    connections[inCon] = newConnection;
    outCon.connections.add(newConnection);
    inCon.connections.add(newConnection);
    
    sortConnections();
  }
  
  void disconnect(Connector inCon) {
    for (var connection in inCon.connections) {
      connection.conFrom.connections.remove(connection);
    }
    connections.remove(inCon);
    inCon.connections.clear();
    
    sortConnections();
  }
  
  void sortConnections() {
    // To solve the graph, we need to compute the value of each connection in
    // order so that each node's outputs are computed after all its inputs.
    // This is what topological sorting is for.
    List<Connection> sorted  = new List<Connection>();
    Set<Connection> unmarked = connections.values.toSet();
    Set<Connection> tempMark = new Set<Connection>();
    
    void visit(Connection n) {
      if (tempMark.contains(n))
        throw new GraphCycleException(n);
      if (unmarked.contains(n)) {
        tempMark.add(n);
        for (var m in n.conTo.node.outputConnections)
          visit(m);
        unmarked.remove(n);
        tempMark.remove(n);
        sorted.add(n);
      }
    }
    
    for (var con in connections.values)
      con.isCycleOffender = false;
    
    try {
      while (unmarked.isNotEmpty)
        visit(unmarked.first);
    } on GraphCycleException catch (e) {
      e.offender.isCycleOffender = true;
    }
    
    sorted = sorted.reversed.toList(growable:false);
  }
}

class GraphCycleException implements Exception {
  final Connection offender;
  GraphCycleException(this.offender);
}