part of Flock;

class BirdInput extends BaseNode {
  static var objectCount = 0;
  final uniqueNum = objectCount++;

  static const size = 0.2;
  
  TextLayout text;
  
  BirdInput(Graph graph, {x:0.0, y:0.0}) : 
    super(graph, size, size*2, x:x, y:y) {
    
    connectors['outA'] = new Connector(this, 'outA', true, size/2,  size/2);
    connectors['outB'] = new Connector(this, 'outB', true, size/2,  0.0   );
    connectors['outC'] = new Connector(this, 'outC', true, size/2, -size/2);

    text = new TextLayout(graph.gl, graph.sdfText);
    text.addString('In', scale:1.2, x:-0.017, y:0.069);
  }
  
  void draw(Matrix4 projection, [bool picking = false]) {
    super.draw(projection, picking);
    if (!picking)
      text.draw(projection * super.modelProj);
  }
  
  getCompute() {
    final outA = "${toString()}[outA]";
    final outB = "${toString()}[outB]";
    final outC = "${toString()}[outC]";
    
    void doCompute(Map state) {
      state[outA] = 0.0;
      state[outB] = 1.0;
      state[outC] = 2.0;      
    }
    return doCompute;
  }

  String toString() {
    return "BirdInput${uniqueNum}";
  }
}