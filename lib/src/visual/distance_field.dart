part of Flock;

class DistanceField {
  static Shader _shader;

  final webgl.RenderingContext gl;
  webgl.Texture _texture;
  var _atlas;
  StreamController _onLoadStreamController = new StreamController();
  
  Stream<Event> get onLoad => _onLoadStreamController.stream.asBroadcastStream();
  dynamic get atlas => _atlas;

  DistanceField(this.gl) {
    if (_shader == null) {
      var vertSource = 
"""
precision mediump int;
precision mediump float;

attribute vec2  aPos, aTex;
attribute vec3  aColor;
attribute float aThreshold;

uniform mat4 uProj;

varying vec2  vTex;
varying vec4  vPos;
varying vec3  vColor;
varying float vThreshold;

void main() {
  vPos = vec4(aPos, 0.0, 1.0);
  gl_Position = uProj * vPos;
  vTex = aTex;
  vColor = aColor;
  vThreshold = aThreshold;
}
""";
      
      var fragSource =
"""
#extension GL_OES_standard_derivatives : enable

precision mediump int;
precision mediump float;

uniform sampler2D uTexture;

varying vec2  vTex;
varying vec4  vPos;
varying vec3  vColor;
varying float vThreshold;

void main() {
  float aa = 16.0 * fwidth(vPos.x);
  float alpha = smoothstep(vThreshold-aa, vThreshold+aa, texture2D(uTexture, vTex).r);
  //alpha = step(vThreshold, texture2D(uTexture, vTex).r);
  gl_FragColor = vec4(vColor, alpha);
}
""";
      
      _shader = new Shader(gl, vertSource, fragSource, 
          {'aPos': 0, 'aTex': 1, 'aColor': 2, 'aThreshold': 3});
    }
    
    _texture = gl.createTexture();
  }
  
  Future loadUrl(String imgUrl, String atlasUrl) {
    ImageElement imgElem = new ImageElement(src: imgUrl);

    var textureFuture = imgElem.onLoad.first
        .then((_) => _loadImage(imgElem));

    var atlasFuture = HttpRequest.getString(atlasUrl)
        .then((response) => _atlas = JSON.decode(response));
    
    return Future.wait([textureFuture, atlasFuture])
        .then((_) => _onLoadStreamController.add(null));
  }
  
  void bind() {
    if (_texture == null) return;
    gl.bindTexture(webgl.TEXTURE_2D, _texture);
    _shader.use();
    gl.uniform1i(_shader['uTexture'], 0);
  }
  
  void _loadImage(ImageElement img) {
    gl.bindTexture(webgl.TEXTURE_2D, _texture);
    gl.texParameteri(webgl.TEXTURE_2D, webgl.TEXTURE_MIN_FILTER, webgl.LINEAR);
    gl.texParameteri(webgl.TEXTURE_2D, webgl.TEXTURE_MAG_FILTER, webgl.LINEAR);
    gl.texImage2DImage(webgl.TEXTURE_2D, 0, webgl.RGB, 
        webgl.RGB, webgl.UNSIGNED_BYTE, img);
  }

}