library models;

import 'package:config/config.dart';
import 'package:web_ui/web_ui.dart';
import 'dart:async';
import 'dart:html';
import 'package:taco_design_builder/src/apis.dart';

part 'models/asset.dart';
part 'models/sticker.dart';
part 'models/background.dart';
part 'models/design.dart';

abstract class Model {
}

typedef Model FromAttrFactory(Map m);

abstract class LoadedModels<M extends Model> {
  List<M> loaded = [];
  FromAttrFactory _fromAttrFactory;
  set fromAttrFactory(M f(Map m)) => _fromAttrFactory = f;

  Future<Iterable<Map>> findAll();

  Future<Iterable<M>> populate() {
    return findAll().then((datas) {
      datas.forEach(addFromAttrToLoaded);
      return loaded;
    });
  }

  M addFromAttrToLoaded(attrs) {
    var m = _fromAttrFactory(attrs);
    loaded.add(m);
    return m;
  }
}

String get designSetRoot => "${config.get('apiUri')}/design_sets/${config.get("designSetId")}";
String get uploadRoot => config.get("uploadUri");