part of Flock;

class Scene {
  int width, height;
  webgl.RenderingContext gl;
  FrameBuffer pickBuf;
  StreamController _onDirtyController = new StreamController(); 
  
  Graph _graph;
  Bezier _bezier;
  
  Stream get onDirty => _onDirtyController.stream;
  
  Scene(this.gl, this.width, this.height) {
    pickBuf = new FrameBuffer(gl, width, height);

    var sdfText = new DistanceField(gl);
    sdfText.loadUrl('/packages/Flock/fonts/font.png',
                    '/packages/Flock/fonts/font.json')
      ..then((_) => setDirty());

    _graph = new Graph(gl)
      ..addNode("addition", x:0.0, y:0.0);
    _bezier = new Bezier(gl, new Vector2List.fromList([
      new Vector2(0.0, -0.1), new Vector2(0.0, 0.0),
      new Vector2(0.5, -0.5), new Vector2(0.5, 0.0)]));

    
    gl.enable(webgl.BLEND);
    gl.blendFunc(webgl.SRC_ALPHA, webgl.ONE_MINUS_SRC_ALPHA);
    gl.clearColor(0.8, 0.8, 0.8, 1.0);
    
  }
  
  void animate(double time) {
    
  }
  
  void draw(Matrix4 proj) {
    gl.clear(webgl.COLOR_BUFFER_BIT);
    
    gl.bindFramebuffer(webgl.FRAMEBUFFER, pickBuf.fbo);
    _graph.draw(proj, true);
    
    gl.bindFramebuffer(webgl.FRAMEBUFFER, null);
    _graph.draw(proj);
    _bezier.draw(proj);
  }
  
  void setDirty() {
    if (_onDirtyController.hasListener && !_onDirtyController.isPaused)
      _onDirtyController.add(null);
  }
  
  String getPickTarget(int x, int y) {
    var pixel = new Uint8List(4);
    pixel[1] = 42;
    
    gl.bindFramebuffer(webgl.FRAMEBUFFER, pickBuf.fbo);
    gl.readPixels(x, y, 1, 1, webgl.RGBA, webgl.UNSIGNED_BYTE, pixel);
    gl.bindFramebuffer(webgl.FRAMEBUFFER, null);
    
   return new PickTable().lookup(pixel);
  }

  void onMouseDown(int x, int y) {
    var target = getPickTarget(x, y);
    print("MouseDown: ($x, $y)  Target: $target");
  }

  void onMouseUp(int x, int y) {
  }

  void onMouseMove(int x, int y) {
  }
  
  void onMouseOut() {
  }
}