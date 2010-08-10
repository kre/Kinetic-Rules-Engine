{
   "dispatch": [{"domain": "facebook.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\nGetting rid of those annoying ads     \n",
      "logging": "on",
      "name": "Cleaner Facebook"
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
      "emit": "\nfunction zap() {      try {        $K(\"#pagelet_ads\").replaceWith(\"<div id='sidebar_ads'><\/div>\");      } catch(e) {}      try {        $K(\"#pagelet_adbox\").replaceWith(\"<div id='sidebar_ads'><\/div>\");      } catch(e) {}      try {        $K(\"#sidebar_ads\").replaceWith(\"<div id='sidebar_ads'><\/div>\");      } catch(e) {}        KOBJ.log(\"....... zap!\");    }         function sweeper() {      setTimeout(\"zap()\",4000);      KOBJ.log(\"..... sweeper\");    }         function pageChange() {      zap();      sweeper();      KOBJ.log(\"...... pageChange\");    }          KOBJ.watchDOM(\"#content\",pageChange);    KOBJ.watchDOM(\"#menubar_container\",pageChange);    KOBJ.watchDOM(\"#pagefooter\",pageChange);    KOBJ.watchDOM(\"#pagelet_presence\",pageChange);          zap();    sweeper();                  ",
      "foreach": [],
      "name": "ad_stripper",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x60"
}
