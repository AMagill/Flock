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
  ConnectionLine _line;
  NodeGallery _gallery;
  
  String _dragging = "";
  Object _dragObject;
  Vector4 _lastMouse = new Vector4.zero();
  
  Stream get onDirty => _onDirtyController.stream;
  
  Scene(this.gl, this.width, this.height) {
    pickBuf = new FrameBuffer(gl, width, height);

    var sdfText = new DistanceField(gl);
    sdfText.loadUrl('/packages/Flock/fonts/font.png',
                    '/packages/Flock/fonts/font.json')
      ..then((_) => setDirty());

    _graph = new Graph(gl);
    _line = new ConnectionLine(gl);
    
    _gallery = new NodeGallery(_graph, "addition,subtraction,multiplication,division,birdinput,birdoutput", 1, x:-0.75);
    
    reproject();
    
    gl.enable(webgl.BLEND);
    gl.blendFunc(webgl.SRC_ALPHA, webgl.ONE_MINUS_SRC_ALPHA);
  }
  
  void animate(double time) {
    
  }
  
  void draw() {
    void drawPicking() {
      gl.clearColor(0.0, 0.0, 0.0, 1.0);
      gl.clear(webgl.COLOR_BUFFER_BIT);
      _gallery.draw(viewProjection, true);      
      _graph.draw(viewProjection, true);      
    }
    
    gl.bindFramebuffer(webgl.FRAMEBUFFER, pickBuf.fbo);
    drawPicking();
    
    gl.bindFramebuffer(webgl.FRAMEBUFFER, null);
    gl.clearColor(0.8, 0.8, 0.8, 1.0);
    gl.clear(webgl.COLOR_BUFFER_BIT);
    _gallery.draw(viewProjection);      
    _graph.draw(viewProjection);
    if (_dragging.startsWith("line"))
      _line.draw(viewProjection);
    
    //drawPicking();
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
  
  Object getPickObject(int x, int y) {
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
    var target = getPickObject(e.layer.x, e.layer.y);
    _lastMouse = unproject(e.layer.x, e.layer.y);
    
    if (target == null) {
      _dragging = "canvas";
    } else if (target is BaseNode) {
      _dragging    = "node";
      _dragObject  = target;
    } else if (target is Connector) {
      if (!(target as Connector).isOut) {
        _graph.disconnect(target);
      }
      _dragging    = (target as Connector).isOut ? "lineEnd" : "lineStart";
      _dragObject  = target;        
      _line.toPt   = (target as Connector).worldPos;
      _line.fromPt = (target as Connector).worldPos;
      setDirty();
    } else if (target is GalleryNode) {
      var newNodeType = (target as GalleryNode).type;
      var newNode  = _graph.addNode(newNodeType, x:_lastMouse.x, y:_lastMouse.y);
      _dragging    = "node";
      _dragObject  = newNode;
    }
    
    e.preventDefault();
  }

  void onMouseMove(MouseEvent e) {
    var target     = getPickObject(e.layer.x, e.layer.y);
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
        (_dragObject as BaseNode).pos += delta.xy;
        setDirty();
        break;
      case "lineStart":
        if (target is Connector && target.isOut &&
            target.node != (_dragObject as Connector).node) {
          _line.fromPt = (target as Connector).worldPos;
        } else {
          _line.fromPt = worldCoord.xy;          
        }
        setDirty();
        break;
      case "lineEnd":
        if (target is Connector && !target.isOut &&
            target.node != (_dragObject as Connector).node) {
          _line.toPt = (target as Connector).worldPos;
        } else {
          _line.toPt = worldCoord.xy;
        }
        setDirty();
        break;
    }
  }
  
  void onMouseUp(MouseEvent e) {
    var target = getPickObject(e.layer.x, e.layer.y);
    switch (_dragging) {
      case "lineStart":
        if (target is Connector && target.isOut &&
            target.node != (_dragObject as Connector).node) {
          _graph.connect(target, _dragObject);
        }        
        break;
      case "lineEnd":
        if (target is Connector && !target.isOut &&
            target.node != (_dragObject as Connector).node) {
          _graph.connect(_dragObject, target);
        }
        break;
    }
    
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