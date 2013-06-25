library models.Design;

import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'dart:json' as json;
import 'dart:async';

@observable
class Design {
  static Map<int, Design> layoutIdToDesign = toObservable(new Map<int, Design>());
  static int currentLayoutId;

  int id;
  int layoutId;
  String layoutName;
  String _caml;
  bool dirty = false;

  Design.fromJson(Map json) {
    id = json["id"];
    layoutId = json["layout_id"];
    layoutName = json["layout_name"];
    _caml = json["caml"];
  }

  static addFromDesignsJson(List<Map> designsJson) {
    designsJson.forEach(addFromDesignJson);
  }

  static addFromDesignJson(Map designJson) {
    var design = new Design.fromJson(designJson);
    layoutIdToDesign[design.layoutId] = design;
    if (currentLayoutId == null) {
      currentLayoutId = design.layoutId;
    }
  }

  static Future load({int designSetId}) {
    var completer = new Completer();

    HttpRequest.getString("${designsPath}?with_unlinked=true").then((response) {
     addFromDesignsJson(json.parse(response)["data"]);
     completer.complete();
    });
    return completer.future;
  }

  void freezeDirty(doWork(design)) {
    var oldDirty = dirty;
    doWork(this);
    dirty = oldDirty;
  }

  static Design get current => layoutIdToDesign[currentLayoutId];
  static String get currentSelectedValue => currentLayoutId.toString();
  static set currentSelectedValue (newVal) => currentLayoutId = int.parse(newVal);
  static get all => layoutIdToDesign.values;

  String get caml => _caml;
  void set caml (newCaml) {
    dirty = true;
    _caml = newCaml;
  }

  static String get designsPath {
    int designSetId = int.parse(window.location.hash.substring(1));
    return "${window.location.origin}/taco/api/design_sets/$designSetId/designs";
  }

  //http://www.dartlang.org/articles/json-web-service/#saving-objects-on-the-server
  bool save() {
    HttpRequest request = new HttpRequest();

    request.onReadyStateChange.listen((_) {
      if (request.readyState == HttpRequest.DONE &&
          (request.status == 200 || request.status == 0)) {
        dirty = false;
        addFromDesignJson(json.parse(request.responseText)["data"]);
        print("Successfully updated design #$id");
      }
    });

    if (id == null) {
      request.open("Post", designsPath);
      request.setRequestHeader("content-type", "application/json");
      request.send(json.stringify({"design": {"layout_id": layoutId, "caml": caml}}));
    } else {
      String url = "$designsPath/$id";
      request.open("Put", url);
      request.setRequestHeader("content-type", "application/json");
      request.send(json.stringify({"design": {"caml": caml}}));
    }
  }

  String get optionValue => layoutId.toString();
  String get optionLabel {
    var prefix = id == null ? "UNCREATED " : "";
    return "$prefix Design for Layout $layoutId ($layoutName)";
  }
  bool get optionSelected => layoutId == Design.currentLayoutId;
}