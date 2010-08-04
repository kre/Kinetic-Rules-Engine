{
   "dispatch": [],
   "global": [{"emit": "\nif (!window.console || !console.firebug)    {        var names = [\"log\", \"debug\", \"info\", \"warn\", \"error\", \"assert\", \"dir\", \"dirxml\",        \"group\", \"groupEnd\", \"time\", \"timeEnd\", \"count\", \"trace\", \"profile\", \"profileEnd\"];            window.console = {};        for (var i = 0; i < names.length; ++i)            window.console[names[i]] = function() {}    }        alert(window.console);                    "}],
   "meta": {"description": "\ntesting the console problem between firebug and google reader \n"},
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
      "emit": null,
      "foreach": [],
      "name": "allthingsgoogle",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "www.google.com",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a8x8"
}
