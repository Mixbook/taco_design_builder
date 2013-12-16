part of models;

final DesignApi designApi = new DesignApi(designSetRoot);

@observable
class Design extends Model {
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

  bool save() {
    if (id == null) {
      designApi.create({"caml": caml, "layout_id": layoutId}).then((data) {
        id = data["id"];
        dirty = false;
      });
    } else {
      designApi.save(id, {"caml": caml}).then((data) {
        dirty = false;
      });
    }
  }
}

class LoadedDesigns extends LoadedModels<Design> {
  final DesignApi designApi;

  LoadedDesigns(this.designApi);

  Future<Iterable<Map>> findAll() => designApi.findAll();
}

LoadedDesigns buildLoadedDesigns() {
  return new LoadedDesigns(designApi)
    ..fromAttrFactory = (attrs) => new Design.fromJson(attrs);
}