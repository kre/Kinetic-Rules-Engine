{
   "dispatch": [],
   "global": [],
   "meta": {
      "description": "\nCreates a \"PopIn' as seen on www.uservoice.com     \n",
      "logging": "off",
      "name": "runtime-addition-pop-in"
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
      "emit": "\nKOBJ.createPopIn = function(config,content) {    \tdefaults = {    \t\t\"position\": \"left-center\",  \t\t\"imageLocation\": \"http://k-misc.s3.amazonaws.com/actions/pop_in_feedback.jpg\",  \t\t\"bg_color\": \"#FFFFFF\",  \t\t\"link_color\": \"#FF0000\",  \t\t\"overlay_color\": \"#000000\",  \t\t\"width\": \"20%\",  \t\t\"opacity-dialog\": \"1\",  \t\t\"opacity-overlay\": \".85\",  \t\t\"id\": \"popInTest\"  \t    \t};  \tif (typeof config === 'object') {  \t\tjQuery.extend(defaults, config);  \t}    \tvar side1;  \tvar side2;  \tvar distance;    \tswitch(defaults[\"position\"])  \t{  \tcase \"top-left\":  \t\tside1 = \"top\";  \t\tside2 = \"left\";  \t\tdistance = \"10%\";  \t\tbreak;  \tcase \"top-center\":  \t\tside1 = \"top\";  \t\tside2 = \"left\";  \t\tdistance = \"45%\";  \t\tbreak;  \tcase \"top-right\":  \t\tside1 = \"top\";  \t\tside2 = \"right\";  \t\tdistance = \"10%\";  \t\tbreak;  \tcase \"bottom-left\":  \t\tside1 = \"bottom\";  \t\tside2 = \"left\";  \t\tdistance = \"10%\";  \t\tbreak;  \tcase \"bottom-center\":  \t\tside1 = \"bottom\";  \t\tside2 = \"left\";  \t\tdistance = \"45%\";  \t\tbreak;  \tcase \"bottom-right\":  \t\tside1 = \"bottom\";  \t\tside2 = \"right\";  \t\tdistance = \"10%\";  \t\tbreak;  \tcase \"left-top\":  \t\tside1 = \"left\";  \t\tside2 = \"top\";  \t\tdistance = \"10%\";  \t\tbreak;  \tcase \"left-center\":  \t\tside1 = \"left\";  \t\tside2 = \"top\";  \t\tdistance = \"45%\";  \t\tbreak;  \tcase \"left-bottom\":  \t\tside1 = \"left\";  \t\tside2 = \"bottom\";  \t\tdistance = \"10%\";  \t\tbreak;  \tcase \"right-top\":  \t\tside1 = \"right\";  \t\tside2 = \"top\";  \t\tdistance = \"10%\";  \t\tbreak;  \tcase \"right-center\":  \t\tside1 = \"right\";  \t\tside2 = \"top\";  \t\tdistance = \"45%\";  \t\tbreak;  \tcase \"right-bottom\":  \t\tside1 = \"right\";  \t\tside2 = \"bottom\";  \t\tdistance = \"10%\";  \t\tbreak;  \tdefault:  \t\tside1 = \"left\";  \t\tside2 = \"top\";  \t\tdistance = \"45%\";  \t\tbreak;  \t}  \t  \t$K('body').append('<div id=\"KOBJ_'+defaults[\"id\"]+'_Link\" style=\"'+side1+': 0; '+side2+':'+distance+'; -moz-border-radius-bottomright: 12px; -moz-border-radius-topright: 12px; background-color:'+defaults[\"link_color\"]+'; display:block; margin-top:-45px; position: fixed;  z-index:100001;\"><a href=\"javascript:KOBJ_create_pop_in()\"><img src=\"'+defaults[\"imageLocation\"]+'\" alt=\"KOBJ_pop_in\" border=\"none\" /><\/a>');  \tKOBJ_create_pop_in = function() {  \t\tvar OverlayPresent = $K('#KOBJ_'+defaults[\"id\"]+'_Overlay').length;  \t\tvar ContentPresent = $K('#KOBJ_'+defaults[\"id\"]+'_Dialog').length;  \t  \t\tif(OverlayPresent) {  \t\t\t$K('#KOBJ_'+defaults[\"id\"]+'_Overlay').fadeIn('slow');  \t\t}  \t\tif(ContentPresent) {  \t\t\t$K('#KOBJ_'+defaults[\"id\"]+'_Dialog').fadeIn('slow');  \t\t}  \t\tif(!OverlayPresent) {  \t\t\t$K('body').append('<div id=\"KOBJ_'+defaults[\"id\"]+'_Overlay\" style=\"display: block; position: fixed; background-color: '+defaults[\"overlay_color\"]+'; height: 100%; width: 100%; left: 0;  filter:alpha(opacity='+defaults[\"opacity-overlay\"]*100+'); opacity: '+defaults[\"opacity-overlay\"]+'; top: 0; z-index: 100002; display: none;\" />');  \t\t\t$K('#KOBJ_'+defaults[\"id\"]+'_Overlay').fadeIn('slow');  \t\t}  \t\tif(!ContentPresent) {  \t\t\t$K('body').append('<div id=\"KOBJ_'+defaults[\"id\"]+'_Dialog\" style=\"top: 45%; right: 40%; -moz-border-radius: 5px; display: block; height: auto; width: '+defaults[\"width\"]+'; position: fixed; margin: 0 auto; text-align: center; z-index: 100003; display: none; background: '+defaults[\"bg_color\"]+'; filter:alpha(opacity='+defaults[\"opacity-dialog\"]*100+'); opacity: '+defaults[\"opacity-dialog\"]+'; \"><div class=\"close\" id=\"KOBJ_'+defaults[\"id\"]+'_Close\" style=\"cursor: pointer; float: right; font-weight: bold; margin-right: 8px; margin-top: 5px;\">x<\/div><div id=\"KOBJ_'+defaults[\"id\"]+'_Content\" style=\"padding: 10px; \">'+content+'<\/div><\/div>');  \t\t\t$K('#KOBJ_'+defaults[\"id\"]+'_Close').click(function() {KOBJ.close_pop_in(defaults[\"id\"]);});  \t\t\t$K('#KOBJ_'+defaults[\"id\"]+'_Dialog').fadeIn('slow');  \t\t}  \t  \t};  \t  \tKOBJ.close_pop_in = function(Id) {  \t\t  \t\t$K('#KOBJ_'+Id+'_Overlay').fadeOut('slow');  \t\t$K('#KOBJ_'+Id+'_Dialog').fadeOut('slow');  \t  \t};    };    popin_options = {};    KOBJ.createPopIn(popin_options,'<h1>hello<\/h1> world!');            ",
      "foreach": [],
      "name": "popin",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a41x50"
}
