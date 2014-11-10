part of node_graph;

abstract class BaseNode {
  final conSize = 0.06;
  
  RoundedRect _rect;
  List<RoundedRect> _connectorRects;
  Map<String, Vector2> connectorMap;
  Matrix4 modelProj;
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

  BaseNode(Graph graph, this.width, this.height, this.connectorMap, 
           {double x:0.0, double y:0.0}) {
    _rect = new RoundedRect(graph.gl, w:width, h:height);
    modelProj = new Matrix4.identity();
    _connectorRects = new List<RoundedRect>();
    _x = x;
    _y = y;
    modelProj.setTranslationRaw(_x, _y, 0.0);
    
    for (var item in connectorMap.values) {
      _connectorRects.add(new RoundedRect(graph.gl, w:conSize, h:conSize, radius:conSize/2,
          x:item.x, y:item.y, inColor:new Vector4(1.0,1.0,1.0,1.0)));
    }
  }
  
  void draw(Matrix4 projection) {
    var mvp = projection * modelProj;
    
    _rect.draw(mvp);
    for (var cc in _connectorRects) {
      cc.draw(mvp);
    }
  }
}