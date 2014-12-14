part of Flock;

class Connection extends ConnectionLine {
  static final _tan = new Vector2(0.5, 0.0);
  final Connector conFrom, conTo;
  
  bool _isCycleOffender = false;
  
  get isCycleOffender => _isCycleOffender;
  set isCycleOffender(bool val) {
    _isCycleOffender = val;
    if (val)
      color = new Vector4(1.0, 0.0, 0.0, 1.0);
    else
      color = new Vector4(0.0, 0.0, 0.0, 1.0);
  }

  Connection(webgl.RenderingContext gl, this.conFrom, this.conTo) : super(gl) {
    _points = new Vector2List(4);
    update();
  }
  
  update() {
    _points[0] = conFrom.worldPos;
    _points[2] = conTo.worldPos;
    _updateControlPts();
  }
  
  String toString() {
    return "${conFrom.toString()}-${conTo.toString()}";
  }
}