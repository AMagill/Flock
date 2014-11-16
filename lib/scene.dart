import 'dart:web_gl' as webgl;
import 'package:vector_math/vector_math.dart';
import 'package:vector_math/vector_math_lists.dart';
import 'src/util/frame_buffer.dart';
import 'node_graph.dart';

class Scene {
  int width, height;
  webgl.RenderingContext gl;
  FrameBuffer pickBuf;
  
  Graph _graph;
  Bezier _bezier;
  
  Scene(this.gl, this.width, this.height) {
    pickBuf = new FrameBuffer(gl, width, height);

    var sdfText = new DistanceField(gl);
    sdfText.loadUrl('/packages/node_graph/fonts/font.png',
                    '/packages/node_graph/fonts/font.json');
//      ..then((_) => scheduleRender());

    _graph = new Graph(gl)
      ..addNode("addition", x:0.0, y:0.0);
    _bezier = new Bezier(gl, new Vector2List.fromList([
      new Vector2(0.0, -0.1), new Vector2(0.0, 0.0),
      new Vector2(0.5, -0.5), new Vector2(0.5, 0.0)]));

    
    gl.enable(webgl.BLEND);
    gl.blendFunc(webgl.SRC_ALPHA, webgl.ONE_MINUS_SRC_ALPHA);
    gl.clearColor(0.8, 0.8, 0.8, 1.0);
    
    
    String getPickTarget(int x, int y) {
      return null;
      /*
      var pixel = new Uint8List(4);
      pixel[1] = 42;
      gl.readPixels(x, y, 1, 1, webgl.RGBA, webgl.UNSIGNED_BYTE, pixel);
      
     return new PickTable().lookup(pixel);*/
    }
  }
  
  void animate(double time) {
    
  }
  
  void draw(Matrix4 proj) {
    gl.clear(webgl.COLOR_BUFFER_BIT);
    
    gl.bindFramebuffer(webgl.FRAMEBUFFER, pickBuf.fbo);
    _graph.draw(proj, true);
    
    gl.bindFramebuffer(webgl.FRAMEBUFFER, null);
    _graph.draw(proj);
    _bezier.draw(proj);
  }
  
  void onMouseDown(int x, int y) {
    print("MouseDown: ($x, $y)");
  }

  void onMouseUp(int x, int y) {
  }

  void onMouseMove(int x, int y) {
  }
  
  void onMouseOut() {
  }
}