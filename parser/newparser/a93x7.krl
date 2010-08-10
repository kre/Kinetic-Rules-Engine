{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "bing.com"},
      {"domain": "yahoo.com"},
      {"domain": "cnn.com"},
      {"domain": "facebook.com"},
      {"domain": "google.co.uk"},
      {"domain": "google.com.pk"},
      {"domain": "msn.com"}
   ],
   "global": [{"emit": " var cidtest = \"asdfasdfas\"; "}],
   "meta": {
      "keys": {"errorstack": "f781d9b65e45f413592a177b8d79988d"},
      "logging": "off",
      "name": "ShowNotify"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "test"
            },
            {
               "type": "str",
               "val": "<a id='rssfeed' href='#'>Click me<\/a><br>test this sucker"
            }
         ],
         "modifiers": [{
            "name": "sticky",
            "value": {
               "type": "bool",
               "val": "true"
            }
         }],
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
      "pre": [],
      "state": "active"
   }],
   "ruleset_name": "a93x7"
}
