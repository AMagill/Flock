part of Flock;

// This should only be used in BaseNode.
class Connector {
  final inColor = new Vector4(1.0,1.0,1.0,1.0);
  final size = 0.06;

  final String   name;
  final Vector2  pos;
  final BaseNode node;
  final bool     isOut;
  
  Set<Connection> connections = new Set<Connection>();
  
  RoundedRect _rect;
  
  Vector2 get worldPos => (node.modelProj * new Vector4(pos.x, pos.y, 0.0, 1.0)).xy;
  
  Connector(this.node, this.name, this.isOut, double x, double y) :
    pos = new Vector2(x, y)  {
    
    var pickColor = new PickTable().add(this);
    node._rect.addRect(x, y, size, size, radius:size/2, inColor:inColor, pickColor:pickColor);
  }
  
  String toString() {
    return "${node.toString()}[${name}]";
  }
}