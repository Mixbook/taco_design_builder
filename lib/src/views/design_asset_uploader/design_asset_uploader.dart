library views.design_asset_uploader;

import 'package:taco_design_builder/src/models/asset.dart';
import 'package:web_ui/web_ui.dart';

@observable
class DesignAssetUploaderComponent extends WebComponent {
  static const List<String> FILTERS = Asset.TYPES;

  String currentFilter = FILTERS.first;

  var assets = Asset.all;

  Iterable<Asset> get filteredAssets => assets.where((asset) => asset.type == currentFilter);
}