library mustache_specs;

import 'dart:io';
import 'dart:json';
import 'package:/unittest/unittest.dart';
import 'package:mustache4dart/mustache4dart.dart';

final List<String> EXCLUDES = ['~lambdas.json', 'partials.json', 'inverted.json', 'delimiters.json', 'comments.json']; 

main() {
  print("Running mustache specs");
  var specs_dir = new Directory('spec/specs');
  specs_dir
    .listSync()
    .forEach((f) {
      // filter out only .json files and not the lambda tests at the moment
      if (shouldRun(f.name)) {
        f.readAsString(Encoding.UTF_8)
          .then((text) {
            var json = parse(text);
            var tests = json['tests'];
            tests.forEach( (t) {
              var testDescription = new StringBuffer(t['name']);
              testDescription.write(': ');
              testDescription.write(t['desc']);
              var template = t['template'];
              var data = t['data'];
              var templateOnline = template.replaceAll('\n', '\\n').replaceAll('\r', '\\r');
              testDescription.write(" When rendering '''$templateOnline''' with '$data'");
              var expected = t['expected'];
              test(testDescription.toString(), () => expect(render(template, data), expected)); 
            });
          });
      }
    });
}

bool shouldRun(String filename) {
  if (!filename.endsWith('.json')) {
    return false;
  }
  String name = filename.substring(filename.lastIndexOf('/') + 1);
  return !EXCLUDES.contains(name);
}