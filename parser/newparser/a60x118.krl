{
   "dispatch": [{"domain": "docs.kynetx.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\nPopup example for documentation     \n",
      "logging": "on",
      "name": "Popup Example"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "num",
               "val": 0
            },
            {
               "type": "num",
               "val": 0
            },
            {
               "type": "num",
               "val": 1000
            },
            {
               "type": "num",
               "val": 800
            },
            {
               "type": "str",
               "val": "http://api.jquery.com/"
            }
         ],
         "modifiers": null,
         "name": "popup",
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
      "name": "dont_annoy_me_with_popups",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://docs.kynetx.com/krl/kynetx-rule-language-documentation/actions/popup/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x118"
}
