{
   "dispatch": [{"domain": "example.com"}],
   "global": [{
      "cachable": 0,
      "datatype": "JSON",
      "name": "twitter_search",
      "source": "http://search.twitter.com/search.json",
      "type": "datasource"
   }],
   "meta": {
      "author": "Mike Grace",
      "description": "\nexample for devex    \n",
      "logging": "on",
      "name": "Twitter search"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "JSON"
            },
            {
               "type": "var",
               "val": "json"
            }
         ],
         "modifiers": null,
         "name": "notify",
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
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "json",
         "rhs": {
            "args": [{
               "type": "str",
               "val": "q=kynetx"
            }],
            "predicate": "twitter_search",
            "source": "datasource",
            "type": "qualified"
         },
         "type": "expr"
      }],
      "state": "active"
   }],
   "ruleset_name": "a60x155"
}
