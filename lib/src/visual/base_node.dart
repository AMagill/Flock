part of Flock;

abstract class BaseNode {
  Graph graph;
  RoundedRect _rect;
  List<Connector> connectors = new List<Connector>();
  Matrix4 modelProj = new Matrix4.identity();
  double _x, _y, width, height;
  
  double get x => _x;
  set x(double val) {
     _x = val;
     modelProj.setTranslationRaw(_x, _y, 0.0);
  }
  
  double get y => _y;
  set y(double val) {
     _y = val;
     modelProj.setTranslationRaw(_x, _y, 0.0);
  }

  BaseNode(this.graph, this.width, this.height,
           {double x:0.0, double y:0.0}) {
    var pickTable = new PickTable();
    var pickColor = pickTable.add(this, "base");
    
    _rect = new RoundedRect(graph.gl, w:width, h:height, pickColor:pickColor);
    _x = x;
    _y = y;
    modelProj.setTranslationRaw(_x, _y, 0.0);
  }
  
  void draw(Matrix4 projection, [bool picking = false]) {
    var mvp = projection * modelProj;
    
    _rect.draw(mvp, picking);
    for (var con in connectors) {
      con.draw(mvp, picking);
    }
  }
}