part of Flock;

class Bezier {
  static webgl.Buffer _vboLine;
  static Shader _shader;
  
  webgl.RenderingContext _gl;
  Vector2List _points;
  int _divisions, _nLines;
  double _thick;
  Matrix4 _modelProj = new Matrix4.identity();
  
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
  
  Bezier(this._gl, [this._points = null, this._thick = 0.01, this._divisions = 16]) {
    if (this._divisions < 1)
      throw new ArgumentError('Divisions must be greater than zero.');
    
    if (_shader == null) {
      var vertSource = 
"""
precision mediump int;
precision mediump float;

attribute vec2  aPosition;
uniform   mat4  uProj;

void main() {
  gl_Position = uProj * vec4(aPosition, 0.0, 1.0);
}
""";
      
      var fragSource =
"""
precision mediump int;
precision mediump float;

void main() {
  gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}
""";
      
      _shader = new Shader(_gl, vertSource, fragSource, {'aPosition': 0});
    }
    
    _vboLine = _gl.createBuffer();
    _generateBuffer();
  }
  
  void draw(Matrix4 projection) {
    _shader.use();

    _gl.lineWidth(4.0);
    
    _gl.bindBuffer(webgl.ARRAY_BUFFER, _vboLine);
    _gl.vertexAttribPointer(0, 2, webgl.FLOAT, false, 0, 0);
    _gl.enableVertexAttribArray(0);
    
    var mvp = projection * _modelProj;
    _gl.uniformMatrix4fv(_shader['uProj'], false, mvp.storage);
    
    _gl.drawArrays(webgl.TRIANGLES, 0, _nLines * 6);
  }
  
  void _generateBuffer() {
    var nSegments = (_points == null) ? 0 : _points.length ~/ 4;
    _nLines = nSegments * _divisions;
    var vertices = new Vector2List(_nLines * 6);

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
      
      Vector2 pt0, pt1;
      for (var j = 0; j <= _divisions; j++) {
        var t = j / _divisions;
        
        var pos  = a*(t*t*t) + b*(t*t) + c*t + d;
        var tan  = a*(t*t*3.0) + b*(t*2.0) + c;
        tan.normalize();
        var norm = new Vector2(-tan.y, tan.x);
        
        var pt2 = pos - norm * (_thick * 0.5);
        var pt3 = pos + norm * (_thick * 0.5);
        
        if (j > 0) {
          vertices[k++] = pt0; 
          vertices[k++] = pt1;
          vertices[k++] = pt2;

          vertices[k++] = pt0; 
          vertices[k++] = pt2;
          vertices[k++] = pt3;
        }

        pt0 = pt3;
        pt1 = pt2;
      }
    }
    
    _gl.bindBuffer(webgl.ARRAY_BUFFER, _vboLine);
    _gl.bufferDataTyped(webgl.ARRAY_BUFFER, vertices.buffer, webgl.STATIC_DRAW);
  }
  
  
}
