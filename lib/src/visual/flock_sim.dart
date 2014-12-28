part of Flock;

class FlockSim {
  static Shader _shader;

  Graph graph;
  webgl.Buffer _vbo;
  webgl.RenderingContext gl;
  
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
    
    var vertices = new Float32List.fromList([
      x-w*0.5, y-h*0.5,    x+w*0.5, y-h*0.5,
      x-w*0.5, y+h*0.5,    x+w*0.5, y+h*0.5]);
    _vbo = gl.createBuffer();
    gl.bindBuffer(webgl.ARRAY_BUFFER, _vbo);
    gl.bufferDataTyped(webgl.ARRAY_BUFFER, vertices, webgl.STATIC_DRAW);
  }  
  
  void draw(Matrix4 projection, [bool picking = false]) {
    _shader.use();
    gl.uniformMatrix4fv(_shader['uProj'], false, projection.storage);
    
    gl.bindBuffer(webgl.ARRAY_BUFFER, _vbo);
    gl.vertexAttribPointer(0, 2, webgl.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(0);
    gl.drawArrays(webgl.TRIANGLE_STRIP, 0, 4);
    
  }
}