part of Flock;

class Graph {
  final fontSrc = ['/packages/Flock/fonts/font.png',
                   '/packages/Flock/fonts/font.json'];

  var _nodes = new List<BaseNode>();
  final webgl.RenderingContext gl;
  final sdfText;
  
  Graph(gl) 
    : this.gl = gl,
      sdfText = new DistanceField(gl) {
    sdfText.loadUrl(fontSrc[0], fontSrc[1]);
  }
  
  void addNode(String type, {x:0.0, y:0.0, Vector2 position}) {
    switch (type.toLowerCase()) {
      case "entity":
        _nodes.add(new EntityNode(this, x:x, y:y));
        break;
      case "addition":
        _nodes.add(new AdditionNode(this, x:x, y:y));
        break;
      default:
    }
    
  }
  
  void draw(Matrix4 projection, [bool picking = false]) {
    for (var node in _nodes) {
      node.draw(projection, picking);
    }
  }
}