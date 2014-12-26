part of Flock;

class Scene {
  int width, height;
  webgl.RenderingContext gl;
  FrameBuffer pickBuf;
  StreamController _onDirtyController = new StreamController(); 
  Camera camera = new Camera();
  
  Graph _graph;
  ConnectionLine _line;
  NodeGallery _gallery;
  
  String _dragging = "";
  Object _dragObject;
  Vector2 _lastMouse = new Vector2.zero();
  
  Stream get onDirty => _onDirtyController.stream;
  
  Scene(this.gl, this.width, this.height) {
    pickBuf = new FrameBuffer(gl, width, height);
    
    camera.aspect = width / height;

    var sdfText = new DistanceField(gl);
    sdfText.loadUrl('/packages/Flock/fonts/font.png',
                    '/packages/Flock/fonts/font.json')
      ..then((_) => setDirty());

    _graph = new Graph(gl);
    _graph.outputNode = _graph.addNode("birdoutput", x:0.8, y:0.0);
    _line = new ConnectionLine(gl);
    
    _gallery = new NodeGallery(_graph, 
        ["addition","subtraction","multiplication","division","birdinput"], 
        1, x:-0.75);
    
    gl.viewport(0, 0, width, height);
    gl.enable(webgl.BLEND);
    gl.blendFunc(webgl.SRC_ALPHA, webgl.ONE_MINUS_SRC_ALPHA);
  }
  
  void animate(double time) {
    
  }
  
  void draw() {
    void drawPicking() {
      gl.clearColor(0.0, 0.0, 0.0, 1.0);
      gl.clear(webgl.COLOR_BUFFER_BIT);
      _gallery.draw(camera.projection, true);      
      _graph.draw(camera.projection, true);      
    }
    
    gl.bindFramebuffer(webgl.FRAMEBUFFER, pickBuf.fbo);
    drawPicking();
    
    gl.bindFramebuffer(webgl.FRAMEBUFFER, null);
    gl.clearColor(0.8, 0.8, 0.8, 1.0);
    gl.clear(webgl.COLOR_BUFFER_BIT);
    _gallery.draw(camera.projection);      
    _graph.draw(camera.projection);
    if (_dragging.startsWith("line"))
      _line.draw(camera.projection);
    
    //drawPicking();
  }
  
  void resize(int width, int height) {
    this.width  = width;
    this.height = height;
    gl.viewport(0, 0, width, height);
    pickBuf.resize(width, height);
    camera.aspect = width / height;
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
  
  void onMouseDown(MouseEvent e) {
    var target = getPickObject(e.layer.x, e.layer.y);
    _lastMouse = camera.unproject(e.layer.x/width, e.layer.y/height);
    
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
    var worldCoord = camera.unproject(e.layer.x/width, e.layer.y/height);
    var delta      = worldCoord - _lastMouse;
    _lastMouse     = worldCoord;
    bool badLine   = false;
    bool dirty     = false;
    
    switch (_dragging) {
      case "canvas":
        camera.center -= delta;
        _lastMouse -= delta;
        dirty = true;
        break;
      case "node":
        (_dragObject as BaseNode).pos += delta.xy;
        dirty = true;
        break;
      case "lineStart":
        if (target is Connector && target.isOut &&
            target.node != (_dragObject as Connector).node) {
          // Snap to
          _line.fromPt = (target as Connector).worldPos;
          badLine = !_graph.sortNodes(target.node, 
            (_dragObject as Connector).node);
        } else {
          _line.fromPt = worldCoord.xy;          
        }
        dirty = true;
        break;
      case "lineEnd":
        if (target is Connector && !target.isOut &&
            target.node != (_dragObject as Connector).node) {
          // Snap to
          _line.toPt = (target as Connector).worldPos;
          badLine = !_graph.sortNodes((_dragObject as Connector).node,
              target.node);
        } else {
          _line.toPt = worldCoord.xy;
        }
        dirty = true;
        break;
    }
    
    if (badLine) {
      _line.color = new Vector4(1.0, 0.0, 0.0, 1.0);
    } else {
      _line.color = new Vector4(0.0, 0.0, 0.0, 1.0);
    }
    
    if (dirty) 
      setDirty();
  }
  
  void onMouseUp(MouseEvent e) {
    var target = getPickObject(e.layer.x, e.layer.y);
    switch (_dragging) {
      case "lineStart":
        if (target is Connector && target.isOut &&
            target.node != (_dragObject as Connector).node &&
            _graph.sortNodes(target.node, (_dragObject as Connector).node)) {
            _graph.connect(target, _dragObject);
        }        
        break;
      case "lineEnd":
        if (target is Connector && !target.isOut &&
            target.node != (_dragObject as Connector).node &&
            _graph.sortNodes((_dragObject as Connector).node, target.node)) {
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
    var worldCoord = camera.unproject(e.layer.x/width, e.layer.y/height);
    camera.zoomBy(e.wheelDeltaY / 200.0, center:worldCoord);
    setDirty();
  }
}