{
   "dispatch": [{"domain": "appbuilder.kynetx.com"}],
   "global": [{
      "content": "#actions {      z-index: 400;    }    .form-text {      width:150px;    }        ",
      "type": "css"
   }],
   "meta": {
      "author": "Mike Garce",
      "logging": "off",
      "name": "appbuilder css hack"
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
      "emit": null,
      "foreach": [],
      "name": "change_css",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x24"
}
