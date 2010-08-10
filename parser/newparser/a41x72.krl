{
   "dispatch": [],
   "global": [{"emit": "\nKOBJ.watchDOM = function(selector,callBackFunc,time){    \tif(!KOBJ.watcherRunning){    \t\t\tKOBJ.log(\"Starting the DOM Watcher\");    \t\t\tvar KOBJ_setInterval = setInterval_native || setInterval;    \t\t\tif(KOBJ.watcherRunning){clearInterval(KOBJ.watcherRunning);}                            KOBJ.watcherData = [];                            KOBJ.watcherData.push({\"selector\": selector,\"callBacks\": [callBackFunc]});    \t\t\t$K(selector+\" :child:first\").addClass(\"KOBJ_AjaxWatcher\");    \t\t\tKOBJ.watcher = function(){    \t\t\t\t$K(KOBJ.watcherData).each(function(){    \t\t\t\t\tvar data = this;    \t\t\t\t\tvar selectorExists = $K(selector).length;    \t\t\t\t\tif(!selectorExists){return;}    \t\t\t\t\tvar hasNotChanged = $K(data.selector+\" :child:first\").is(\".KOBJ_AjaxWatcher\");    \t\t\t\t\tif(!hasNotChanged){    \t\t\t\t\t\t$K(data.callBacks).each(function(){    \t\t\t\t\t\t\tcallBack = this;    \t\t\t\t\t\t\tKOBJ.log(\"Running call back\");    \t\t\t\t\t\t\tcallBack();    \t\t\t\t\t\t});    \t\t\t\t\t\t$K(data.selector+\" :child:first\").addClass(\"KOBJ_AjaxWatcher\");    \t\t\t\t\t}    \t\t\t\t});    \t\t\t};    \t\t\tKOBJ.watcherRunning = KOBJ_setInterval(KOBJ.watcher,time||1000);    \t} else {    \t\t$K(KOBJ.watcherData).each(function(){    \t\t\tdataObj = this;    \t\t\tif(dataObj.selector == selector){    \t\t\t\tdataObj.callBacks.push(callBackFunc);    \t\t\t\t$K(selector+\" :child:first\").addClass(\"KOBJ_AjaxWatcher\");    \t\t\t\tKOBJ.log(\"DOM Watcher Callback for previous selector\",selector,\"added\");    \t\t\t\treturn false;    \t\t\t} else {    \t\t\t\tKOBJ.watcherData.push({\"selector\": selector,\"callBacks\": [callBackFunc]});    \t\t\t\t$K(selector+\" :child:first\").addClass(\"KOBJ_AjaxWatcher\");    \t\t\t\tKOBJ.log(\"DOM Watcher Call for new selector\",selector,\"added\");    \t\t\t}    \t\t});    \t}\t    };                        "}],
   "meta": {
      "logging": "off",
      "name": "Watcher Test"
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
      "emit": "\nmsg = '<div>I rule!! Woo!<\/div>';    \t$K(\"#home_sidebar\").prepend(msg);  \t  \tKOBJ.watchDOM(\"#home_sidebar\",function(){$K(\"#home_sidebar\").prepend(msg);});            ",
      "foreach": [],
      "name": "facebook_ajax_test",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://www.facebook.com/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a41x72"
}
