library models;

import 'package:config/config.dart';
import 'package:web_ui/web_ui.dart';
import 'dart:async';
import 'dart:html';
import 'dart:json' as json;

part 'models/asset.dart';
part 'models/design.dart';

String get designSetsPath => "/taco/api/design_sets/${config.get("design-set-id")}";
String get uploaderHost => config.get("upload-host");