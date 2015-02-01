Mustache for the dartlang [![Build Status](https://travis-ci.org/valotas/mustache4dart.svg?branch=v1.0.8)](https://travis-ci.org/valotas/mustache4dart)
=======================================================================================================================================================
A simple implementation of [Mustache][mustache] for the [Dart language][dartlang],
which passes happily all the [mustache specs][specs]. If you want to 
have a look at how it works, just check the [tests][tests]. For more info, 
just read further.

Using it
--------
In order to use the library, just add it to your `pubspec.yaml` as a dependency

	dependencies:
	  mustache4dart: '>= 1.0.0 < 2.0.0'

and then import the package

```dart
import 'package:mustache4dart/mustache4dart.dart';
```

and you are good to go. You can use the render toplevel function to render your template.
For example:

```dart
var salutation = render('Hello {{name}}!', {'name': 'Bob'});
print(salutation); //shoud print Hello Bob!
```

### Context objects
mustache4dart will look at your given object for operators, fields or methods. For example,
if you give the template `{{firstname}}` for rendering, mustache4dart will try the followings

1. use the `[]` operator with `firstname` as the parameter
2. search for a field named `firstname`
3. search for a getter named `firstname`
4. search for a method named `firstname`
5. search for a method named `getFirstname`

in each case the first valid value will be used.

#### @MirrorsUsed
In order to do the stuff described above the mirror library is being used which could lead to big js files when compiling the library with dartjs. The implementation does use the `@MirrorsUsed` annotation but [as documented](https://api.dartlang.org/apidocs/channels/stable/#dart-mirrors.MirrorsUsed) this is experimental.

In order to avoid the use of the mirrors package, make sure that you compile your library with `dart2js -DMIRRORS=false `. In that case though you must always make sure that your context object have a right implementation of the `[]` operator as it will be the only check made against them (from the ones described above) in order to define a value.

### Partials
mustache4dart support partials but it needs somehow to know how to find a partial. You can
do that by providing a function that returns a template given a name:

```dart
String partialProvider(String partialName) => "this is the partial with name: ${partialName}";
expect(render('[{{>p}}]', null, partial: partialProvider), '[this is the partial with name: p]'));
```

### Compiling to functions
If you have a template that you are going to reuse with different contextes you can compile
it to a function using the toplevel function compile:

```dart
var salut = compile('Hello {{name}}!');
print(salut({'name': 'Alice'})); //should print Hello Alice!
``` 

Developing
----------
The project passes all the [Mustache specs][specs].  You have to make sure though that you've downloaded them. Just make sure that you have done the steps described below.

```sh
git clone git://github.com/valotas/mustache4dart.git
git submodule init
git submodule update
pub install
```


If you want to run the tests yourself, just do what [drone.io does](https://drone.io/github.com/valotas/mustache4dart/admin),
or to put it by another way, do the following:

```sh
test/run.sh
```

Alternatively, if you have [Dart Test Runner](https://pub.dartlang.org/packages/test_runner) installed you can just do

```
pub global run test_runner
```

Contributing
------------
If you found a bug, just create a [new issue][new_issue] or even better fork and issue a pull request with you fix.

Versioning
----------
The library will follow a [semantic versioning][semver]

[mustache]: http://mustache.github.com/
[dartlang]: http://www.dartlang.org/
[tests]: http://github.com/valotas/mustache4dart/blob/master/test/mustache_tests.dart
[specs]: http://github.com/mustache/spec
[new_issue]: https://github.com/valotas/mustache4dart/issues/new
[semver]: http://semver.org/
