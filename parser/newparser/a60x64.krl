{
   "dispatch": [{"domain": "facebook.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "logging": "on",
      "name": "simple facebook cleaner"
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
      "emit": "\nKOBJ.log(\".......... FIRST EMIT\");          ",
      "foreach": [],
      "name": "simple_strip",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x64"
}
