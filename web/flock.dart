import 'dart:html';
import 'dart:web_gl' as webgl;
import 'package:vector_math/vector_math.dart';
import 'package:Flock/flock.dart';

webgl.RenderingContext _gl;
Scene _scene;

double _zoom = 0.0;
Vector2 _center;

void main() {
  var canvas = document.querySelector("#glCanvas");
  _gl = canvas.getContext("webgl", {'preserveDrawingBuffer': true, 'stencil': true});

  var extStdDeriv = _gl.getExtension('OES_standard_derivatives');
  //_gl.hint(webgl.OesStandardDerivatives.FRAGMENT_SHADER_DERIVATIVE_HINT_OES, webgl.FASTEST);

  canvas.width  = canvas.parent.client.width;
  canvas.height = canvas.parent.client.height;
  _scene  = new Scene(_gl, canvas.width, canvas.height);
  
  canvas.onMouseWheel.listen((e) => _scene.onMouseWheel(e));
  canvas.onMouseDown.listen((e)  => _scene.onMouseDown(e));    
  canvas.onMouseUp.listen((e)    => _scene.onMouseUp(e));    
  canvas.onMouseMove.listen((e)  => _scene.onMouseMove(e));    
  canvas.onMouseOut.listen((e)   => _scene.onMouseOut(e));

  window.onResize.listen((e) {
    canvas.width  = canvas.parent.client.width;
    canvas.height = canvas.parent.client.height;
    _scene.resize(canvas.width, canvas.height);
  });
  
  gameLoop();    
}

void gameLoop([num delta = 0.0]) {
  _scene.animate(delta);
  _scene.draw();
  window.animationFrame.then(gameLoop);
}

