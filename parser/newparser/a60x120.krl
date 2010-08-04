{
   "dispatch": [{"domain": "docs.kynetx.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\nRedirect example for documentation     \n",
      "logging": "on",
      "name": "Redirect Example"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Redirecting"
               },
               {
                  "type": "str",
                  "val": "You are being redirected to api.jquery.com"
               }
            ],
            "modifiers": null,
            "name": "notify",
            "source": null
         }},
         {"action": {
            "args": [{
               "type": "str",
               "val": "http://api.jquery.com/"
            }],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 3
               }
            }],
            "name": "redirect",
            "source": null
         }}
      ],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": null,
      "foreach": [],
      "name": "redirector",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://docs.kynetx.com/krl/kynetx-rule-language-documentation/actions/redirect/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x120"
}
