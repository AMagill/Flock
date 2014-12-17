part of Flock;

class MultiplicationNode extends BaseNode {
  static var objectCount = 0;
  final uniqueNum = objectCount++;

  static const size = 0.2;
  
  TextLayout text;
  
  MultiplicationNode(Graph graph, {x:0.0, y:0.0}) : 
    super(graph, size, size, x:x, y:y) {
    
    connectors['inA'] = new Connector(this, 'inA', false, -size/2,  size/5);
    connectors['inB'] = new Connector(this, 'inB', false, -size/2, -size/5);
    connectors['out'] = new Connector(this, 'out', true,   size/2,  0.0   );

    text = new TextLayout(graph.gl, graph.sdfText);
    text.addString('*', scale:0.25, x:0.0, y:0.08);
  }
  
  void draw(Matrix4 projection, [bool picking = false]) {
    super.draw(projection, picking);
    if (!picking)
      text.draw(projection * super.modelProj);
  }
  
  getCompute() {
    final inA = connectors['inA'].connections.isNotEmpty ?
                connectors['inA'].connections.first.conFrom.toString() : null;
    final inB = connectors['inB'].connections.isNotEmpty ?
                connectors['inB'].connections.first.conFrom.toString() : null;
    final out = "${toString()}[out]";
    
    void doCompute(Map state) {
      var valA = (inA == null) ? 1.0 : state[inA];
      var valB = (inB == null) ? 1.0 : state[inB];
      state[out] = valA * valB;
    }
    return doCompute;
  }

  String toString() {
    return "Multiplication${uniqueNum}";
  }
}