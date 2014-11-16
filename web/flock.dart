import 'dart:html';
import 'dart:web_gl' as webgl;
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import 'package:Flock/node_graph.dart';
import 'package:Flock/scene.dart';

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
  
  
  canvas.onMouseWheel.listen((e) {
    _zoom += e.wheelDeltaY;
    reProject();
    scheduleRender();
  });
  canvas.onMouseDown.listen((e) {
    var x = e.layer.x;
    var y = e.layer.y;
    _scene.onMouseDown(x, y);    
  });
  canvas.onMouseUp.listen((e) {
    var x = e.layer.x;
    var y = e.layer.y;
    _scene.onMouseUp(x, y);    
  });
  canvas.onMouseMove.listen((e) {
    var x = e.layer.x;
    var y = e.layer.y;
    _scene.onMouseMove(x, y);    
  });
  canvas.onMouseOut.listen((e) {
    _scene.onMouseOut();
  });
  
  scheduleRender();
}


var proj = new Matrix4.identity();

void reProject() {
  proj = new Matrix4.identity();
  proj.scale(math.pow(1.001, _zoom));  
}

void animate(double time) {
  /*
  proj = new Matrix4.identity();
  proj.translate(math.cos(time * 0.001) * 0.1, math.sin(time * 0.0015) * 0.1);
  proj.rotateZ(math.sin(time * 0.001) * 0.1);
  proj.scale((math.cos(time * 0.0005) + 1.1) * 16.0);
  */
  
  render();

  // scheduleRender();
}

void scheduleRender() {
  window.animationFrame
    ..then((time) => animate(time));
}

void render() {
  _scene.draw(proj);
}

