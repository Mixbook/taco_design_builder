part of models;

@observable
class Design {
  static Map<int, Design> layoutIdToDesign = toObservable(new Map<int, Design>());
  static int currentLayoutId;

  int id;
  int layoutId;
  String layoutName;
  String _caml;
  bool dirty = false;

  static String get designsPath => "$designSetsPath/designs";

  static Future<List<Design>> load() {
    return HttpRequest.getString("$designsPath?include_missing_designs=true").then((responseText) {
      List<Map> designsJson = json.parse(responseText)["data"];
      var designs = new List<Design>();
      designsJson.forEach((Map designJson) => designs.add(new Design.fromJson(designJson)));
      return designs;
    });
  }

  Design.fromJson(Map json) {
    id = json["id"];
    layoutId = json["layout_id"];
    layoutName = json["layout_name"];
    _caml = json["caml"];
  }

  void freezeDirty(doWork(design)) {
    var oldDirty = dirty;
    doWork(this);
    dirty = oldDirty;
  }

  String get caml => _caml;
  void set caml (newCaml) {
    dirty = true;
    _caml = newCaml;
  }

  //http://www.dartlang.org/articles/json-web-service/#saving-objects-on-the-server
  bool save() {
    HttpRequest request = new HttpRequest();

    request.onReadyStateChange.listen((_) {
      if (request.readyState == HttpRequest.DONE &&
          (request.status == 200 || request.status == 0)) {
        dirty = false;
        if (id == null) { id = json.parse(request.responseText)["data"]["id"]; }
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
}