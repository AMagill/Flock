part of node_graph;

class TextLayout {
  webgl.RenderingContext _gl;
  Vector2 _position = new Vector2(0.0, 0.0);
  double _size, _hAlign, _vAlign;
  String _text;
  DistanceField _sdf;
  webgl.Buffer _vbo;
  bool _initialized = false;
  
  String get text => _text;
  set text(String val) {
    _text = val;
    _layout();
  }
  
  double get size => _size;
  set size(double val) {
    _size = val;
    //_layout();
  }
  
  Vector2 get position => _position;
  set position(Vector2 val) {
    _position = val;
    _layout();
  }

  double get hAlign => _hAlign;
  set hAlign(double val) {
    _hAlign = val;
    _layout();
  }
  
  double get vAlign => _vAlign;
  set vAlign(double val) {
    _vAlign = val;
    _layout();
  }
  
  TextLayout(this._gl, this._sdf, [this._text="", this._size=1.0, 
      this._position, this._hAlign=0.0, this._vAlign=0.0]) {
    
    //_sdf.onLoad.listen((_) => _layout());
    _vbo = _gl.createBuffer();
    if (_sdf.atlas != null) {
      _layout();
    }
  }
  
  void draw() {
    if (!_initialized) {
      if (!_layout()) return;
    }
    
    _sdf.bind();
    
    _gl.bindBuffer(webgl.ARRAY_BUFFER, _vbo);
    _gl.vertexAttribPointer(0, 2, webgl.FLOAT, false, 16, 0);
    _gl.enableVertexAttribArray(0);
    _gl.vertexAttribPointer(1, 2, webgl.FLOAT, false, 16, 8);
    _gl.enableVertexAttribArray(1);

    _size = 0.25;
    _gl.uniform1f(DistanceField._shader['uSize'], _size);
    
    _gl.drawArrays(webgl.TRIANGLES, 0, 6);
  }
  
  bool _layout() {
    if (_sdf.atlas == null) return false;
    
    var vtAttributes = new Float32List(24);
    var vtPos = new Vector2List.view(vtAttributes, 0, 4);
    var vtTex = new Vector2List.view(vtAttributes, 2, 4);
    var size = 1.0;
    vtPos[0] = new Vector2(-size, -size);
    vtPos[1] = new Vector2( size, -size);
    vtPos[2] = new Vector2( size,  size);
    vtPos[3] = new Vector2(-size, -size);
    vtPos[4] = new Vector2( size,  size);
    vtPos[5] = new Vector2(-size,  size);
    
    var glyphIdx  = '83';
    var glyphPos  = new Vector2(_sdf.atlas[glyphIdx]['x'],     _sdf.atlas[glyphIdx]['y']);
    var glyphSize = new Vector2(_sdf.atlas[glyphIdx]['width'], _sdf.atlas[glyphIdx]['height']);
    vtTex[0] = glyphPos + new Vector2(0.0, glyphSize.y);
    vtTex[1] = glyphPos + glyphSize;
    vtTex[2] = glyphPos + new Vector2(glyphSize.x, 0.0);
    vtTex[3] = glyphPos + new Vector2(0.0, glyphSize.y);
    vtTex[4] = glyphPos + new Vector2(glyphSize.x, 0.0);
    vtTex[5] = glyphPos;
    
    _gl.bindBuffer(webgl.ARRAY_BUFFER, _vbo);
    _gl.bufferDataTyped(webgl.ARRAY_BUFFER, vtAttributes, webgl.STATIC_DRAW);
    
    _initialized = true;
    return true;
  }
}