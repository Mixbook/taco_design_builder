library apis;

import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'package:restful/restful.dart';

_getData(Map response) => response["data"];

class UploaderFormat extends Format {
  UploaderFormat() : super(null);

  Object deserialize(String response) => JSON.decode(response);
  serialize(Object formData) => formData;
}

class AssetUploadApi {
  final Resource resource;

  AssetUploadApi(String apiRoot, String resourceName) :
    resource = new RestApi(apiUri: apiRoot, format: JSON_FORMAT).resource(resourceName);

  Future<Map> createFromFile(File file) {
    var formData = new FormData()
        ..appendBlob("Filedata", file);

    // We cannot use resource post because contentType is always set and credentials are never sent.
    return HttpRequest.request(resource.url, method: "post", withCredentials: true, sendData: formData).then((req) {
      return JSON.decode(req.responseText);
    });
  }
}

class AssetLinkApi {
  final Resource resource;

  AssetLinkApi(String apiRoot, String resourceName) :
    resource = new RestApi(apiUri: apiRoot, format: JSON_FORMAT).resource(resourceName);

  Future<Map> create(int id) => resource.create({"id": id}).then(_getData);
  Future<Iterable<Map>> findAll() => resource.findAll().then(_getData);
}

class DesignApi {
  final Resource resource;

  DesignApi(String apiRoot) :
    resource = new RestApi(apiUri: apiRoot, format: JSON_FORMAT).resource("designs");

  Future<Map> create(Map attrs) => resource.create({"design": attrs}).then(_getData);
  Future<Map> save(int id, Map attrs) => resource.save(id, {"design": attrs}).then(_getData);
  Future<Iterable<Map>> findAll() => resource.request('get', "${resource.url}?include_missing_designs=true").then(_getData);
}