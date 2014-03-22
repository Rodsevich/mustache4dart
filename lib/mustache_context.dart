library mustache_context;

import 'dart:collection';
import 'dart:mirrors';

class MustacheContext {
  static const String DOT = '\.';
  final Map cache = {}; 
  final ctx;
  _ObjectReflector ctxReflector;
  MustacheContext _parent;

  MustacheContext(this.ctx, [MustacheContext this._parent]);
  
  bool get isLambda => ctx is Function;

  call([arg]) => isLambda ? ctx(arg) : ctx.toString();

  operator [](String key) {
    if (ctx == null) return null;
    var result = cache[key];
    if (result == null) {
      result = _getInThisOrParent(key);
      if (result != null) {
        cache[key] = result;
      }
    }
    return result;
  }
  
  _getInThisOrParent(String key) {
    var result = _get(key);
    
    //if the result is null, try the parent context
    if (result == null && _parent != null) {
      result = _parent[key];
      
      //set the parent of the result
      if (result != null && !identical(result, this)) {
        result.parent = this;
      }
    }
    return result;
  }
  
  set parent(MustacheContext ctx) => this._parent = ctx;
  
  _get(String key) {
    if (key == DOT) {
      return this;
    }
    if (key.contains(DOT)) {
      Iterator<String> k = key.split(DOT).iterator;
      var val = this;
      while(k.moveNext()) {
        val = val._getValidValueOrContext(k.current);
        if (val == null) {
          return null;
        }
      }
      return val;
    }
    //else
    return _getValidValueOrContext(key);
  }
  
  _getValidValueOrContext(String key) {
    var v = _getValue(key);
    if (v == null) {
      return null;
    }
    if (v is Iterable) {
      if (v.isEmpty) {
        return null;
      }
      return new _IterableMustacheContextDecorator(v, this);
    }
    if (v == false) {
      return null;
    }
    return new MustacheContext(v, this);
  }
  
  _getValue(String key) {
    try {
      return ctx[key];
    } catch (NoSuchMethodError) {
      return _ctxReflector[key];
    } 
  }
  
  get _ctxReflector {
    if (ctxReflector == null) {
      ctxReflector = new _ObjectReflector(ctx);
    }
    return ctxReflector;
  }
    
  String toString() => "MustacheContext($ctx, $_parent)";
}

class _IterableMustacheContextDecorator extends IterableBase<MustacheContext> {
  final Iterable delegate;
  final MustacheContext other;
  
  _IterableMustacheContextDecorator(this.delegate, this.other);
  
  Iterator<MustacheContext> get iterator => new _MustachContextIteratorDecorator(delegate.iterator, other);
  
  int get length => delegate.length;
  
}

class _MustachContextIteratorDecorator extends Iterator<MustacheContext> {
  final Iterator delegate;
  final MustacheContext other;
  MustacheContext current;
  
  _MustachContextIteratorDecorator(this.delegate, this.other);
  
  bool moveNext() {
    if (delegate.moveNext()) {
      current = new MustacheContext(delegate.current);
      return true;
    } else {
      current = null;
      return false;
    }
  }
}

/**
 * Helper class which given an object it will try to get a value by key analyzing
 * the object by reflection
 */
class _ObjectReflector {
  final InstanceMirror m;
  
  _ObjectReflector.fromMirror(this.m);
  
  factory _ObjectReflector(o) {
    return new _ObjectReflector.fromMirror(reflect(o));
  }
  
  operator [](String key) {
    var declaration = getDeclaration(key);
    
    if (declaration == null) {
      return null;
    }
    
    return declaration.value;
  }
  
  _ObjectReflectorDeclaration getDeclaration (String key) {
    var declarationMirror = _findMemberMirror(m, key);
        
    if (declarationMirror == null) {
      return null;
    }
    
    return new _ObjectReflectorDeclaration(m, declarationMirror);
  }
  
  static DeclarationMirror _findMemberMirror(InstanceMirror m, String declarationName) {
    var declarations = m.type.declarations;
    var declarationMirror = declarations[new Symbol(declarationName)];
    if (declarationMirror == null) {
      //try out a getter:
      declarationName = "get${declarationName[0].toUpperCase()}${declarationName.substring(1)}";
      declarationMirror = declarations[new Symbol(declarationName)];
    }
    return declarationMirror;
  }
}

class _ObjectReflectorDeclaration {
  final InstanceMirror mirror;
  final DeclarationMirror declaration;
  
  _ObjectReflectorDeclaration(this.mirror, this.declaration);
  
  bool get isLambda => declaration is MethodMirror && (declaration as MethodMirror).parameters.length == 1;
  
  Function get lambda => (val) {
    var im = mirror.invoke(declaration.simpleName, [val]);
    if (im is InstanceMirror) {
      var r = im.reflectee;
      return r;
     }
     else {
      return null;
     }
  };
  
  get value {
    if (isLambda) {
      return lambda;
    }
    
    //Now we try to find out a field or a getter named after the given name
    var im = null;
    if (isVariableOrGetter) {
      im = mirror.getField(declaration.simpleName);
    }
    else if (isParameterlessMethod) {
      im = mirror.invoke(declaration.simpleName, []);
    }
    if (im != null && im is InstanceMirror) {
      return im.reflectee;
    }
    return null;
  }
  
  bool get isVariableOrGetter => (declaration is VariableMirror) || (declaration is MethodMirror && (declaration as MethodMirror).isGetter);
  
  bool get isParameterlessMethod => declaration is MethodMirror && (declaration as MethodMirror).parameters.length == 0;
}