import 'dart:html';
import 'dart:web_gl' as webgl;
import 'package:vector_math/vector_math.dart';
import 'package:vector_math/vector_math_lists.dart';
import 'package:node_graph/node_graph.dart';

int _width, _height;
webgl.RenderingContext _gl;
RoundedRect _node;
Bezier _bezier;

void main() {
  var canvas = document.querySelector("#glCanvas");
  _width  = canvas.width;
  _height = canvas.height;
  _gl     = canvas.getContext("webgl");

  _node = new RoundedRect(_gl, new Vector2(1.8, 0.2), new Vector2(0.0, 0.5));
  _bezier = new Bezier(_gl, new Vector2List.fromList([
    new Vector2(0.0, 0.0), new Vector2(0.0, -0.5),
    new Vector2(0.5, 0.0), new Vector2(0.5, -0.5)]));
  
  _gl.enable(webgl.BLEND);
  _gl.blendFunc(webgl.SRC_ALPHA, webgl.ONE_MINUS_SRC_ALPHA);
  _gl.clearColor(0.8, 0.8, 0.8, 1.0);
  
  window.animationFrame
    ..then((time) => animate(time));
}

void animate(double time) {
  render();
  
  //window.animationFrame
  //  ..then((time) => animate(time));
}

void render() {
  _gl.clear(webgl.COLOR_BUFFER_BIT);
  
  _node.draw();
  _bezier.draw();
}

