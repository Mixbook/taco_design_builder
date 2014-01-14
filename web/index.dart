import 'package:taco_design_builder/src/views/app/app.dart';
import 'package:config/config.dart';
import 'dart:html';

void main() {
  Element container = query(".c-main");

  config = new Config.fromHtmlContainer(container);

  AppView appView = new AppView()
      ..presenter = new AppPresenter();
  appView.appendTo(container);
}