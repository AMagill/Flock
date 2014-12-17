part of Flock;

class BirdOutput extends BaseNode {
  static var objectCount = 0;
  final uniqueNum = objectCount++;

  static const size = 0.2;
  
  TextLayout text;
  
  BirdOutput(Graph graph, {x:0.0, y:0.0}) : 
    super(graph, size, size*2, x:x, y:y) {
    
    connectors['inA'] = new Connector(this, 'inA', false, -size/2,  size/2);
    connectors['inB'] = new Connector(this, 'inB', false, -size/2,  0.0   );
    connectors['inC'] = new Connector(this, 'inC', false, -size/2, -size/2);

    text = new TextLayout(graph.gl, graph.sdfText);
    text.addString('Out', scale:0.10, x:0.0, y:0.05);
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
    final inC = connectors['inC'].connections.isNotEmpty ?
                connectors['inC'].connections.first.conFrom.toString() : null;
    
    void doCompute(Map state) {
      final valA = (inA == null) ? 0.0 : state[inA];
      final valB = (inB == null) ? 0.0 : state[inB];
      final valC = (inC == null) ? 0.0 : state[inC];
      print("Out: A=$valA B=$valB C=$valC");
    }
    return doCompute;
  }

  String toString() {
    return "BirdOutput${uniqueNum}";
  }
}