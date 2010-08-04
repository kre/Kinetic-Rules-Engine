{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "kynetx.com"},
      {"domain": "fogbugz.com"},
      {"domain": "twitter.com"}
   ],
   "global": [],
   "meta": {
      "author": "MikeGrace",
      "description": "\ntesting true execution order of rules     \n",
      "logging": "on",
      "name": "order test"
   },
   "rules": [
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "1.0"
                  },
                  {
                     "type": "str",
                     "val": "first action of first rule"
                  }
               ],
               "modifiers": null,
               "name": "notify",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "1.1"
                  },
                  {
                     "type": "str",
                     "val": "second action of first rule"
                  }
               ],
               "modifiers": null,
               "name": "notify",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "1.2 third action of first rule"
               }],
               "modifiers": null,
               "name": "alert",
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
         "name": "first",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "2.0"
                  },
                  {
                     "type": "str",
                     "val": "first action of second rule"
                  }
               ],
               "modifiers": null,
               "name": "notify",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "2.1"
                  },
                  {
                     "type": "str",
                     "val": "second action of second rule"
                  }
               ],
               "modifiers": null,
               "name": "notify",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "2.2 third action of second rule"
               }],
               "modifiers": null,
               "name": "alert",
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
         "name": "second",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "3.0"
                  },
                  {
                     "type": "str",
                     "val": "first action of third rule"
                  }
               ],
               "modifiers": null,
               "name": "notify",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "3.1"
                  },
                  {
                     "type": "str",
                     "val": "second action of third rule"
                  }
               ],
               "modifiers": null,
               "name": "notify",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "3.2 third action of third rule"
               }],
               "modifiers": null,
               "name": "alert",
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
         "name": "third",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a60x70"
}
