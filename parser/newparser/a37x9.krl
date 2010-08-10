{
   "dispatch": [],
   "global": [{
      "cachable": 0,
      "datatype": "JSON",
      "name": "external_service",
      "source": "http://www.ingenistics.com/mn/service.php?",
      "type": "datasource"
   }],
   "meta": {
      "logging": "off",
      "name": "Micronotes Sample Remote"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [],
         "modifiers": null,
         "name": "noop",
         "source": null
      }}],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": "\n$K('#result').text(result);          ",
      "foreach": [],
      "name": "sample",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "result",
         "rhs": {
            "args": [{
               "args": [
                  {
                     "type": "str",
                     "val": "q="
                  },
                  {
                     "args": [{
                        "type": "str",
                        "val": "q"
                     }],
                     "predicate": "env",
                     "source": "page",
                     "type": "qualified"
                  }
               ],
               "op": "+",
               "type": "prim"
            }],
            "predicate": "external_service",
            "source": "datasource",
            "type": "qualified"
         },
         "type": "expr"
      }],
      "state": "active"
   }],
   "ruleset_name": "a37x9"
}
