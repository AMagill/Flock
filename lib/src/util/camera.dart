import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';

class Camera {
  static const zoomMin = -3.0;
  static const zoomMax =  5.0;
  
  Matrix4 _proj, _invProj;
  double  _zoom, _aspect;
  Vector2 _center;
  
  Matrix4 get projection {
    if (_proj == null) {
      _proj = new Matrix4.identity();
      var zs  = math.pow(2.0, zoom);
      if (_aspect > 1.0)
        _proj.scale(zs / _aspect, zs);
      else
        _proj.scale(zs, zs * _aspect);
      _proj.translate(-_center.x, -_center.y);
    }
    return _proj;
  }
  
  Matrix4 get invProjection {
    if (_invProj == null) {
      _invProj = projection.clone()..invert();
    }
    return _invProj;
  }
  
  double get zoom => _zoom;
  set zoom(double val) {
    _zoom = val.clamp(zoomMin, zoomMax);
    _proj = _invProj = null;
  }
  
  double get aspect => _aspect;
  set aspect(double val) {
    _aspect = val;
    _proj = _invProj = null;
  }
  
  Vector2 get center => _center;
  set center(Vector2 val) {
    _center = val;
    _proj = _invProj = null;    
  }
  
  Camera() :
    _proj = null,
    _invProj = null,
    _zoom = 0.0, _aspect = 1.0,
    _center = new Vector2(0.0, 0.0);
  
  void zoomBy(double amount, {Vector2 center}) {
    var delta = _zoom;
    zoom  += amount;
    delta -= _zoom;
    if (center != null)
      _center = center - (center-_center) * math.pow(2.0, delta);
  }
  
  Vector2 unproject(num x, num y, [num z=0.0]) {
    var result = invProjection * new Vector4(x*2.0-1.0, -(y*2.0-1.0), z, 1.0);
    return result.xy;
  }
}