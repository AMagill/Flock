library pick_table;

class PickTable {
  static final PickTable _singleton = new PickTable._internal();
  
  final table = new Map<int, String>();
  int _seed = 1;
  
  factory PickTable() {
    return _singleton;
  }
  
  PickTable._internal();
  
  int add(String value) {
    _seed = _lfsr(_seed);
    table[_seed] = value;
    return _seed;
  }
  
  operator [](int key) {
    return table[key];
  }
  
  
  int _lfsr(int n) {
    if ((n & 1) != 0)
      n = (n >> 1) ^ 0x8566AB;  // Maximum-length 24-bit LFSR
    else
      n = (n >> 1);
    return n;
  }
}