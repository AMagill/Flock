part of Flock;

// This should probably only be used in BaseNode.
class Connector {
  final inColor = new Vector4(1.0,1.0,1.0,1.0);
  final size = 0.06;

  final String   name;
  final Vector2  pos;
  final BaseNode node;
  final bool     isOut;
  
  Set<Connector> connections = new Set<Connector>();
  
  RoundedRect _rect;
  
  Vector2 get worldPos => (node.modelProj * new Vector4(pos.x, pos.y, 0.0, 1.0)).xy;
  
  Connector(this.node, this.name, this.isOut, double x, double y) :
    pos = new Vector2(x, y)  {
    
    var pickColor = new PickTable().add(this, "con");
    _rect = new RoundedRect(node.graph.gl, w:size, h:size, radius:size/2,
        x:x, y:y, inColor:inColor, pickColor:pickColor);
  }
  
  void draw(Matrix4 proj, [bool picking = false]) {
    _rect.draw(proj, picking);
  }
}