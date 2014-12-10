part of Flock;

class BirdInput extends BaseNode {
  static const size = 0.2;
  
  TextLayout text;
  
  BirdInput(Graph graph, {x:0.0, y:0.0}) : 
    super(graph, size, size*2, x:x, y:y) {
    
    connectors.add(new Connector(this, 'outA', true, size/2,  size/2));
    connectors.add(new Connector(this, 'outB', true, size/2,  0.0   ));
    connectors.add(new Connector(this, 'outC', true, size/2, -size/2));

    text = new TextLayout(graph.gl, graph.sdfText);
    text.addString('In', scale:1.2, x:-0.017, y:0.069);
  }
  
  void draw(Matrix4 projection, [bool picking = false]) {
    super.draw(projection, picking);
    if (!picking)
      text.draw(projection * super.modelProj);
  }
}