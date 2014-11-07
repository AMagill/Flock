part of node_graph;

class EntityNode extends BaseNode {
  EntityNode(webgl.RenderingContext _gl, {x:0.0, y:0.0}) : 
    super(_gl, w:1.0, h:1.0, x:x, y:y, nInputs:2, nOutputs:3) {

  }
}