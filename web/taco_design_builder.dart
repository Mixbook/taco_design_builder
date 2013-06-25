import 'dart:html';
import 'dart:core';
import 'dart:json' as json;
import 'package:web_ui/web_ui.dart';
import 'package:js/js.dart' as js;
import 'design.dart';
import 'package:taco_design_builder/src/models/asset.dart';
import 'package:caml/caml.dart';
import 'package:caml/taco.dart';

//int designSetId = int.parse(window.location.hash.substring(2));
var editor;
var tacoExtension = new TacoExtension();
@observable CamlRenderer camlRenderer;
@observable CamlElement camlElement;

void main() {
  Design.load(designSetId: 1).then((_) {
    setupAce();
    rerender();
  });
  Asset.load(designSetId: 1);
}

void setupAce() {
  js.scoped(() {
    var ace = js.context.ace;
    editor = new js.Proxy(ace.edit, 'editor');
    editor.setTheme('ace/theme/github');
    editor.getSession().setMode('ace/mode/xml');
    editor.getSession().setTabSize(2);

    // We use editor.session.setValue because it clears the undoManager as well https://github.com/ajaxorg/ace/issues/1243
    editor.session.setValue(Design.current.caml);

    editor.on('change', new js.Callback.many((_, __) => handleEditorChange()));

    js.retain(editor);
  });
}

void handleEditorChange() {
  Design.current.caml = editor.getValue();
}

void rerender() {
  try {
    if (camlRenderer != null) { camlRenderer.detach(); }
    camlElement = new CamlElement.caml(Design.current.caml, extensions: [tacoExtension]);
    camlRenderer = camlElement.createRenderer();
    camlRenderer.debugFocalBoxes = true;
    camlRenderer.attachTo(query("#caml-container"));
  } catch(e) {
    print("Rerender error: $e");
  }
}

void handleSave() {
  print("saving");
  Design.current.save();
}

void handleDesignSelect(Event event) {
  var switchDesign = true;
//  if (Design.current.dirty) {
//    switchDesign = window.confirm("Switch without Saving?");
//  }

  if (switchDesign) {
    Design.currentSelectedValue = ((event.target as SelectElement).value);
    Design.current.freezeDirty((d) => editor.session.setValue(d.caml)); // need to freezeDirty otherwise CB will trigger dirty caml is set.
    rerender();
  } else {
    event.preventDefault();
    (query("#design-select-option-${Design.currentLayoutId}") as OptionElement).selected = true;
  }
}

var designsJson = [
                   {"id": 1, "layout_id": 99, "caml": camlExamples['CLEAN_SLATE']},
                   {"id": null, "name": "kitchen sink", "layout_id": 999, "caml": camlExamples['KITCHEN_SINK']},
                   {"id": null, "layout_id": 9999, "caml": camlExamples['SPARSE']}
                   ];

//var assetsJson = [];
////                  {"sticker": {"id": 1, "type": "sticker"}},
////                  {"sticker": {"id": 2, "type": "sticker"}},
////                  {"background": {"id": 3, "type": "background"}},
////                  {"background": {"id": 4, "type": "background"}}
////                  ];

var camlExamples = {

  'CLEAN_SLATE': '''
<caml xmlns="http://www.mixbook.com/caml/1.0" xmlns:taco="http://www.mixbook.com/taco/1.0">

</caml>
''',

  'KITCHEN_SINK': '''
<caml xmlns="http://www.mixbook.com/caml/1.0" xmlns:taco="http://www.mixbook.com/taco/1.0" 
      width="2000" height="1000">

  <head>
    <regions>
      <Region id="Left" box="0 0 1000 1000"/>
      <Region id="Right" box="1000 0 1000 1000"/>
    </regions>
  </head>

  <taco:Background top="0" bottom="0" left="0" right="0"
                   source="http://naperdesign.com/wp-content/uploads/2010/09/fractals_generative.jpg"/>
  
  <taco:Background top="0" bottom="0" left="0" right="0" 
                   fill="#ffffff" fill-opacity="0.9">
    <Rect bottom="0" width="400" height="100"/>
  </taco:Background>
  
  <taco:Content top="0" bottom="0" left="0" right="0" rotation="0">
    <Ellipse width="200" height="200" bottom="0" right="0"
           fill="#00ff00" fill-opacity="0.25"/>
  
    <Line xFrom="2000" xTo="1000" yFrom="0" yTo="500"
          stroke="#ff0000" stroke-width="10"/>
    
    <Rect x="1300" y="450" width="350" height="325" rotation="55"
          fill="#000000" fill-opacity="1" 
          stroke="#ff0000" stroke-width="20"/>
    
    <Group x="0" width="2000" height="100" flow-type="row" 
           flow-gap="10">
      <Rect width="100#" height="100#"/>
      <Rect width="100#" height="100#"/>
    </Group>
    
    <Group bottom="150" left="0" right="0" height="200" flow-type="row" 
           flow-gap="10">
      <taco:Photo width="100#" height="100#" focalBox="50 50 300 100"
                  stroke="#ffffff" stroke-width="10"/>
      <taco:Photo width="100#" height="100#" rotation="65" focalBox="75 75 400 100"/>
      <taco:Photo width="100#" height="100#" rotation="-25"/>
      <taco:Photo width="100#" height="100#" focalBox="150 20 300 100"/>
    </Group>

    <taco:Sticker x="30" y="20" width="100" height="100" rotation="-25"
                  source="http://www.animationinsider.com/wp-content/uploads/2012/08/yoda.jpg"/>

    <Group x="200" y="200" width="500" height="500" rotation="-10">
      <Rect top="0" bottom="0" left="0" right="0"
            fill="#0000ff" fill-opacity="0.20"/>
      <Bitmap top="25" left="25" right="25" bottom="25" rotation="25"
              source="http://www.animationinsider.com/wp-content/uploads/2012/08/yoda.jpg"/>
      <Ellipse width="100" height="100" 
               horizontalCenter="0" verticalCenter="0"
               fill="#00ff00" fill-opacity="0.5"/>
    </Group>
    
    <Ellipse x="800" y="300" width="200" height="50" fill="#ff0000" fill-opacity="0.25" rotation="45"/>
    
    <Text x="1200" y="300" width="200" height="50"
          font-size="40" rotation="0">
      <TextLine baseline="30">Lorem ipsum dolor sit amet, consectetur</TextLine>
      <TextLine baseline="75" maxWidth="180">squeezed text</TextLine>
    </Text>
  </taco:Content>

</caml>
''',

  'SPARSE': '''
<caml xmlns="http://www.mixbook.com/caml/1.0" xmlns:taco="http://www.mixbook.com/taco/1.0" width="2000" height="1000">
  <Rect x="1300" y="450" width="350" height="325" rotation="55"
          fill="#000000" fill-opacity="1" 
          stroke="#ff0000" stroke-width="20"/>
</caml>
'''
};