part of Flock;

class Bezier {
  static Shader _shader;
  
  webgl.Buffer _vbo, _ebo;
  webgl.RenderingContext _gl;
  Vector2List _points;
  int _divisions, _nLines, _nIndices;
  double _thick;
  Matrix4 _modelProj = new Matrix4.identity();
  Vector4 color;
  
  get points => _points;
  set points(Vector2List newPts) {
    _points = newPts;
    _generateBuffer();
  }
  
  get thick => _thick;
  set thick(double newThick) {
    _thick = newThick;
    _generateBuffer();
  }

  get divisions => _divisions;
  set divisions(int newDivs) {
    _divisions = newDivs;
    _generateBuffer();
  }
  
  Bezier(this._gl, [this._points = null, this._thick = 0.03, this._divisions = 32]) {
    if (this._divisions < 1)
      throw new ArgumentError('Divisions must be greater than zero.');
    
    if (_shader == null) {
      var vertSource = 
"""
precision mediump int;
precision mediump float;

attribute vec2  aPosition;
attribute vec2  aUV;
varying   vec2  vUV;
uniform   mat4  uProj;

void main() {
  gl_Position = uProj * vec4(aPosition, 0.0, 1.0);
  vUV = aUV;
}
""";
      
      var fragSource =
"""
#extension GL_OES_standard_derivatives : enable

precision mediump int;
precision mediump float;

uniform vec4 uColor;
varying vec2 vUV;

void main() {
  float upp = fwidth(vUV.x);
  float aa  = smoothstep(1.0, 1.0-upp, abs(vUV.x));
  gl_FragColor = uColor;
  gl_FragColor.a *= aa;
}
""";
      
      _shader = new Shader(_gl, vertSource, fragSource, {'aPosition': 0, 'aUV': 1});
    }
    
    color = new Vector4(0.0, 0.0, 0.0, 1.0);
    
    _vbo = _gl.createBuffer();
    _ebo = _gl.createBuffer();
    _generateBuffer();
  }
  
  void draw(Matrix4 projection, [bool picking = false]) {
    _shader.use();

    _gl.lineWidth(4.0);
    
    _gl.bindBuffer(webgl.ARRAY_BUFFER, _vbo);
    _gl.vertexAttribPointer(0, 2, webgl.FLOAT, false, 4*4, 0*4);
    _gl.vertexAttribPointer(1, 2, webgl.FLOAT, false, 4*4, 2*4);
    _gl.enableVertexAttribArray(0);
    _gl.enableVertexAttribArray(1);
    _gl.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, _ebo);
    
    var mvp = projection * _modelProj;
    _gl.uniformMatrix4fv(_shader['uProj'], false, mvp.storage);
    
    _gl.uniform4fv(_shader['uColor'], color.storage);
    
    _gl.drawElements(webgl.TRIANGLE_STRIP, _nIndices, webgl.UNSIGNED_SHORT, 0);
  }
  
  void _generateBuffer() {
    var nSegments = (_points == null) ? 0 : _points.length ~/ 4;
    _nLines = nSegments * _divisions;
    var vtAttributes = new Float32List((_nLines+1)*12);
    var vtPos = new Vector2List.view(vtAttributes, 0, 4);
    var vtUV  = new Vector2List.view(vtAttributes, 2, 4);

    var k = 0;
    for (var i = 0; i < nSegments; i++) {
      // Cubic interpoloation curves
      var p0 = _points[i*4+0];
      var p1 = _points[i*4+1];
      var p2 = _points[i*4+3];
      var p3 = _points[i*4+2];
      var a = -p0     + p1*3.0 - p2*3.0 + p3;
      var b =  p0*3.0 - p1*6.0 + p2*3.0;
      var c = -p0*3.0 + p1*3.0;
      var d =  p0;
      
      for (var j = 0; j <= _divisions; j++) {
        var t = j / _divisions;
        
        var pos  = ((a*t + b)*t + c)*t + d;
        var tan  = (a*t*3.0 + b*2.0)*t + c;
        tan.normalize();
        var norm = new Vector2(-tan.y, tan.x);
        
        vtPos[k] = pos - norm * (_thick * 0.5);   vtUV[k++] = new Vector2(-1.0, 0.0); 
        vtPos[k] = pos;                           vtUV[k++] = new Vector2( 0.0, 0.0);
        vtPos[k] = pos + norm * (_thick * 0.5);   vtUV[k++] = new Vector2( 1.0, 0.0);
      }
    }
    
    // The indices will be arranged as two strips separated by a pair of degenerates.
    _nIndices = nSegments*_divisions*4+6;
    var indices = new Uint16List(_nIndices);
    k = 0;
    // Left strip
    for (var i = 0; i <= nSegments*_divisions; i++) {
      indices[k++] = i*3+0;
      indices[k++] = i*3+1;
    }
    // Degenerate terminators
    indices[k]   = indices[k-1]; k++;
    indices[k++] = 1;
    // Right strip
    for (var i = 0; i <= nSegments*_divisions; i++) {
      indices[k++] = i*3+1;
      indices[k++] = i*3+2;
    }
    
    _gl.bindBuffer(webgl.ARRAY_BUFFER, _vbo);
    _gl.bufferDataTyped(webgl.ARRAY_BUFFER, vtAttributes, webgl.STATIC_DRAW);
    _gl.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, _ebo);
    _gl.bufferDataTyped(webgl.ELEMENT_ARRAY_BUFFER, indices, webgl.STATIC_DRAW);
  }
  
  
}
