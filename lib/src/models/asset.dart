part of models;

abstract class Asset extends Model {
  int id;
  String thumb;
  String original;

  String get type;
  String get mixbookUri => "mixbook://${type}s/$id";

  Asset.fromJson(Map json) {
    id = json["id"];
    thumb = json["thumb"];
    original = json["original"];
  }
}

typedef Asset AssetFromAttrFactory(Map m);

class LoadedAssets<A extends Asset> extends LoadedModels {
  AssetUploadApi assetUploadApi;
  AssetLinkApi assetLinkApi;

  LoadedAssets(this.assetUploadApi, this.assetLinkApi);

  Future<Iterable<Map>> findAll() => assetLinkApi.findAll();

  Future<A> addFromFile(File file) {
    return assetUploadApi.createFromFile(file)
      .then((idOnlyAttrs) => assetLinkApi.create(idOnlyAttrs["id"]))
      .then(addFromAttrToLoaded);
  }
}