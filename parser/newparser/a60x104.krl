{
   "dispatch": [{"domain": "docs.google.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\nfloat example for documentation     \n",
      "logging": "on",
      "name": "float example"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "absolute"
            },
            {
               "type": "str",
               "val": "top: 10px"
            },
            {
               "type": "str",
               "val": "right: 10px"
            },
            {
               "type": "str",
               "val": "http://www.google.com/"
            }
         ],
         "modifiers": [{
            "name": "draggable",
            "value": {
               "type": "bool",
               "val": "true"
            }
         }],
         "name": "float",
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
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://docs.kynetx.com/krl/kynetx-rule-language-documentation/actions/float/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x104"
}
