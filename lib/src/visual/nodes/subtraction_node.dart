part of Flock;

class SubtractionNode extends BaseNode {
  static const size = 0.2;
  
  TextLayout text;
  
  SubtractionNode(Graph graph, {x:0.0, y:0.0}) : 
    super(graph, size, size, x:x, y:y) {
    
    connectors.add(new Connector(this, 'inA', false, -size/2,  size/5));
    connectors.add(new Connector(this, 'inB', false, -size/2, -size/5));
    connectors.add(new Connector(this, 'out', true,   size/2,  0.0   ));

    text = new TextLayout(graph.gl, graph.sdfText);
    text.addString('-', scale:1.5, x:-0.017, y:0.089);
  }
  
  void draw(Matrix4 projection, [bool picking = false]) {
    super.draw(projection, picking);
    if (!picking)
      text.draw(projection * super.modelProj);
  }
}