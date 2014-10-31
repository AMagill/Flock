part of node_graph;

class TextLayout {
  webgl.RenderingContext _gl;
  Matrix4 _modelProj = new Matrix4.identity();
  DistanceField _sdf;
  webgl.Buffer _vbo;
  bool _initialized = false;
  var _layout = new List<Map<String, double>>(); 

  Matrix4 get modelProj => _modelProj;
  set modelProj(Matrix4 val) {
    _modelProj = val;
  }

  TextLayout(this._gl, this._sdf) {
    _vbo = _gl.createBuffer();
  }
  
  void addString(String text, {double scale:1.0, Vector2 position,  
      double hAlign:0.0, double vAlign:0.0, Vector3 color, double threshold:0.5}) {
    if (position == null)
      position = new Vector2(0.0, 0.0);
    
    var cursor = new Vector2.zero();
    var lastGlyph = 0;

    var glyphs   = new List<String>();
    var glyphPos = new List<Vector2>();
    
    for (var ch in text.codeUnits) {
      var glyph   = ch.toString();
      var glyphInfo = _sdf.atlas[glyph];
      final xo = glyphInfo['xoffset'];
      final yo = -glyphInfo['yoffset'];
      
      // Apply kerning
      if (lastGlyph != 0) {
        if (_sdf.atlas[lastGlyph]['kernings'].containsKey(glyph)) {
          var kern = _sdf.atlas[lastGlyph]['kernings'][glyph];
          cursor.x += kern;
        }
      }
      
      glyphs.add(glyph);
      glyphPos.add(position + cursor * scale);
      
      cursor += new Vector2(glyphInfo['xadvance'], 0.0);
      lastGlyph = glyph;
    }
    
    var offset = new Vector2(
        (cursor.x + _sdf.atlas[lastGlyph]['width']) * hAlign, 
        0.0);
    
    for (int i = 0; i < glyphs.length; i++) {
      addGlyph(glyphs[i], scale:scale, position:glyphPos[i] - offset, 
          color:color, threshold:threshold);
    }

  }
  
  void addGlyph(String glyph, {double scale:1.0, Vector2 position, 
      Vector3 color, double threshold:0.5}) {
    if (position == null)
      position = new Vector2.zero();
    if (color == null)
      color = new Vector3.zero();
    
    assert(_sdf.atlas.containsKey(glyph));
    
    var glyphInfo = _sdf.atlas[glyph];
    final x  = glyphInfo['x'];
    final y  = glyphInfo['y'];
    final w  = glyphInfo['width'];
    final h  = glyphInfo['height'];
    final xo = glyphInfo['xoffset'];
    final yo = -glyphInfo['yoffset'];

    _layout.add({
      'pos':        position + new Vector2(xo, yo) * scale,
      'size':       new Vector2(w, h),
      'uv':         new Vector2(x, y),
      'color':      color,
      'scale':      scale,
      'threshold':  threshold,
    });

    _initialized = false; // The VBO is dirty now
  }
  
  void draw(Matrix4 projection) {
    if (!_initialized) {
      if (!_genBuffer()) return;
    }
    
    _sdf.bind();
    
    _gl.bindBuffer(webgl.ARRAY_BUFFER, _vbo);
    _gl.vertexAttribPointer(0, 2, webgl.FLOAT, false, 8*4, 0*4);  // position
    _gl.enableVertexAttribArray(0);
    _gl.vertexAttribPointer(1, 2, webgl.FLOAT, false, 8*4, 2*4);  // uv
    _gl.enableVertexAttribArray(1);
    _gl.vertexAttribPointer(2, 3, webgl.FLOAT, false, 8*4, 4*4);  // color
    _gl.enableVertexAttribArray(2);
    _gl.vertexAttribPointer(3, 1, webgl.FLOAT, false, 8*4, 7*4);  // threshold
    _gl.enableVertexAttribArray(3);

    var mvp = projection * _modelProj;
    _gl.uniformMatrix4fv(DistanceField._shader['uProj'], false, mvp.storage);
    
    _gl.drawArrays(webgl.TRIANGLES, 0, _layout.length*6);
  }
  
  bool _genBuffer() {
    if (_sdf.atlas == null) return false;

    var vi = 0;
    
    // n glyphs * 2 triangles * 3 vertices * 8 attribute elements = n*48
    var vtAttributes = new Float32List(_layout.length * 48);
    var vtPos = new Vector2List.view(vtAttributes, 0, 8);
    var vtTex = new Vector2List.view(vtAttributes, 2, 8);
    var vtCol = new Vector4List.view(vtAttributes, 4, 8);

    var lastCh = 0;
    for (var item in _layout) {
      var pos       = item['pos'];
      var size      = item['size'];
      var uv        = item['uv'];
      var color     = item['color'];
      var scale     = item['scale'];
      var threshold = item['threshold'];
      
      vtPos[vi+0] = pos + new Vector2(0.0,    -size.y) * scale;
      vtPos[vi+1] = pos + new Vector2(size.x, -size.y) * scale;
      vtPos[vi+2] = pos + new Vector2(size.x, 0.0    ) * scale;
      vtPos[vi+3] = pos + new Vector2(0.0,    -size.y) * scale;
      vtPos[vi+4] = pos + new Vector2(size.x, 0.0    ) * scale;
      vtPos[vi+5] = pos + new Vector2(0.0,    0.0    ) * scale;

      vtTex[vi+0] = uv + new Vector2(0.0,    size.y);
      vtTex[vi+1] = uv + new Vector2(size.x, size.y);
      vtTex[vi+2] = uv + new Vector2(size.x, 0.0    );
      vtTex[vi+3] = uv + new Vector2(0.0,    size.y);
      vtTex[vi+4] = uv + new Vector2(size.x, 0.0    );
      vtTex[vi+5] = uv + new Vector2(0.0,    0.0    );
      
      for (var i = 0; i < 6; i++) {
        vtCol[vi+i] = new Vector4(color.x, color.y, color.z, threshold);
        //vtThr[vi+i] = threshold;
      }
      
      vi += 6;
    }
    
    _gl.bindBuffer(webgl.ARRAY_BUFFER, _vbo);
    _gl.bufferDataTyped(webgl.ARRAY_BUFFER, vtAttributes, webgl.STATIC_DRAW);
    
    _initialized = true;
    return true;
  }
}