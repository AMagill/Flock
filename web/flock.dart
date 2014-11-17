import 'dart:html';
import 'dart:web_gl' as webgl;
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import 'package:Flock/flock.dart';

int _width, _height;
webgl.RenderingContext _gl;
Scene _scene;

double _zoom = 0.0;
Vector2 _center;

void main() {
  var canvas = document.querySelector("#glCanvas");
  _width  = canvas.width;
  _height = canvas.height;
  _gl     = canvas.getContext("webgl", {'preserveDrawingBuffer': true});

  var extStdDeriv = _gl.getExtension('OES_standard_derivatives');
  //_gl.hint(webgl.OesStandardDerivatives.FRAGMENT_SHADER_DERIVATIVE_HINT_OES, webgl.FASTEST);

  _scene  = new Scene(_gl, _width, _height);
  
  _scene.onDirty.listen((e)      => scheduleRender());
  canvas.onMouseWheel.listen((e) => _scene.onMouseWheel(e));
  canvas.onMouseDown.listen((e)  => _scene.onMouseDown(e));    
  canvas.onMouseUp.listen((e)    => _scene.onMouseUp(e));    
  canvas.onMouseMove.listen((e)  => _scene.onMouseMove(e));    
  canvas.onMouseOut.listen((e)   => _scene.onMouseOut(e));
  
  scheduleRender();
}

void scheduleRender() {
  window.animationFrame
    ..then((time) => _scene.draw());
}

