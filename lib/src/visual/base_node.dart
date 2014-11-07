part of node_graph;

abstract class BaseNode {
  final conSize = 0.06;
  
  webgl.RenderingContext _gl;
  RoundedRect _rect;
  List<RoundedRect> _inputs, _outputs;
  Matrix4 _modelProj;
  
  BaseNode(this._gl, {double w:1.0, double h:1.0, double x:0.0, double y:0.0, 
    int nInputs:0, int nOutputs:0}) {
    
    _rect = new RoundedRect(_gl, w:w, h:h);
    
    _inputs  = new List<RoundedRect>();
    for (var i = 0; i < nInputs; i++) {
      var newNode = new RoundedRect(_gl, w:conSize, h:conSize, radius:conSize/2,
          inColor:new Vector4(1.0,1.0,1.0,1.0), x:-w/2, y:h/2 - h*(i+1)/(nInputs+1));
      _inputs.add(newNode);
    }
    
    _outputs = new List<RoundedRect>();
    for (var i = 0; i < nOutputs; i++) {
      var newNode = new RoundedRect(_gl, w:conSize, h:conSize, radius:conSize/2,
          inColor:new Vector4(1.0,1.0,1.0,1.0), x:w/2, y:h/2 - h*(i+1)/(nOutputs+1));
      _outputs.add(newNode);
    }

    _modelProj = new Matrix4.identity();
    _modelProj.setTranslationRaw(x, y, 0.0);
  }
  
  void draw(Matrix4 projection) {
    var mvp = projection * _modelProj;
    
    _rect.draw(mvp);
    for (var n in _inputs) {
      n.draw(mvp);
    }
    for (var n in _outputs) {
      n.draw(mvp);
    }
  }
}