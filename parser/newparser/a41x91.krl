{
   "dispatch": [],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "domTest"
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
      "emit": "\n$K('body').append('<div id=\"kobj_loaded\"><\/div>');  $K('#domTestClicker').bind('click',function(){  \t$K('#domTestContent').html('<div id=\"domTestPresent\">Clicked<\/div>');  });  KOBJ.watchDOM('#domTestContent',function(){  \t$K('body').append('<div id=\"domTestWorked\">DOM Test Worked<\/div>');  });            ",
      "foreach": [],
      "name": "domtester",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://k-misc.s3.amazonaws.com/runtime-dependencies/domWatch.html",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a41x91"
}
