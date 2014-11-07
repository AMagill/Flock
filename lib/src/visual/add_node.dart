part of node_graph;

class AddNode extends BaseNode {
  static const size = 0.2;
  
  AddNode(webgl.RenderingContext _gl, {x:0.0, y:0.0}) : 
    super(_gl, w:size, h:size, x:x, y:y, nInputs:2, nOutputs:1) {

  }
}