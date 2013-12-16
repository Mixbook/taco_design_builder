library views.app;
import 'package:taco_design_builder/src/models.dart';
import 'package:taco_helpers/src/mixbook_web_component.dart';
import 'dart:js';
import 'package:web_ui/web_ui.dart';
import 'package:caml/caml.dart';
import 'package:caml/taco.dart';
import 'dart:async';
import 'dart:html';

@observable
class AppPresenter {
  var editor;

  LoadedDesigns loadedDesigns;
  LoadedAssets<Sticker> loadedStickers;
  LoadedAssets<Background> loadedBackgrounds;

  String currentAssetFilter;

  Map<String, LoadedAssets> loadedAssetsByType = {};
  Iterable<String> get assetFilters => loadedAssetsByType.keys;
  LoadedAssets get currentLoadedAssets => loadedAssetsByType[currentAssetFilter];
  Iterable<Asset> get filteredAssets => currentLoadedAssets.loaded;

  Iterable<Design> get designs => loadedDesigns.loaded;
  Design currentDesign;

  var camlElement;
  var region;
  var debugHelpers;
  var useAnimationFrame;
  var visibleGuides;

  AppPresenter() {
    loadedDesigns = buildLoadedDesigns();
    loadedStickers = buildLoadedStickers();
    loadedBackgrounds = buildLoadedBackgrounds();

    loadedAssetsByType["sticker"] = loadedStickers;
    loadedAssetsByType["background"] = loadedBackgrounds;
    currentAssetFilter = assetFilters.first;

    convertToObservable(loadedStickers);
    convertToObservable(loadedBackgrounds);
    convertToObservable(loadedDesigns);

    setupCaml();

    Future.wait([
      loadedStickers.populate(),
      loadedBackgrounds.populate(),
      loadedDesigns.populate().then((_) {
        currentDesign = designs.first;
        setupAce();
        renderCaml();
      })
    ]);
  }

  void convertToObservable(LoadedModels loadedModels) {
    loadedModels.loaded = toObservable(loadedModels.loaded);
  }

  void setupCaml() {
    debugHelpers = true;
    useAnimationFrame = true;
    visibleGuides = "";
    registerExtension(new TacoExtension());
  }

  void handleDesignChange(Event event) {
    var newValue = (event.target as SelectElement).value;
    currentDesign = designs.firstWhere((Design design) => design.layoutId.toString() == newValue);
    currentDesign.freezeDirty((d) => resetEditorValue(d.caml)); // need to freezeDirty otherwise CB will trigger dirty caml is set.
    renderCaml();
  }

  String designOptionLabel(Design design) {
    var prefix = design.id == null ? "UNCREATED " : "";
    return "$prefix Design for Layout ${design.layoutId} (${design.layoutName})";
  }

  void handleUpload(var view) {
    FileUploadInputElement elem = view.query("#upload");
    ButtonElement uploadButton = view.query("#upload-button");
    uploadButton.disabled = true;

    if (elem.files.length == 1) {
      var file = elem.files.first;
      currentLoadedAssets.addFromFile(file).then((_) {
        uploadButton.disabled = false;
      });
      elem.replaceWith(elem.clone(true)); // Clear the upload input afterwards.
    }
  }

  void resetEditorValue(String value) {
    // We use editor.session.setValue because it clears the undoManager as well https://github.com/ajaxorg/ace/issues/1243
    editor['session'].callMethod('setValue', [value]);
  }

  void handleEditorChange() {
    currentDesign.caml = editor.callMethod('getValue', []);
  }

  void setupAce() {
    var ace = context['ace'];
    editor = new JsObject(ace['edit'], ['editor']);
    editor.callMethod('setTheme', ['ace/theme/github']);

    editor['session']
        ..callMethod('setMode', ['ace/mode/xml'])
        ..callMethod('setTabSize', [2]);

    resetEditorValue(currentDesign.caml);
    editor.callMethod('on', ['change', (_, __) => handleEditorChange()]);
  }

  void renderCaml() {
//    query("#caml-container").innerHtml = currentDesign.caml;
    var camlContainer = querySelector("#caml-container");
    try {
      camlElement = new CamlElement.caml(currentDesign.caml);
      camlContainer.innerHtml = ""; // Clear previous error message
    } catch(e) {
      String error = "Rerender error: $e";
      camlContainer.innerHtml = error;
      print(error);
    }
  }

  void handleSave() {
    print("saving");
    currentDesign.save();
  }
}

@observable
class AppView extends MixbookWebComponent {
  AppPresenter presenter;
}
