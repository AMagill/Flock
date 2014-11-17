part of Flock;

class ConnectorLine extends Bezier {
  final tan = new Vector2(0.1, 0.0);
  
  Vector2 get fromPt => _points[0];
  set fromPt(Vector2 value) {
    _points[1] = value;
    _points[0] = value + tan;
    _generateBuffer();
  }
  
  Vector2 get toPt => _points[2];
  set toPt(Vector2 value) {
    _points[2] = value - tan;
    _points[3] = value;
    _generateBuffer();
  }

  ConnectorLine(webgl.RenderingContext gl) : super(gl) {
    _points = new Vector2List(4);
  }
}