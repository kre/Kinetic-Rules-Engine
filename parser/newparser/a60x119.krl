{
   "dispatch": [{"domain": "docs.kynetx.com"}],
   "global": [{
      "content": ".inserted_span {        color: purple;      }    ",
      "type": "css"
   }],
   "meta": {
      "author": "Mike Grace",
      "description": "\nPrepend example for documentation     \n",
      "logging": "on",
      "name": "Prepend Example"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": ":header"
            },
            {
               "type": "str",
               "val": "<span class='inserted_span'>I'm a header!&nbsp;&nbsp;&nbsp;<\/span>"
            }
         ],
         "modifiers": null,
         "name": "prepend",
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
      "name": "the_prepender",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://docs.kynetx.com/krl/kynetx-rule-language-documentation/actions/prepend/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x119"
}
