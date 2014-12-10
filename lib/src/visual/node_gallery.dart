part of Flock;

class NodeGallery {
  static const nodeWidth  = 0.4;
  static const nodeHeight = 0.1;
  static const marginSize = 0.03;
  
  Graph graph;
  RoundedRect _rects;
  TextLayout  _text;
  List<GalleryNode> _nodes = [];
  
  NodeGallery(this.graph, String nodes, int columns, {double x:0.0, double y:0.0}) {
    var nodeTypes = nodes.split(',');

    columns    = columns.clamp(1, nodeTypes.length);
    var rows   = nodeTypes.length ~/ columns; 
    var width  = marginSize + (nodeWidth + marginSize) * columns;
    var height = marginSize + (nodeHeight + marginSize) * rows;
    
    _rects = new RoundedRect(graph.gl)
      ..addRect(x, y, width, height, 
          edgeColor: new Vector4(0.0, 0.2, 0.0, 1.0),
          inColor  : new Vector4(1.0, 1.0, 1.0, 1.0));
    _text = new TextLayout(graph.gl, graph.sdfText);
    
    final topLeftX = x + (nodeWidth-width )/2 + marginSize;
    final topLeftY = y + (height-nodeHeight)/2 - marginSize; 
    for (var i = 0; i < nodeTypes.length; i++) {
      var nx = topLeftX + (nodeWidth+marginSize) * (i%columns);
      var ny = topLeftY - (nodeHeight+marginSize) * (i~/columns);
      _nodes.add(new GalleryNode(this, nodeTypes[i], nx, ny, nodeWidth, nodeHeight));
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
    gallery._text.addString(type, scale:0.5, x:x-0.015, y:y+0.025);
  }
}