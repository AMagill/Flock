import 'dart:io';
import 'dart:convert';


// Takes text .fnt files from http://kvazars.com/littera/,
// and converts them into a JSON glyph atlas.
void main() {
  final String inFileName  = '../lib/fonts/font.fnt';
  final String outFileName = '../lib/fonts/font.json';
  
  convert(inFileName, outFileName);
}

void convert(String inFileName, String outFileName) {
  var keyPattern = new RegExp(r"^(\w+)");
  var valPattern = new RegExp(r"([^ ]+)=([^ ]*)");
  
  var scaleW, scaleH;
  var chars = {};
  
  var inLines = new File(inFileName).readAsLinesSync();
  for (var line in inLines) {
    var vals = {};
    
    var key = keyPattern.stringMatch(line);
    for (Match m in valPattern.allMatches(line)) {
      vals[m.group(1)] = m.group(2);
    }
    
    switch (key) {
      case 'common':
        scaleW = int.parse(vals['scaleW']);
        scaleH = int.parse(vals['scaleH']);
        break;
      case 'char':
        chars[vals['id']] = {
          'x':        int.parse(vals['x'])        / scaleW,
          'y':        int.parse(vals['y'])        / scaleH,
          'width':    int.parse(vals['width'])    / scaleW,
          'height':   int.parse(vals['height'])   / scaleH,
          'xoffset':  int.parse(vals['xoffset'])  / scaleW,
          'yoffset':  int.parse(vals['yoffset'])  / scaleH,
          'xadvance': int.parse(vals['xadvance']) / scaleW,
          'kernings': {},
        };
        break;
      case 'kerning':
        var first  = vals['first'];
        var second = vals['second'];
        var amount = int.parse(vals['amount'])    / scaleW;
        chars[first]['kernings'][second] = amount;
        break;
    }
  }
  
  new File(outFileName).writeAsStringSync(JSON.encode(chars));
  
}
