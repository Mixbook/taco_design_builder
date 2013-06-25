library models.asset;

import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'dart:json' as json;

@observable
class Asset {
  static const String STICKER_TYPE = "sticker";
  static const String BACKGROUND_TYPE = "background";
  static const List<String> TYPES = const [STICKER_TYPE, BACKGROUND_TYPE];

  static final List<Asset> all = toObservable(new List<Asset>());

  int id;
  String type;

  Asset.fromJson(Map json) {
    type = json.containsKey("sticker") ? "sticker" : "background";
    id = json[type]["id"];
  }

  static addFromAssetsJson(List assetsJson) {
    assetsJson.forEach((Map assetJson) {
      var asset = new Asset.fromJson(assetJson);
      all.add(asset);
    });
  }

  String get thumb => "${designSetPath}/${type}s/${id}/thumb";

  static void load({int designSetId}) {
    TYPES.forEach((type) => loadType(designSetId, type));
  }

  static String get designSetPath {
      int designSetId = int.parse(window.location.hash.substring(1));
      return "${window.location.origin}/taco/api/design_sets/${designSetId}";
  }

  static void loadType(int designSetId, String type) {
    HttpRequest.getString("${designSetPath}/${type}s").then((response) {
     addFromAssetsJson(json.parse(response)["data"]);
    });
  }
}