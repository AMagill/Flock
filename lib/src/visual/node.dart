part of node_graph;

class Node {
  static DistanceField _sdfSymbol;
  
  webgl.RenderingContext _gl;
  RoundedRect _rect;
  TextLayout _symbols;
  
  Node(this._gl, [size, Vector2 position]) {
    void afterSdfLoaded() {
        _symbols.addGlyph('circle_filled', scale:0.6, color:new Vector3(1.0, 1.0, 1.0));
        _symbols.addGlyph('circle_open'  , scale:0.6, threshold:0.5);
    }
    
    if (_sdfSymbol == null) {
      _sdfSymbol = new DistanceField(_gl)
          ..loadUrl('/packages/node_graph/fonts/symbols.png',
                    '/packages/node_graph/fonts/symbols.json')
          .then((_) => afterSdfLoaded());
    }
    else {
      afterSdfLoaded();
    }

    _symbols = new TextLayout(_gl, _sdfSymbol);

    _rect = new RoundedRect(_gl, size:size, position:position);
  }
  
  void draw(Matrix4 projection) {
    _rect.draw(projection);
    _symbols.draw(projection);
  }
}