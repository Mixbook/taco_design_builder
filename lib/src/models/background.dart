part of models;

final String backgroundType = "background";

class Background extends Asset {
  String get type => backgroundType;
  Background.fromJson(Map json) : super.fromJson(json);
}

LoadedAssets<Background> buildLoadedBackgrounds() {
  return new LoadedAssets<Background>(
    new AssetUploadApi(uploadRoot, "backgrounds"),
    new AssetLinkApi(designSetRoot, "backgrounds"))
      ..fromAttrFactory = (attrs) => new Background.fromJson(attrs);
}