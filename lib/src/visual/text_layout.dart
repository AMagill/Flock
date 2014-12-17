part of Flock;

class TextLayout {
  final DistanceField _sdf;
  final webgl.RenderingContext gl;

  Matrix4 _modelProj = new Matrix4.identity();
  webgl.Buffer _vbo;
  var _strings = [], _layout = null;
  var _vboDirty = true;

  Matrix4 get modelProj => _modelProj;
  set modelProj(Matrix4 val) {
    _modelProj = val;
  }

  TextLayout(this.gl, this._sdf) {
    _vbo = gl.createBuffer();
  }
  
  void addString(String text, {double scale:1.0, double x:0.0, double y:0.0,  
    double hAlign:0.5, double vAlign:0.5, double r:0.0, double g:0.0, double b:0.0, 
    double threshold:0.5}) {
    
    _strings.add({
      "text":       text,
      "scale":      scale,
      "pos":        new Vector2(x, y),
      "hAlign":     hAlign,
      "vAlign":     vAlign,
      "color":      new Vector3(r, g, b),
      "threshold":  threshold,
    });
    
    _layout = null; // Dirty
  }
    
  void draw(Matrix4 projection, [bool picking = false]) {
    if (_layout == null) {
      if (!_genLayout()) return;
    }
    if (_vboDirty) {
      if (!_genBuffer()) return;
    }
    
    _sdf.bind();
    
    gl.bindBuffer(webgl.ARRAY_BUFFER, _vbo);
    gl.vertexAttribPointer(0, 2, webgl.FLOAT, false, 8*4, 0*4);  // position
    gl.enableVertexAttribArray(0);
    gl.vertexAttribPointer(1, 2, webgl.FLOAT, false, 8*4, 2*4);  // uv
    gl.enableVertexAttribArray(1);
    gl.vertexAttribPointer(2, 3, webgl.FLOAT, false, 8*4, 4*4);  // color
    gl.enableVertexAttribArray(2);
    gl.vertexAttribPointer(3, 1, webgl.FLOAT, false, 8*4, 7*4);  // threshold
    gl.enableVertexAttribArray(3);

    var mvp = projection * _modelProj;
    gl.uniformMatrix4fv(DistanceField._shader['uProj'], false, mvp.storage);
    
    gl.drawArrays(webgl.TRIANGLES, 0, _layout.length*6);
  }
  
  
  bool _genLayout() {
    if (_sdf.atlas == null) return false;

    _layout = [];
    
    for (var str in _strings) {
      if (_strings.length == 0)
        continue;
      
      var cursor = new Vector2.zero();
      var firstGlyphInfo = null, lastGlyphInfo = null;
  
      var glyphs   = new List<String>();
      var glyphPos = new List<Vector2>();
      
      for (var ch in str['text'].codeUnits) {
        var glyph     = ch.toString();
        var glyphInfo = _sdf.atlas[glyph];
        if (firstGlyphInfo == null)
          firstGlyphInfo = glyphInfo;
        
        // Apply kerning
        if (lastGlyphInfo != null) {
          if (lastGlyphInfo['kernings'].containsKey(glyph)) {
            var kern = lastGlyphInfo['kernings'][glyph];
            cursor.x += kern;
          }
        }
        
        glyphs.add(glyph);
        glyphPos.add(cursor);
        
        cursor += new Vector2(glyphInfo['xadvance'], 0.0);
        lastGlyphInfo = glyphInfo;
      }
      
      var offset = new Vector2(
          cursor.x * str['hAlign'], 
          0.0);
      
      
      for (int i = 0; i < glyphs.length; i++) {
        _layoutGlyph(glyphs[i], scale:str['scale'], 
            position: str['pos'] + (glyphPos[i] - offset) * str['scale'], 
            color:str['color'], threshold:str['threshold']);
      }
    }
    
    return true;
  }
  
  void _layoutGlyph(String glyph, {double scale:1.0, Vector2 position, 
      Vector3 color, double threshold:0.5}) {
    if (position == null)
      position = new Vector2.zero();
    if (color == null)
      color = new Vector3.zero();
    
    assert(_sdf.atlas.containsKey(glyph));
    
    var glyphInfo = _sdf.atlas[glyph];
    final uvx = glyphInfo['uvx'];
    final uvy = glyphInfo['uvy'];
    final uvw = glyphInfo['uvw'];
    final uvh = glyphInfo['uvh'];
    final w   = glyphInfo['width'];
    final h   = glyphInfo['height'];
    final xo  = glyphInfo['xoffset'];
    final yo  = glyphInfo['yoffset'] * -1;

    _layout.add({
      'pos':        position + new Vector2(xo, yo) * scale,
      'size':       new Vector2(w, h),
      'uvpos':      new Vector2(uvx, uvy),
      'uvsize':     new Vector2(uvw, uvh),
      'color':      color,
      'scale':      scale,
      'threshold':  threshold,
    });
    
    _vboDirty = true;
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
      var uvpos     = item['uvpos'];
      var uvsize    = item['uvsize'];
      var color     = item['color'];
      var scale     = item['scale'];
      var threshold = item['threshold'];
      
      vtPos[vi+0] = pos + new Vector2(0.0,    -size.y) * scale;
      vtPos[vi+1] = pos + new Vector2(size.x, -size.y) * scale;
      vtPos[vi+2] = pos + new Vector2(size.x, 0.0    ) * scale;
      vtPos[vi+3] = pos + new Vector2(0.0,    -size.y) * scale;
      vtPos[vi+4] = pos + new Vector2(size.x, 0.0    ) * scale;
      vtPos[vi+5] = pos + new Vector2(0.0,    0.0    ) * scale;

      vtTex[vi+0] = uvpos + new Vector2(0.0,      uvsize.y);
      vtTex[vi+1] = uvpos + new Vector2(uvsize.x, uvsize.y);
      vtTex[vi+2] = uvpos + new Vector2(uvsize.x, 0.0    );
      vtTex[vi+3] = uvpos + new Vector2(0.0,      uvsize.y);
      vtTex[vi+4] = uvpos + new Vector2(uvsize.x, 0.0    );
      vtTex[vi+5] = uvpos + new Vector2(0.0,      0.0    );
      
      for (var i = 0; i < 6; i++) {
        vtCol[vi+i] = new Vector4(color.r, color.g, color.b, threshold);
        //vtThr[vi+i] = threshold;
      }
      
      vi += 6;
    }
    
    gl.bindBuffer(webgl.ARRAY_BUFFER, _vbo);
    gl.bufferDataTyped(webgl.ARRAY_BUFFER, vtAttributes, webgl.STATIC_DRAW);

    _vboDirty = false;
    return true;
  }
}