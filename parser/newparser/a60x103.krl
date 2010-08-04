{
   "dispatch": [{"domain": "docs.kynetx.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\nbefore action example for documentation     \n",
      "logging": "on",
      "name": "before example"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": ".entry-title"
            },
            {
               "type": "str",
               "val": "<h1>I got inserted before the <a href='http://api.jquery.com/category/selectors/'>jQuery selector<\/a> '.entry-title'<\/h1>"
            }
         ],
         "modifiers": null,
         "name": "before",
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
      "name": "before_entry_title",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://docs.kynetx.com/krl/kynetx-rule-language-documentation/actions/before/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x103"
}
