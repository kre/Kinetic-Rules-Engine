{
   "dispatch": [],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "runtime-addition-bar"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [],
         "modifiers": null,
         "name": "noop",
         "source": null
      }}],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": "\nbar_close = function(id) {  \t$K('#'+id).fadeOut('slow');  };    bar = function(config,content) {  \t  \tdefaults = {      \t\t\"sticky\": false,  \t\t\"width\": \"98.5%\",  \t\t\"height\": \"30px\",  \t\t\"id\": \"KOBJ_test_bar\",  \t\t\"bg_color\": \"#222222\",  \t\t\"delay\": 3000,  \t\t\"position\": \"bottom\",  \t\t\"opacity\": \".8\",  \t\t\"color\": \"#ffffff\"    \t};  \tif (typeof config === 'object') {  \t\tif(config[\"sticky\"] === true) {  \t\t\tconfig[\"delay\"] = false;  \t\t}  \t\tjQuery.extend(defaults, config);    \t}  \t\tvar side = \"\";  \t\tvar corners = \"\";  \t\tvar direction = \"\";  \t\t  \tswitch(defaults[\"position\"]) {  \tcase \"top\":  \t\tside = \"top\";  \t\tcorners = \"bottom\";  \t\tdirection = \"down\";  \t\tbreak;  \tcase \"bottom\":  \t\tside = \"bottom\";  \t\tcorners = \"top\";  \t\tdirection = \"up\";  \t\tbreak;  \tdefault:  \t\tside = \"bottom\";  \t\tcorners = \"top\";  \t\tdirection = \"up\";  \t\tbreak;  \t}      \t$K('body').append('<div id=\"'+defaults[\"id\"]+'_wrapper\" style=\"display: none; position: fixed; '+side+': 0; width: 100%; height: '+defaults[\"height\"]+';\"><div id=\"'+defaults[\"id\"]+'\" style=\"color: '+defaults[\"color\"]+'; height: '+defaults[\"height\"]+'; background: '+defaults[\"bg_color\"]+'; opacity: '+defaults[\"opacity\"]+'; -moz-border-radius-'+corners+'right: 5px; -moz-border-radius-'+corners+'left: 5px; margin-left: 12px; margin-right: 30px; width: '+defaults[\"width\"]+'; margin: 0 auto;\"><div class=\"close\" style=\"float: right; font-weight: bold; font-size: 20px; cursor: pointer; margin-right: 10px; margin-top: 5px;\">x<\/div><div class=\"KOBJ_bar_content\" style=\"color: '+defaults[\"color\"]+';\">'+content+'<\/div><\/div>');  \t$K('#'+defaults[\"id\"]+'>.close').click(function() { bar_close(defaults[\"id\"]); });  \t$K('#'+defaults[\"id\"]+'_wrapper').slideDown('slow');  \tif(defaults[\"sticky\"] === false) {  \t\tsetTimeout(function() {bar_close(defaults[\"id\"]);},defaults[\"delay\"]);  \t}      };      bar({\"sticky\": false, \"position\":\"bottom\"},'<span style=\"color: white\">hi<\/span>');                ",
      "foreach": [],
      "name": "bar",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a41x51"
}
