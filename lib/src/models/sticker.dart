part of models;

final String stickerType = "sticker";

class Sticker extends Asset {
  String get type => stickerType;
  Sticker.fromJson(Map json) : super.fromJson(json);
}

LoadedAssets<Sticker> buildLoadedStickers() {
  return new LoadedAssets<Sticker>(
    new AssetUploadApi(uploadRoot, "stickers"),
    new AssetLinkApi(designSetRoot, "stickers"))
      ..fromAttrFactory = (attrs) => new Sticker.fromJson(attrs);
}