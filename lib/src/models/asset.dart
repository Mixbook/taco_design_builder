part of models;

class Asset {
  static const TYPES = const ["sticker", "background"];

  int id;
  String type;
  String thumb;
  String original;

  static Future<List<Asset>> load() {
    var loadTypeFutures = TYPES.map((type) => loadType(type));

    return Future.wait(loadTypeFutures).then((List assetLists) {
      List<Asset> assets = new List<Asset>();
      assetLists.forEach((List<Asset> assetList) => assets.addAll(assetList));
      return assets;
    });
  }

  static Future<List<Asset>> loadType(String type) {
    String pluralType = "${type}s";
    String assetsPath = "$designSetsPath/$pluralType";

    return HttpRequest.getString(assetsPath).then((response) {
     List<Map> assetsJson = json.parse(response)["data"];
     List<Asset> assets = new List<Asset>();
     assetsJson.forEach((Map assetJson) => assets.add(new Asset.fromJson(assetJson)));
     return assets;
    });
  }

  static Future<Asset> fromDataUrl({var dataUrl, String type}) {
    String pluralType = "${type}s";
    String uploaderPath = "/$pluralType";
    String assetsPath = "$designSetsPath/$pluralType";

    return postToUploader(uploaderPath, dataUrl).then((assetIdJson) {
      print("Received: $assetIdJson");
      var id = json.parse(assetIdJson)["id"];
      print("Uploaded with id: $id");
      return attachToDesignSet(assetId: id, assetsPath: assetsPath);
    }).then((dataJson) {
      var assetJson = json.parse(dataJson)["data"];
      return new Asset.fromJson(assetJson);
    });
  }

  Asset.fromJson(Map json) {
    type = TYPES.firstWhere((t) => json.containsKey(t));
    id = json[type]["id"];
    thumb = json[type]["thumb"];
    original = json[type]["original"];
  }

  static Future<String> postToUploader(String uploaderPath, dataUrl) {
    Completer completer = new Completer();

    HttpRequest request = new HttpRequest();
    request.onReadyStateChange.listen((_) {
      if (request.readyState == HttpRequest.DONE) {
        if (request.status == 200 || request.status == 0) {
          completer.complete(request.responseText);
        } else {
          completer.completeError(request.responseText);
        }
      }
    });

    request.open("POST", "$uploaderHost$uploaderPath");
    request.withCredentials = true;
    request.setRequestHeader("content-type", "application/x-www-form-urlencoded");
    var params = [];
    Map paramsMap = {"Filedata": dataUrl};
    paramsMap.forEach((k, v) => params.add("$k=${Uri.encodeComponent(v)}"));
    request.send(params.join("&"));
    return completer.future;
  }

  static Future<String> attachToDesignSet({int assetId, String assetsPath}) {
    Completer completer = new Completer();

    HttpRequest request = new HttpRequest();
    request.onReadyStateChange.listen((_) {
      if (request.readyState == HttpRequest.DONE) {
        if (request.status == 200 || request.status == 0) {
          print("attached to ${request.responseText}");
          completer.complete(request.responseText);
        } else {
          completer.completeError(request.responseText);
        }
      }
    });

    request.open("POST", assetsPath);
    request.setRequestHeader("content-type", "application/json");
    request.send(json.stringify({"id": assetId}));
    return completer.future;
  }
}