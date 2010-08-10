{
   "dispatch": [{"domain": "google.com"}],
   "global": [{
      "cachable": {
         "period": "seconds",
         "value": "5"
      },
      "datatype": "JSON",
      "name": "diegoevents",
      "source": "http://pipes.yahoo.com/pipes/pipe.run?_id=eab72a01b7076f8bc91edc54dbcc062d&_render=json",
      "type": "dataset"
   }],
   "meta": {
      "author": "Mark Mugleston",
      "description": "\n      test on datasource interaction and pick operator\n    ",
      "logging": "off",
      "name": "Datasource Test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "event header"
            },
            {
               "type": "var",
               "val": "link"
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
      "name": "first_rule",
      "pagetype": {
         "event_expr": {
            "domain": "web",
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         },
         "foreach": []
      },
      "pre": [{
         "lhs": "link",
         "rhs": {
            "args": [{
               "type": "str",
               "val": "$.value.items[0].link"
            }],
            "name": "ick",
            "obj": {
               "type": "var",
               "val": "diegoevents"
            },
            "type": "operator"
         },
         "type": "expr"
      }],
      "state": "active"
   }],
   "ruleset_name": "a659x3"
}
