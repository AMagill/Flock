part of node_graph;

class Graph {
  webgl.RenderingContext _gl;
  var _nodes = new List<Node>();
  
  Graph(this._gl) {
    
  }
  
  void AddNode([size, Vector2 position]) {
    _nodes.add(new Node(_gl, size, position));
  }
  
  void draw(Matrix4 projection) {
    for (var node in _nodes) {
      node.draw(projection);
    }
  }
}