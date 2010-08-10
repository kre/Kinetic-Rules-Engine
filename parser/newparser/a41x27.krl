{
   "dispatch": [
      {"domain": "yahoo.com"},
      {"domain": "bing.com"},
      {"domain": "google.com"},
      {"domain": "cnn.com"},
      {"domain": "chevelle.confettiantiques.com"}
   ],
   "global": [{
      "content": "#KOBJ_replace {background-color: black;}        ",
      "type": "css"
   }],
   "meta": {
      "logging": "on",
      "name": "AutoJAM Tests"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [{
               "type": "str",
               "val": "KOBJ_alert"
            }],
            "modifiers": null,
            "name": "alert",
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
         "name": "alert",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "[^chevelle]\\w+",
            "type": "prim_event",
            "vars": []
         }},
         "state": "inactive"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "body"
               },
               {
                  "type": "str",
                  "val": "<span id='KOBJ_after'>KOBJ_after<\/span>"
               }
            ],
            "modifiers": null,
            "name": "after",
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
         "name": "after",
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
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "body"
               },
               {
                  "type": "str",
                  "val": "<div id='KOBJ_app_bef_aft_test'><span id='KOBJ_append'>KOBJ_append<\/span><\/div>"
               }
            ],
            "modifiers": null,
            "name": "append",
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
         "name": "append",
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
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#KOBJ_append"
               },
               {
                  "type": "str",
                  "val": "<span id='KOBJ_before'>KOBJ_before<\/span>"
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
         "name": "before",
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
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "absolute"
               },
               {
                  "type": "str",
                  "val": "top:10px"
               },
               {
                  "type": "str",
                  "val": "right:10px"
               },
               {
                  "type": "str",
                  "val": "http://k-misc.s3.amazonaws.com/random/test/annotate.html"
               }
            ],
            "modifiers": null,
            "name": "float",
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
         "name": "float",
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
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "absolute"
               },
               {
                  "type": "str",
                  "val": "bottom:10px"
               },
               {
                  "type": "str",
                  "val": "left:10px"
               },
               {
                  "type": "str",
                  "val": "<span id='KOBJ_float_html'>KOBJ_float_html<\/span>"
               }
            ],
            "modifiers": null,
            "name": "float_html",
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
         "name": "float_html",
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
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#KOBJ_before"
               },
               {
                  "type": "str",
                  "val": "#KOBJ_after"
               }
            ],
            "modifiers": null,
            "name": "move_after",
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
         "name": "move_after",
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
         "actions": [{"action": {
            "args": [{
               "type": "str",
               "val": "#KOBJ_float_html"
            }],
            "modifiers": null,
            "name": "move_to_top",
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
         "name": "move_to_top",
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
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "KOBJ_test"
               },
               {
                  "type": "str",
                  "val": "<div id='KOBJ_notify'><h3>KOBJ_notify<\/h3><\/div>"
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
         "name": "notify",
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
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#KOBJ_float_html"
               },
               {
                  "type": "str",
                  "val": "<span id='KOBJ_prepend'>KOBJ_prepend<\/span>"
               }
            ],
            "modifiers": null,
            "name": "prepend",
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
         "name": "prepend",
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
   "ruleset_name": "a41x27"
}
