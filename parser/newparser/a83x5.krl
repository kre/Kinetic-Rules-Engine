{
   "dispatch": [],
   "global": [{
      "cachable": 0,
      "datatype": "JSON",
      "name": "info_service",
      "source": "http://www.micronotes.info/boa/service.asmx/fetchInfo?",
      "type": "datasource"
   }],
   "meta": {
      "logging": "off",
      "name": "Proxy_MiningBOA"
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
      "emit": "\n$K(\"#resp\").html(xml);          ",
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
         "lhs": "xml",
         "rhs": {
            "args": [{
               "args": [
                  {
                     "type": "str",
                     "val": "id="
                  },
                  {
                     "args": [{
                        "type": "str",
                        "val": "id"
                     }],
                     "predicate": "env",
                     "source": "page",
                     "type": "qualified"
                  }
               ],
               "op": "+",
               "type": "prim"
            }],
            "predicate": "info_service",
            "source": "datasource",
            "type": "qualified"
         },
         "type": "expr"
      }],
      "state": "active"
   }],
   "ruleset_name": "a83x5"
}
