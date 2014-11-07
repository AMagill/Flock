part of node_graph;

class Graph {
  webgl.RenderingContext _gl;
  var _nodes = new List<BaseNode>();
  
  Graph(this._gl) {
    
  }
  
  void addNode(String type, {x:0.0, y:0.0, Vector2 position}) {
    switch (type.toLowerCase()) {
      case "entity":
        _nodes.add(new EntityNode(_gl, x:x, y:y));
        break;
      case "add":
        _nodes.add(new AddNode(_gl, x:x, y:y));
        break;
      default:
    }
    
  }
  
  void draw(Matrix4 projection) {
    for (var node in _nodes) {
      node.draw(projection);
    }
  }
}