part of Flock;

class RoundedRect {
  static Shader _shader, _pickShader;
  
  final webgl.RenderingContext gl;
  
  bool _vboDirty = true;
  webgl.Buffer _vbo, _ebo;
  var _rects = [];

  RoundedRect(this.gl) {
    _vbo = gl.createBuffer();
    _ebo = gl.createBuffer();
    
    if (_shader == null) {
      var vertSource = 
"""
precision mediump int;
precision mediump float;

attribute vec2  aPosition;
attribute vec2  aUV;
attribute float aThick;
attribute vec4  aInColor;
attribute vec4  aEdgeColor;
attribute vec3  aPickColor;

varying vec2    vPosition;
varying vec2    vUV;
varying float   vThick;
varying vec4    vInColor;
varying vec4    vEdgeColor;
varying vec3    vPickColor;

uniform mat4    uProj;

void main() {
  gl_Position = uProj * vec4(aPosition, 0.0, 1.0);
  vPosition   = aPosition;
  vUV         = aUV;
  vThick      = aThick;
  vInColor    = aInColor;
  vEdgeColor  = aEdgeColor;
  vPickColor  = aPickColor;
}
""";
      
      var fragSource =
"""
#extension GL_OES_standard_derivatives : enable

precision mediump int;
precision mediump float;

varying vec2    vPosition;
varying vec2    vUV;
varying float   vThick;
varying vec4    vInColor;
varying vec4    vEdgeColor;
varying vec3    vPickColor;

uniform bool    uPicking;

void main() {
  const float EPSILON = 0.000001;

  if (uPicking)
  {
    gl_FragColor = vec4(vPickColor, 1.0);
  }
  else
  {
    float upp = max(fwidth(vUV.x), fwidth(vUV.y)); // Units per pixel
    float len = length(vUV);

    float outFactor  = smoothstep(1.0-upp, 1.0, len);
    float edgeFactor = smoothstep(1.0-upp*(vThick+1.0), 1.0-upp*vThick, len);

    gl_FragColor     =  mix(vInColor, vEdgeColor, edgeFactor);
    gl_FragColor.a  *= (1.0 - outFactor);
  }
}
""";
      
      _shader = new Shader(gl, vertSource, fragSource, 
          {'aPosition': 0, 'aUV': 1, 'aThick': 2, 
           'aInColor': 3, 'aEdgeColor': 4, 'aPickColor': 5});
    }
  }
  
  void draw(Matrix4 projection, [bool picking = false]) {
    if (_vboDirty) {
      if (!_genBuffer()) return;
    }
    
    _shader.use();
    gl.uniformMatrix4fv(_shader['uProj'], false, projection.storage);
    gl.uniform1i(_shader['uPicking'], picking?1:0);

    gl.bindBuffer(webgl.ARRAY_BUFFER, _vbo);
    final stride = 16 * 4;
    gl.vertexAttribPointer(0, 2, webgl.FLOAT, false, stride, 0*4);  // position
    gl.enableVertexAttribArray(0);
    gl.vertexAttribPointer(1, 2, webgl.FLOAT, false, stride, 2*4);  // UV
    gl.enableVertexAttribArray(1);
    gl.vertexAttribPointer(2, 1, webgl.FLOAT, false, stride, 4*4);  // thick
    gl.enableVertexAttribArray(2);
    gl.vertexAttribPointer(3, 4, webgl.FLOAT, false, stride, 5*4);  // inColor
    gl.enableVertexAttribArray(3);
    gl.vertexAttribPointer(4, 4, webgl.FLOAT, false, stride, 9*4);  // edgeColor
    gl.enableVertexAttribArray(4);
    gl.vertexAttribPointer(5, 3, webgl.FLOAT, false, stride, 13*4); // pickColor
    gl.enableVertexAttribArray(5);
    gl.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, _ebo);
    
    gl.drawElements(webgl.TRIANGLES, _rects.length * 54, webgl.UNSIGNED_SHORT, 0);
  }
  
  void addRect(double x, double y, double w, double h, 
    {radius:0.05, edgeThick:1.0, inColor, edgeColor, pickColor}) {
    _rects.add({
      'pos':        new Vector2(x, y),
      'size':       new Vector2(w, h),
      'radius':     radius,
      'thick':      edgeThick,
      'inColor':    (inColor  !=null) ? inColor   : new Vector4(0.5, 0.5, 0.5, 1.0),
      'edgeColor':  (edgeColor!=null) ? edgeColor : new Vector4(0.0, 0.0, 0.0, 1.0),
      'pickColor':  (pickColor!=null) ? pickColor : new Vector3(0.0, 0.0, 0.0),
    });
    _vboDirty = true;
  }
  
  bool _genBuffer() {
    if (_rects.length == 0) return false;
    
    final stride = 16;
    var vtAttributes  = new Float32List(_rects.length * stride * 16);
    var vtPos         = new Vector2List.view(vtAttributes, 0, stride);
    var vtUV          = new Vector2List.view(vtAttributes, 2, stride);
    // float thick                1                        4
    var vtInColor     = new Vector4List.view(vtAttributes, 5, stride);
    var vtEdgeColor   = new Vector4List.view(vtAttributes, 9, stride);
    var vtPickColor   = new Vector3List.view(vtAttributes, 13, stride);
    var vtElements    = new Uint16List(_rects.length * 54);
    
    var vi = 0, ei = 0, ri = 0;
    for (var rect in _rects) {
      final pos       = rect['pos'];
      final size      = rect['size'];
      final radius    = rect['radius'];
      final thick     = rect['thick'];
      final inColor   = rect['inColor'];
      final edgeColor = rect['edgeColor'];
      final pickColor = rect['pickColor'];

      final uo = [-1.0, 0.0, 0.0, 1.0];
      final xo = [new Vector2(-0.5*size.x, 0.0),          
                  new Vector2(-0.5*size.x+radius, 0.0), 
                  new Vector2( 0.5*size.x-radius, 0.0), 
                  new Vector2( 0.5*size.x, 0.0)];
      final yo = [new Vector2(0.0, -0.5*size.y),          
                  new Vector2(0.0, -0.5*size.y+radius), 
                  new Vector2(0.0,  0.5*size.y-radius), 
                  new Vector2(0.0,  0.5*size.y)];

      for (var y = 0; y < 4; y++) {
        for (var x = 0; x < 4; x++) {
          vtPos[vi] = pos + xo[x] + yo[y];
          vtUV[vi]  = new Vector2(uo[x], uo[y]);
          vtAttributes[vi*stride+4] = thick;
          vtInColor[vi]   = inColor;
          vtEdgeColor[vi] = edgeColor;
          vtPickColor[vi] = pickColor;
          vi++;
        }
      }
      
      final seq = [0, 1, 4,   4, 1, 5];
      for (var y = 0; y < 3; y++) {
        for (var x = 0; x < 3; x++) {
          for (var z = 0; z < 6; z++) {
            vtElements[ei++] = seq[z] + x + 4*y + 16*ri;            
          }
        }
      }
      
      ri++;
    }

    gl.bindBuffer(webgl.ARRAY_BUFFER, _vbo);
    gl.bufferDataTyped(webgl.ARRAY_BUFFER, vtAttributes, webgl.STATIC_DRAW);
    gl.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, _ebo);
    gl.bufferDataTyped(webgl.ELEMENT_ARRAY_BUFFER, vtElements, webgl.STATIC_DRAW);

    _vboDirty = false;
    return true;
  }
}
