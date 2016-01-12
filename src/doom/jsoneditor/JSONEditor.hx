package doom.jsoneditor;

import Doom.*;
import jsoneditor.JSONEditor as JE;
import jsoneditor.JSONEditorOptions as JEOptions;
import jsoneditor.JSONEditorOptions.JSONEditorBaseOptions as JEBaseOptions;
import thx.Dynamics;
using thx.Objects;

class JSONEditor extends doom.Component<JSONEditorApi, JSONEditorState> {
  var editor : JE;
  var options : JEBaseOptions;
  override function render() {
    return div(["class" => "doom-jsoneditor"]);
  }

  override function didMount() {
    options = state.options;
    editor = new JE(element, options.merge({startval : null != state.value ? state.value : null}));
    if(null != api.onMount)
      api.onMount(editor);
  }

  override function didRefresh() {
    var current = editor.getValue();
    if(!Dynamics.equals(options, state.options)) {
      // if options have changed rebuild everything
      editor.destroy();
      element.innerHTML = "";
      options = state.options;
      editor = new JE(element, options.merge({startval : null != state.value ? state.value : null}));
    } else if(!Dynamics.equals(current, state.value)) {
      // TODO do we need to check if the value changed?
      editor.setValue(state.value);
    }
  }

  override function didUnmount() {
    editor.destroy();
  }

  function migrate(old : JSONEditor) {
    editor = old.editor;
    options = old.options;
  }
}

typedef JSONEditorApi = {
  ?onMount : JE -> Void
}

typedef JSONEditorState = {
  options : JEBaseOptions,
  ?value : {}
}
