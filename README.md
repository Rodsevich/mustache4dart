Mustache for Dart
=================
A simple implementation of [mustache](http://mustache.github.com/) for the
[Dart language](http://www.dartlang.org/). At the moment this project serves
as an excuse to better explore the language. Although it is still in development you can have a look at what is capable of at the
[tests](https://github.com/valotas/mustache4dart/blob/master/test/mustache_tests.dart)

Using it
--------
In order to use the library, just add it to your pubspec.yalm as a dependency

	dependencies:
	  mustache4dart: any

and you are good to go. You can use the render toplevel function to render your template.
For example:

	var salutation = render('Hello {{name}}!', {name: 'Bob'});
	print(salutation); //shoud print Hello Bob!

### Compiling to functions
If you have a template that you are going to reuse with different contextes you can compile
a template to a function using the toplevel function compile:

	var salut = compile('Hello {{name}}!');
	print(salut('Alice')); //should print Hello Alice! 

Running the tests
-----------------
At the moment the project is under heavy development. If you want to run the tests the
following commands should be enough

	git clone git://github.com/valotas/mustache4dart.git
	git submodule init
	git submodule update 
	pub install
	test/run.sh

At the moment mustache4dart can pass all interpolation, inverted and sections specs.

Versioning
----------
Until a stable release the versioning of the project will be 0.0.[NUM] where NUM should be
the number of groups of the mustache specs that pass.

Build status
------------
[![Build Status](https://drone.io/github.com/valotas/mustache4dart/status.png)](https://drone.io/github.com/valotas/mustache4dart/latest)
You can watch the project failing live by clicking at the status badge :-)
