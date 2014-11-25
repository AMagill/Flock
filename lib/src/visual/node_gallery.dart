part of Flock;

class NodeGallery {
  static const nodeSize = 0.15;
  static const marginSize = 0.03;
  
  Graph graph;
  RoundedRect _rects;
  TextLayout  _text;
  List<GalleryNode> _nodes = [];
  
  NodeGallery(this.graph, String nodes, int columns, {double x:0.0, double y:0.0}) {
    columns    = columns.clamp(1, nodes.length);
    var rows   = nodes.length ~/ columns; 
    var width  = marginSize + (nodeSize + marginSize) * columns;
    var height = marginSize + (nodeSize + marginSize) * rows;
    
    _rects = new RoundedRect(graph.gl)
      ..addRect(x, y, width, height, 
          edgeColor: new Vector4(0.0, 0.2, 0.0, 1.0),
          inColor  : new Vector4(1.0, 1.0, 1.0, 1.0));
    _text = new TextLayout(graph.gl, graph.sdfText);
    
    final topLeftX = x + (nodeSize-width )/2 + marginSize;
    final topLeftY = y + (height-nodeSize)/2 - marginSize; 
    for (var i = 0; i < nodes.length; i++) {
      var nx = topLeftX + (nodeSize+marginSize) * (i%columns);
      var ny = topLeftY - (nodeSize+marginSize) * (i~/columns);
      _nodes.add(new GalleryNode(this, nodes[i], nx, ny, nodeSize, nodeSize));
    }
  }
  
  void draw(Matrix4 proj, [bool picking = false]) {
    _rects.draw(proj, picking);
    if (!picking)
      _text.draw(proj);
  }
}

class GalleryNode {
  final String type;
  
  GalleryNode(NodeGallery gallery, this.type, double x, double y, double w, double h) {
    var pickColor = new PickTable().add(this);
    gallery._rects.addRect(x, y, w, h, radius: 0.025, pickColor: pickColor);
    gallery._text.addString(type, scale:1.0, x:x-0.015, y:y+0.060);
  }
  
  String getTypeName() {
    switch (type) {
      case '+':
        return "Addition";
      case '-':
        return "Subtraction";
      case '*':
        return "Multiplication";
      case '/':
        return "Division";
    }
    return null;
  }
}