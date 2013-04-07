part of mustache4dart;

class _Template {
  final _TokenList list;
  
  factory _Template({String template, Delimiter delimiter, String ident, Function partial}) {
    _TokenList tokens = new _TokenList(delimiter, ident);
    if (template == null) {
      tokens.addToken(EMPTY_STRING, delimiter, ident, null);
      return new _Template._internal(tokens);
    }
    
    bool searchForOpening = true;
    for (int i = 0; i < template.length; i++) {
      String char = template[i];
      if (delimiter.isDelimiter(template, i, searchForOpening)) {
        if (searchForOpening) { //opening delimiter
          tokens.addTokenWithBuffer(delimiter, ident, partial);
          searchForOpening = false;
        }
        else { //closing delimiter
          tokens.write(delimiter.closing); //add the closing delimiter
          tokens.addTokenWithBuffer(delimiter, ident, partial);
          i = i + delimiter.closingLength - 1;
          delimiter = tokens.nextDelimiter; //get the next delimiter to use
          searchForOpening = true;
          continue;
        }
      }
      else if (isSingleCharToken(char, searchForOpening)) {
        tokens.addTokenWithBuffer(delimiter, ident, partial);
        tokens.addToken(char, delimiter, ident, partial);
        continue;
      }
      else if (isSpecialNewLine(template, i)) {
        tokens.addTokenWithBuffer(delimiter, ident, partial);
        tokens.addToken(CRNL, delimiter, ident, partial);
        i++;
        continue;
      }
      tokens.write(char);
    }
    tokens.addTokenWithBuffer(delimiter, ident, partial, last: true);

    return new _Template._internal(tokens);
  }
  
  static bool isSingleCharToken(String char, bool opening) {
    if (!opening) {
      return false;
    }
    if (char == NL) {
      return true;
    }
    if (char == SPACE) {
      return true;
    }
    return false;
  }
  
  static bool isSpecialNewLine(String template, int position) {
    if (position + 1 == template.length) {
      return false;
    }
    var char = template[position];
    var nextChar = template[position + 1];
    return char == '\r' && nextChar == NL; 
  }
  
  _Template._internal(this.list);
    
  String call(ctx) {
    if (list.head == null) {
      return EMPTY_STRING;
    }
    if (!(ctx is MustacheContext)) {
      ctx = new MustacheContext(ctx);
    }
    return list.head.render(ctx, null);
  }
  
  String toString() {
    return "Template($list)";
  }
}

class _TokenList {
  StringBuffer buffer;
  _Token head;
  _Token tail;
  Delimiter _nextDelimiter;
  
  _TokenList(Delimiter delimiter, String ident) {
    //Our template should start as an empty string token
    head = new _SpecialCharToken(EMPTY_STRING, ident);
    tail = head;
    _nextDelimiter = delimiter;
    buffer = new StringBuffer();
  }
  
  void addTokenWithBuffer(Delimiter del, String ident, Function partial, {last: false}) {
    if (buffer.length > 0) {
      addToken(buffer.toString(), del, ident, partial, last: last);
      buffer = new StringBuffer();      
    }
  }
  
  void addToken(String str, Delimiter del, String ident, Function partial, {last: false}) {
    _add(new _Token(str, partial, del, ident));
    if (last && buffer.length > 0) {
      _add(new _Token(EMPTY_STRING, partial, del, ident)); //to mark the end of the template
    }
  }
  
  void _add(_Token other) {
    if (other == null) {
      return;
    }
    if (other is _DelimiterToken) {
      _nextDelimiter = other.newDelimiter;
    }
    tail.next = other;
    tail = other;
  }
    
  Delimiter get nextDelimiter => _nextDelimiter;
  
  void write(String txt) {
    buffer.write(txt);
  }

  String toString() {
    StringBuffer str = new StringBuffer("TokenList(");
    if (head == null) {
      //Do not display anything
    }
    else if (head == tail) {
      str.write(head);
    }
    else {
      str.write("$head...$tail");
    }
    str.write(")");
    return str.toString();
  }
}

class Delimiter {
  final String opening;
  final String _closing;
  String realClosingTag;
  
  Delimiter(this.opening, this._closing);
  
  bool isDelimiter(String template, int position, bool opening) {
    String d = opening ? this.opening : this._closing;
    if (d.length == 1) {
      return d == template[position];
    }
    //else:
    int endIndex = position + d.length;
    if (endIndex >= template.length) {
      return false;
    }
    String dd = template.substring(position, endIndex);
    if (d != dd) {
      return false;
    }
    //A hack to support tripple brackets
    if (!opening && _closing == '}}' && template[endIndex] == '}') {
      realClosingTag = '}}}';
    }
    else {
      realClosingTag = null;
    }
    return true;
  }
  
  String get closing => realClosingTag != null ? realClosingTag : _closing;
  
  int get closingLength => closing.length;
  
  int get openingLength => opening.length;
  
  toString() => "Delimiter($opening, $closing)";
}
