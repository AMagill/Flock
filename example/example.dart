import 'dart:html';
import 'dart:web_gl' as webgl;
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import 'package:vector_math/vector_math_lists.dart';
import 'package:node_graph/node_graph.dart';

int _width, _height;
webgl.RenderingContext _gl;
double _zoom = 0.0;
Vector2 _center;

Graph _graph;
Bezier _bezier;
DistanceField _sdfText;
TextLayout _text;

void main() {
  var canvas = document.querySelector("#glCanvas");
  _width  = canvas.width;
  _height = canvas.height;
  _gl     = canvas.getContext("webgl");

  var extStdDeriv = _gl.getExtension('OES_standard_derivatives');
  //_gl.hint(webgl.OesStandardDerivatives.FRAGMENT_SHADER_DERIVATIVE_HINT_OES, webgl.FASTEST);

  _graph = new Graph(_gl)
    ..AddNode(new Vector2(1.0, 0.2), new Vector2(0.0, 0.1));
  _bezier = new Bezier(_gl, new Vector2List.fromList([
    new Vector2(0.0, -0.1), new Vector2(0.0, 0.0),
    new Vector2(0.5, -0.5), new Vector2(0.5, 0.0)]));

  _sdfText = new DistanceField(_gl);
  _text = new TextLayout(_gl, _sdfText);
  _sdfText.loadUrl('/packages/node_graph/fonts/font.png',
                   '/packages/node_graph/fonts/font.json')
    .then((_) => _text.addString("WAFjords!", scale:1.0))
    .then((_) => render());
  
  _gl.enable(webgl.BLEND);
  _gl.blendFunc(webgl.SRC_ALPHA, webgl.ONE_MINUS_SRC_ALPHA);
  _gl.clearColor(0.8, 0.8, 0.8, 1.0);
  
  
  canvas.onMouseWheel.listen((e) {
    _zoom += e.wheelDeltaY;
    reProject();
    scheduleRender();
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
  _gl.clear(webgl.COLOR_BUFFER_BIT);
  
  _graph.draw(proj);
  _bezier.draw(proj);
  _text.draw(proj);
}

