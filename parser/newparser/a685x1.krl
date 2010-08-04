{
   "dispatch": [],
   "global": [],
   "meta": {
      "author": "Cid Dennis",
      "description": "\n      This is a test app to put as much stuff on one pages as we can to verify as many actions as we can.\n    ",
      "logging": "off",
      "name": "MostCrapOnOnePage"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Hello World"
               },
               {
                  "type": "str",
                  "val": "This is a sample rule."
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
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#area9"
               },
               {
                  "type": "str",
                  "val": "added to area 9"
               }
            ],
            "modifiers": null,
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#area9"
               },
               {
                  "type": "str",
                  "val": "prepend to area 9"
               }
            ],
            "modifiers": null,
            "name": "prepend",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#area9"
               },
               {
                  "type": "str",
                  "val": "<div id='area10'>data after area 9<\/div>"
               }
            ],
            "modifiers": null,
            "name": "after",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#area9"
               },
               {
                  "type": "str",
                  "val": "<div id='area8.5'>data before area 9<\/div>"
               }
            ],
            "modifiers": null,
            "name": "before",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "absolute"
               },
               {
                  "type": "str",
                  "val": "top: 10px"
               },
               {
                  "type": "str",
                  "val": "right: 10px"
               },
               {
                  "type": "str",
                  "val": "http://k-misc.s3.amazonaws.com/runtime-dependencies/floattext.html"
               }
            ],
            "modifiers": null,
            "name": "float",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "absolute"
               },
               {
                  "type": "str",
                  "val": "top:50px"
               },
               {
                  "type": "str",
                  "val": "right:50px"
               },
               {
                  "type": "str",
                  "val": "<h1 id='floatid'>I'm Floating HTML!<\/h1>"
               }
            ],
            "modifiers": null,
            "name": "float_html",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#area4"
               },
               {
                  "type": "str",
                  "val": "#area2"
               }
            ],
            "modifiers": null,
            "name": "move_after",
            "source": null
         }},
         {"action": {
            "args": [{
               "type": "str",
               "val": "#area5"
            }],
            "modifiers": null,
            "name": "move_to_top",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#area6"
               },
               {
                  "type": "str",
                  "val": "<div id='newarea6replace'>new area 6<\/div>"
               }
            ],
            "modifiers": null,
            "name": "replace_html",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#area7"
               },
               {
                  "type": "str",
                  "val": "http://k-misc.s3.amazonaws.com/runtime-dependencies/replacetext.html"
               }
            ],
            "modifiers": null,
            "name": "replace",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#area8"
               },
               {
                  "type": "str",
                  "val": "The content has been replaced"
               }
            ],
            "modifiers": null,
            "name": "replace_inner",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#myimage"
               },
               {
                  "type": "str",
                  "val": "http://k-misc.s3.amazonaws.com/runtime-dependencies/Asshole_20Watcher.jpg"
               }
            ],
            "modifiers": null,
            "name": "replace_image_src",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#mychangeelement"
               },
               {
                  "type": "str",
                  "val": "value"
               },
               {
                  "type": "str",
                  "val": "Ihavechanged"
               }
            ],
            "modifiers": null,
            "name": "set_element_attr",
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
      "name": "first_rule",
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
   "ruleset_name": "a685x1"
}
