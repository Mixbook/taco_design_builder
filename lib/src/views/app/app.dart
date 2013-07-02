library views.app;
import 'package:taco_design_builder/src/models.dart';
import 'package:taco_client/mixbook_web_component.dart';
import 'package:js/js.dart' as js;
import 'package:web_ui/web_ui.dart';
import 'package:caml/caml.dart';
import 'package:caml/taco.dart';
import 'dart:async';
import 'dart:html';

@observable
class AppPresenter {
  static const ASSET_FILTERS = Asset.TYPES;

  var editor;

  List<String> assetFilters = ASSET_FILTERS;
  String currentFilter = ASSET_FILTERS.first;

  List<Asset> assets = toObservable(new List<Asset>());
  Iterable<Asset> get filteredAssets => assets.where((asset) => asset.type == currentFilter);

  List<Design> designs = toObservable(new List<Design>());
  Design currentDesign;

  var camlElement;
  var camlRenderer;
  var tacoExtension = new TacoExtension();

  AppPresenter() {
    Future.wait([
      Asset.load().then((loaded) => assets.addAll(loaded)),
      Design.load().then((loaded) {
        designs.addAll(loaded);
        currentDesign = designs.first;
        setupAce();
        renderCaml();
        registerScheme();
    })]);
  }

  void handleDesignChange(Event event) {
    var newValue = (event.target as SelectElement).value;
    currentDesign = designs.firstWhere((Design design) => design.layoutId.toString() == newValue);
    currentDesign.freezeDirty((d) => editor.session.setValue(d.caml)); // need to freezeDirty otherwise CB will trigger dirty caml is set.
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
      File file = elem.files.first;
      FileReader reader = new FileReader();
      reader.onLoadEnd.listen((_) {
        Asset.fromDataUrl(dataUrl: reader.result, type: currentFilter).then((Asset asset) {
          assets.add(asset);
          uploadButton.disabled = false;
        });
      });
      reader.readAsDataUrl(file);
      print("read");
      elem.replaceWith(elem.clone(true)); // Clear the upload input afterwards.
    }
  }

  void setupAce() {
    js.scoped(() {
      var ace = js.context.ace;
      editor = new js.Proxy(ace.edit, 'editor');
      editor.setTheme('ace/theme/github');
      editor.getSession().setMode('ace/mode/xml');
      editor.getSession().setTabSize(2);

      // We use editor.session.setValue because it clears the undoManager as well https://github.com/ajaxorg/ace/issues/1243
      editor.session.setValue(currentDesign.caml);

      editor.on('change', new js.Callback.many((_, __) => handleEditorChange()));

      js.retain(editor);
    });
  }

  void handleEditorChange() {
    currentDesign.caml = editor.getValue();
  }

  void renderCaml() {
//    query("#caml-container").innerHtml = currentDesign.caml;
    var camlContainer = query("#caml-container");
    try {
      if (camlRenderer != null) { camlRenderer.detach(); }
      camlElement = new CamlElement.caml(currentDesign.caml, extensions: [tacoExtension]);
      camlRenderer = camlElement.createRenderer();
      camlRenderer.debugFocalBoxes = true;
      camlContainer.innerHtml = ""; // Clear previous error message
      camlRenderer.attachTo(camlContainer);
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
