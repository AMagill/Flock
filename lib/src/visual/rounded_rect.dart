part of node_graph;

class RoundedRect {
  static webgl.Buffer _vboQuad;
  static webgl.Texture _texture;
  static Shader _shader;
  
  webgl.RenderingContext _gl;
  Vector2 size, position;
  double radius, edgeThick;
  Vector4 inColor, edgeColor;
  Matrix4 _modelProj = new Matrix4.identity();
  
  RoundedRect(this._gl, {this.size, this.position, this.radius:0.05, 
    this.edgeThick:1.0, this.inColor, this.edgeColor}) {
    if (size == null)
      size = new Vector2(1.0, 1.0);
    if (position == null)
      position = new Vector2(0.0, 0.0);
    if (inColor == null)
      inColor   = new Vector4(0.5, 0.5, 0.5, 1.0);
    if (edgeColor == null)
      edgeColor = new Vector4(0.0, 0.0, 0.0, 1.0);
    if (position != null)
      _modelProj.translate(position.x, position.y);

    // Initialize the static variables, if they haven't already
    if (_vboQuad == null) {
      var verts = new Float32List.fromList([
        1.0, -1.0,   1.0, 1.0,   -1.0, -1.0,   -1.0, 1.0]);
      
      _vboQuad = _gl.createBuffer();
      _gl.bindBuffer(webgl.ARRAY_BUFFER, _vboQuad);
      _gl.bufferDataTyped(webgl.ARRAY_BUFFER, verts, webgl.STATIC_DRAW);
    }
    
    if (_shader == null) {
      var vertSource = 
"""
precision mediump int;
precision mediump float;

attribute vec2  aPosition;
varying vec2    vPosition;
uniform vec2    uSize;
uniform mat4    uProj;

void main() {
  gl_Position = uProj * vec4(aPosition * uSize * 0.5, 0.0, 1.0);
  vPosition   = aPosition;
}
""";
      
      var fragSource =
"""
#extension GL_OES_standard_derivatives : enable

precision mediump int;
precision mediump float;

varying vec2      vPosition;
uniform vec2      uSize, uPosition;
uniform float     uRadius;
uniform float     uEdgeThick; 
uniform vec4      uColorIn, uColorEdge;

void main() {
  const float EPSILON = 0.000001;

  vec2 cornerRad = uRadius / uSize * 2.0;
  vec2 cornerPos  = sign(vPosition) *  
    max(((abs(vPosition) - (1.0 - cornerRad)) / cornerRad), vec2(0.0));

  float upp = fwidth(vPosition.x)/cornerRad.x;   // Units per pixel

  float len = length(cornerPos.xy);

  // Anti-alias over a window of one pixel width
  float outFactor  = smoothstep(max(1.0-upp,EPSILON), 1.0, len);
  float edgeFactor = smoothstep(max(1.0-upp*(uEdgeThick+1.0),EPSILON), 
                                max(1.0-upp* uEdgeThick     ,EPSILON), len);

  gl_FragColor    =  mix(uColorIn, uColorEdge, edgeFactor);
  gl_FragColor.a *= (1.0 - outFactor);
}
""";
      
      _shader = new Shader(_gl, vertSource, fragSource, {'aPosition': 0});
    }
  }
  
  void draw(Matrix4 projection) {
    _shader.use();
    var mvp = projection * _modelProj;
    _gl.uniformMatrix4fv(_shader['uProj'], false, mvp.storage);
    _gl.uniform2fv(_shader['uSize'],       size.storage);
    _gl.uniform1f(_shader['uRadius'],      radius);
    _gl.uniform1f(_shader['uEdgeThick'],   edgeThick);
    _gl.uniform4fv(_shader['uColorIn'],    inColor.storage);
    _gl.uniform4fv(_shader['uColorEdge'],  edgeColor.storage);

    _gl.bindBuffer(webgl.ARRAY_BUFFER, _vboQuad);
    _gl.vertexAttribPointer(0, 2, webgl.FLOAT, false, 0, 0);
    _gl.enableVertexAttribArray(0);
    
    _gl.bindTexture(webgl.TEXTURE_2D, _texture);

    _gl.drawArrays(webgl.TRIANGLE_STRIP, 0, 4);
  }
}