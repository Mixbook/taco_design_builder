import 'dart:io';
import 'package:web_ui/component_build.dart';

// Ref: http://www.dartlang.org/articles/dart-web-components/tools.html
main() {
  var args = new List.from(new Options().arguments);
  build(args, ['web/index.html']);
}