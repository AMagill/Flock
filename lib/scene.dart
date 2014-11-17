part of Flock;

class Scene {
  int width, height;
  webgl.RenderingContext gl;
  FrameBuffer pickBuf;
  StreamController _onDirtyController = new StreamController(); 
  Matrix4 viewProjection = new Matrix4.identity();
  Matrix4 invViewProj    = new Matrix4.identity();
  double zoom = 0.0;
  Vector3 viewCenter = new Vector3(0.0, 0.0, 0.0);
  
  Graph _graph;
  ConnectorLine _line;
  
  String _dragging = "";
  Object _draggingObj;
  Vector4 _lastMouse = new Vector4.zero();
  
  Stream get onDirty => _onDirtyController.stream;
  
  Scene(this.gl, this.width, this.height) {
    pickBuf = new FrameBuffer(gl, width, height);

    var sdfText = new DistanceField(gl);
    sdfText.loadUrl('/packages/Flock/fonts/font.png',
                    '/packages/Flock/fonts/font.json')
      ..then((_) => setDirty());

    _graph = new Graph(gl)
      ..addNode("addition", x:-0.5, y:0.0)
      ..addNode("addition", x: 0.5);
    
    _line = new ConnectorLine(gl);
    
    reproject();
    
    gl.enable(webgl.BLEND);
    gl.blendFunc(webgl.SRC_ALPHA, webgl.ONE_MINUS_SRC_ALPHA);
  }
  
  void animate(double time) {
    
  }
  
  void draw() {
    gl.bindFramebuffer(webgl.FRAMEBUFFER, pickBuf.fbo);
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.clear(webgl.COLOR_BUFFER_BIT);
    _graph.draw(viewProjection, true);
    
    gl.bindFramebuffer(webgl.FRAMEBUFFER, null);
    gl.clearColor(0.8, 0.8, 0.8, 1.0);
    gl.clear(webgl.COLOR_BUFFER_BIT);
    _graph.draw(viewProjection);
    
    if (_dragging.startsWith("line")) {
      _line.draw(viewProjection);
    }
  }
  
  void reproject() {
    viewProjection = new Matrix4.identity();
    viewProjection.scale(math.pow(1.2, zoom));
    viewProjection.translate(-viewCenter);
    
    invViewProj = viewProjection.clone()..invert();
  }
  
  void setDirty() {
    if (_onDirtyController.hasListener && !_onDirtyController.isPaused)
      _onDirtyController.add(null);
  }
  
  PickTarget getPickTarget(int x, int y) {
    var pixel = new Uint8List(4);
    pixel[1] = 42;
    
    gl.bindFramebuffer(webgl.FRAMEBUFFER, pickBuf.fbo);
    gl.readPixels(x, height-y, 1, 1, webgl.RGBA, webgl.UNSIGNED_BYTE, pixel);
    gl.bindFramebuffer(webgl.FRAMEBUFFER, null);
    
    return new PickTable().lookup(pixel);
  }
  
  Vector4 unproject(int x, int y) {
    return invViewProj * new Vector4(x*2.0/width-1.0, -(y*2.0/width-1.0), 0.0, 1.0);
  }

  void onMouseDown(MouseEvent e) {
    var target = getPickTarget(e.layer.x, e.layer.y);
    _lastMouse = unproject(e.layer.x, e.layer.y);
    
    if (target == null) {
      _dragging = "canvas";
    } else if (target.obj is BaseNode) {
      if (target.str == "base") {
        _dragging    = "node";
        _draggingObj = target.obj;        
      } else if (target.str.startsWith("in")) {
        _dragging    = "lineEnd";
        _draggingObj = target.obj;
        setDirty();
      } else if (target.str.startsWith("out")) {
        _dragging    = "lineStart";
        _draggingObj = target.obj;
        setDirty();
      }
    }
    
    e.preventDefault();
  }

  void onMouseMove(MouseEvent e) {
    var worldCoord = unproject(e.layer.x, e.layer.y);
    var delta      = worldCoord - _lastMouse;
    _lastMouse     = worldCoord;
    
    switch (_dragging) {
      case "canvas":
        viewCenter -= delta.xyz;
        _lastMouse -= delta;
        reproject();
        setDirty();
        break;
      case "node":
        (_draggingObj as BaseNode).x += delta.x;
        (_draggingObj as BaseNode).y += delta.y;
        setDirty();
        break;
      case "lineStart":
        _line.fromPt = worldCoord.xy;
        setDirty();
        break;
      case "lineEnd":
        _line.toPt = worldCoord.xy;
        setDirty();
        break;
    }
  }
  
  void onMouseUp(MouseEvent e) {
    _dragging = "";
    setDirty();
  }

  void onMouseOut(MouseEvent e) {
    _dragging = "";
    setDirty();
  }
  
  void onMouseWheel(WheelEvent e) {
    zoom += e.wheelDeltaY / 120.0;
    zoom = math.max(zoom, -10.0);
    zoom = math.min(zoom,  10.0);
    reproject();
    setDirty();
  }
}