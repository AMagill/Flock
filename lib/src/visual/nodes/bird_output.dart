part of Flock;

class BirdOutput extends BaseNode {
  static var objectCount = 0;
  final uniqueNum = objectCount++;

  static const size = 0.2;
  
  TextLayout text;
  
  BirdOutput(Graph graph, {x:0.0, y:0.0}) : 
    super(graph, size, size*2, x:x, y:y) {
    
    connectors.add(new Connector(this, 'inA', false, -size/2,  size/2));
    connectors.add(new Connector(this, 'inB', false, -size/2,  0.0   ));
    connectors.add(new Connector(this, 'inC', false, -size/2, -size/2));

    text = new TextLayout(graph.gl, graph.sdfText);
    text.addString('Out', scale:0.8, x:-0.017, y:0.069);
  }
  
  void draw(Matrix4 projection, [bool picking = false]) {
    super.draw(projection, picking);
    if (!picking)
      text.draw(projection * super.modelProj);
  }

  String toString() {
    return "BirdOutput${uniqueNum}";
  }
}