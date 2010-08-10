{
   "dispatch": [{"domain": "docs.kynetx.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\nReplace HTML Example for documentation     \n",
      "logging": "on",
      "name": "Replace HTML Example"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "#replacement_area"
            },
            {
               "type": "str",
               "val": "<h1>All your HTML are belong to us!<\/h1>"
            }
         ],
         "modifiers": null,
         "name": "replace_html",
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
      "name": "replacing_your_html",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://docs.kynetx.com/krl/kynetx-rule-language-documentation/actions/replace-html/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x122"
}
