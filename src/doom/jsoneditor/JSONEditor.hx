package doom.jsoneditor;

import doom.html.Html.*;
import jsoneditor.JSONEditor as JE;
import jsoneditor.JSONEditorOptions.JSONEditorBaseOptions as JEBaseOptions;
import thx.Dynamics;
using thx.Objects;

class JSONEditor extends doom.html.Component<JSONEditorProps> {
  static var eventNames = ["change", "ready"];

  var editor : JE;
  var _options : JEBaseOptions;
  var events : Map<String, Void -> Void>;

  override function render() {
    return div(["class" => "doom-jsoneditor"]);
  }

  function onReady() {
    if(isUnmounted) return;
    editor.setValue(props.value);
    setupEvents();
    if(null != props.mount)
      props.mount(editor);
  }

  override function didMount() {
    _options = props.options;
    editor = new JE(element, _options.merge({startval : (null : {})}));
    editor.on("ready", onReady);
  }

  override function shouldRender()
    return false;

  function setupEvents() {
    events = new Map();
    for(name in eventNames) {
      var fapi = Reflect.field(props, name);
      if(null == fapi) continue;
      var f = function() fapi(editor);
      events.set(name, f);
      editor.on(name, f);
    }
  }

  function clearEvents() {
    if(null == events || null == editor)
      return;
    for(name in events.keys()) {
      editor.off(name, events.get(name));
    }
  }

  override function didUpdate() {
    if(null == editor || !editor.ready || isUnmounted) return;
    clearEvents();
    var current = editor.getValue();
    if(!Dynamics.equals(_options, props.options)) {
      // if options have changed rebuild everything
      editor.destroy();
      element.innerHTML = "";
      _options = props.options;
      editor = new JE(element, _options.merge({startval : null != props.value ? props.value : null}));
      editor.on("ready", onReady);
      if(null != props.mount)
        props.mount(editor);
    } else if(!Dynamics.equals(current, props.value)) {
      editor.setValue(props.value);
      if(null != props.refresh)
        props.refresh(editor);
      setupEvents();
    }
  }

  override function willUnmount() {
    clearEvents();
    if(null != editor)
      editor.destroy();
  }
}

typedef JSONEditorProps = {
  ?mount   : jsoneditor.JSONEditor -> Void,
  ?refresh : jsoneditor.JSONEditor -> Void,
  ?ready   : jsoneditor.JSONEditor -> Void,
  ?change  : jsoneditor.JSONEditor -> Void,
  ?value   : {},
  ?options : jsoneditor.JSONEditorOptions.JSONEditorBaseOptions
}
