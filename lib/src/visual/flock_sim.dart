part of Flock;

class FlockSim {
  static Shader _shader;
  static const numParticles = 100;

  Graph graph;
  webgl.Buffer _vbo;
  FrameBuffer _fbo;
  webgl.RenderingContext gl;
  RoundedRect frame;
  Matrix4 modelProj = new Matrix4.identity();
  
  static const int _attrStride = 4;
  Float32List vertAttributes;
  Vector2List vertPosition, vertVelocity; 
  
  FlockSim(this.graph, {double x:0.0, double y:0.0, double w:1.0, double h:1.0}) {
    gl = graph.gl;
    
    if (_shader == null) {
      var vertSource = 
"""
precision mediump int;
precision mediump float;

attribute vec2  aPosition;
uniform mat4    uProj;

void main() {
  gl_PointSize = 4.0;
  gl_Position = uProj * vec4(aPosition, 0.0, 1.0);
}
""";
      
      var fragSource =
"""
#extension GL_OES_standard_derivatives : enable

precision mediump int;
precision mediump float;

void main() {
  gl_FragColor = vec4(1.0, 0.5, 0.5, 1.0);
}
""";
      
      _shader = new Shader(gl, vertSource, fragSource, {'aPosition': 0});
    }
    
    vertAttributes = new Float32List(numParticles * _attrStride);
    vertPosition   = new Vector2List.view(vertAttributes, 0, _attrStride);
    vertVelocity   = new Vector2List.view(vertAttributes, 2, _attrStride);
    var rand = new math.Random();
    for (var i = 0; i < numParticles; i++) {
      vertPosition[i] = new Vector2(rand.nextDouble(), rand.nextDouble());
      vertVelocity[i] = new Vector2(rand.nextDouble()*2.0-1.0, rand.nextDouble()*2.0-1.0);
    }
    
    _fbo = new FrameBuffer(gl, 1024, 1024);
    
    _vbo = gl.createBuffer();
    gl.bindBuffer(webgl.ARRAY_BUFFER, _vbo);
    gl.bufferDataTyped(webgl.ARRAY_BUFFER, vertAttributes, webgl.STATIC_DRAW);
    
    frame = new RoundedRect(gl)
      ..addRect(0.5, 0.5, 1.0, 1.0, edgeThick: 4.0,
          inColor: new Vector4(0.0, 0.0, 0.0, 1.0),
          edgeColor: new Vector4(0.0, 0.4, 0.0, 1.0));
    
    modelProj.translate(x-w*0.5, y-h*0.5);
    modelProj.scale(w, h);
  }
  
  double lastTime = 0.0;
  void animate(double time) {
    var delta = time - lastTime;
    lastTime = time;
    
    for (var i = 0; i < numParticles; i++) {
      vertPosition[i] += vertVelocity[i] * delta * 0.001;
      if (vertPosition[i].x < 0.0 || vertPosition[i].x > 1.0)
        vertVelocity[i] = vertVelocity[i]..x *= -1;
      if (vertPosition[i].y < 0.0 || vertPosition[i].y > 1.0)
        vertVelocity[i] = vertVelocity[i]..y *= -1;
    }
    
    gl.bindBuffer(webgl.ARRAY_BUFFER, _vbo);
    gl.bufferDataTyped(webgl.ARRAY_BUFFER, vertAttributes, webgl.STATIC_DRAW);
  }
  
  void draw(Matrix4 projection, [bool picking = false]) {
    var mvp = projection * modelProj; 
    
    gl.enable(webgl.STENCIL_TEST);
    gl.stencilFunc(webgl.ALWAYS, 1, 0xFF);
    gl.stencilOp(webgl.KEEP, webgl.KEEP, webgl.REPLACE);
    gl.stencilMask(0xFF);
    gl.clear(webgl.STENCIL_BUFFER_BIT);
    frame.draw(mvp);
    gl.stencilMask(0x00);
    gl.stencilFunc(webgl.EQUAL, 1, 0xFF);
    gl.stencilFunc(webgl.ALWAYS, 1, 0xFF);

    _shader.use();
    gl.uniformMatrix4fv(_shader['uProj'], false, mvp.storage);
    
    gl.bindBuffer(webgl.ARRAY_BUFFER, _vbo);
    gl.vertexAttribPointer(0, 2, webgl.FLOAT, false, _attrStride*4, 0);
    gl.enableVertexAttribArray(0);
    gl.drawArrays(webgl.POINTS, 0, numParticles);
    
    gl.disable(webgl.STENCIL_TEST);
  }
}