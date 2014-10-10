part of node_graph;

class RoundedRect {
  static webgl.Buffer _vboQuad;
  static webgl.Texture _texture;
  static Shader _shader;
  
  webgl.RenderingContext _gl;
  Vector2 _size, _position;
  double _radius = 0.1;
  
  RoundedRect(this._gl, [this._size, this._position]) {
    // Set default parameter values
    if (_size == null) {
      _size     = new Vector2(1.0, 1.0);
    }
    if (_position == null) {
      _position = new Vector2(0.0, 0.0);
    }

    // Initialize the static variables, if they haven't already
    if (_vboQuad == null) {
      var verts = new Float32List.fromList([
        1.0, -1.0,   1.0, 1.0,   -1.0, -1.0,   -1.0, 1.0]);
      
      _vboQuad = _gl.createBuffer();
      _gl.bindBuffer(webgl.ARRAY_BUFFER, _vboQuad);
      _gl.bufferDataTyped(webgl.ARRAY_BUFFER, verts, webgl.STATIC_DRAW);
    }
    
    if (_texture == null) {
      const size = 64;
      var pixels = new Uint8List(4 * size);
      var i = 0;
      while (i < 4*60) {
        pixels[i++] = 0x80;
        pixels[i++] = 0x80;
        pixels[i++] = 0x80;
        pixels[i++] = 0xFF;
      }
      while (i < 4*63) {
        pixels[i++] = 0x00;
        pixels[i++] = 0x00;
        pixels[i++] = 0x00;        
        pixels[i++] = 0xFF;
      }
      while (i < 4*64) {
        pixels[i++] = 0x00;
        pixels[i++] = 0x00;
        pixels[i++] = 0x00;        
        pixels[i++] = 0x00;
      }
      
      _texture = _gl.createTexture();
      _gl.bindTexture(webgl.TEXTURE_2D, _texture);
      _gl.texParameteri(webgl.TEXTURE_2D, webgl.TEXTURE_MIN_FILTER, webgl.LINEAR);
      _gl.texParameteri(webgl.TEXTURE_2D, webgl.TEXTURE_MAG_FILTER, webgl.LINEAR);
      _gl.texParameteri(webgl.TEXTURE_2D, webgl.TEXTURE_WRAP_S, webgl.CLAMP_TO_EDGE);
      _gl.texParameteri(webgl.TEXTURE_2D, webgl.TEXTURE_WRAP_T, webgl.CLAMP_TO_EDGE);
      _gl.texImage2DTyped(webgl.TEXTURE_2D, 0, webgl.RGBA, 1, size, 0, webgl.RGBA, 
          webgl.UNSIGNED_BYTE, pixels);
    }
    
    if (_shader == null) {
      var vertSource = 
"""
precision mediump int;
precision mediump float;

attribute vec2  aPosition;
varying vec2    vPosition;
uniform vec2    uSize, uPosition;

void main() {
  gl_Position = vec4(aPosition * uSize * 0.5 + uPosition, 0.0, 1.0);
  vPosition   = aPosition;
}
""";
      
      var fragSource =
"""
precision mediump int;
precision mediump float;

varying vec2      vPosition;
uniform vec2      uSize, uPosition;
uniform float     uRadius;
uniform sampler2D uTexture;

void main() {
  vec2 rad = uRadius / uSize * 2.0;
  vec2 cornerPos  = sign(vPosition) *  
    max(((abs(vPosition) - (1.0 - rad)) / rad), vec2(0.0)); 

  float len = length(cornerPos.xy);
  gl_FragColor = texture2D(uTexture, vec2(0.5, len));
}
""";
      
      _shader = new Shader(_gl, vertSource, fragSource, {'aPosition': 0});
    }
  }
  
  void draw() {
    _shader.use();
    _gl.uniform2fv(_shader['uSize'],     _size.storage);
    _gl.uniform2fv(_shader['uPosition'], _position.storage);
    _gl.uniform1f( _shader['uRadius'],   0.1);
    _gl.uniform1i( _shader['uTexture'],  0);

    _gl.bindBuffer(webgl.ARRAY_BUFFER, _vboQuad);
    _gl.vertexAttribPointer(0, 2, webgl.FLOAT, false, 0, 0);
    _gl.enableVertexAttribArray(0);
    
    _gl.bindTexture(webgl.TEXTURE_2D, _texture);

    _gl.drawArrays(webgl.TRIANGLE_STRIP, 0, 4);
  }
}