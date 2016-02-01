package doom.jsoneditor;

import Doom.*;
import jsoneditor.JSONEditor as JE;
import jsoneditor.JSONEditorOptions as JEOptions;
import jsoneditor.JSONEditorOptions.JSONEditorBaseOptions as JEBaseOptions;
import thx.Dynamics;
using thx.Objects;

@:children(none)
class JSONEditor extends Doom {
  static var eventNames = ["change", "ready"];

  @:api(opt) var mount   : jsoneditor.JSONEditor -> Void;
  @:api(opt) var refresh : jsoneditor.JSONEditor -> Void;
  @:api(opt) var ready   : jsoneditor.JSONEditor -> Void;
  @:api(opt) var change  : jsoneditor.JSONEditor -> Void;

  @:state var value : {};
  @:state var options : jsoneditor.JSONEditorOptions.JSONEditorBaseOptions;

  var editor : JE;
  var _options : JEBaseOptions;

  var events : Map<String, Void -> Void>;

  override function render() {
    return div(["class" => "doom-jsoneditor"]);
  }

  override function didMount() {
    _options = options;
    editor = new JE(element, _options.merge({startval : null != state.value ? state.value : null}));
    setupEvents();
    if(null != api.mount)
      api.mount(editor);
  }

  function setupEvents() {
    events = new Map();
    for(name in eventNames) {
      var fapi = Reflect.field(api, name);
      if(null == fapi) continue;
      var f = function() fapi(editor);
      events.set(name, f);
      editor.on(name, f);
    }
  }

  function clearEvents() {
    if(null == events)
      return;
    for(name in events.keys()) {
      editor.off(name, events.get(name));
    }
  }

  override function didRefresh() {
    if(null == editor) return;
    var current = editor.getValue();
    if(!Dynamics.equals(_options, options)) {
      // if options have changed rebuild everything
      editor.destroy();
      element.innerHTML = "";
      _options = options;
      editor = new JE(element, _options.merge({startval : null != state.value ? state.value : null}));
      if(null != api.mount)
        api.mount(editor);
    } else if(!Dynamics.equals(current, state.value)) {
      // TODO do we need to check if the value changed?
      editor.setValue(state.value);
      if(null != api.refresh)
        api.refresh(editor);
    }
  }

  override function didUnmount() {
    clearEvents();
    editor.destroy();
  }

  function migrate(old : JSONEditor) {
    if(null == old.editor) return;
    old.clearEvents();
    editor = old.editor;
    _options = old.options;
    editor.setValue(state.value);
    setupEvents();
  }
}
