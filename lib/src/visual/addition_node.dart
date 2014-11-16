part of Flock;

class AdditionNode extends BaseNode {
  static const size = 0.2;
  static final connectors = {
    'inA': new Vector2(-size/2,  size/5),
    'inB': new Vector2(-size/2, -size/5),
    'out': new Vector2( size/2,  0.0),
  };
  
  TextLayout text;
  
  AdditionNode(Graph graph, {x:0.0, y:0.0}) : 
    super(graph, size, size, connectors, x:x, y:y) {

    text = new TextLayout(graph.gl, graph.sdfText);
    text.addString('+', scale:1.5, x:-0.017, y:0.089);
  }
  
  void draw(Matrix4 projection, [bool picking = false]) {
    super.draw(projection, picking);
    if (!picking)
      text.draw(projection * super.modelProj);
  }
}