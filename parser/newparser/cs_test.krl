{
   "dispatch": [
      {"domain": "www.google.com"},
      {
         "domain": "www.yahoo.com",
         "ruleset_id": "cs_test_1"
      },
      {
         "domain": "www.live.com",
         "ruleset_id": "cs_test_1"
      }
   ],
   "global": [
      {
         "cachable": 0,
         "datatype": "JSON",
         "name": "public_timeline",
         "source": "http://twitter.com/statuses/public_timeline.json",
         "type": "dataset"
      },
      {
         "cachable": 1,
         "datatype": "JSON",
         "name": "cached_timeline",
         "source": "http://twitter.com/statuses/public_timeline.json",
         "type": "dataset"
      },
      {"emit": "\nvar foobar = 4;                "}
   ],
   "meta": {
      "author": "Phil Windley",
      "description": "\nRuleset that the eval servers use for self testing (cs.t)     \n",
      "logging": "off",
      "name": "CS Test 1"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kynetx_12"
               },
               {
                  "type": "str",
                  "val": "/kynetx/google_ad.inc"
               }
            ],
            "modifiers": null,
            "name": "replace",
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
         "name": "test_rule_1",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "/([^/]+)/bar.html",
            "type": "prim_event",
            "vars": ["x"]
         }},
         "state": "active"
      },
      {
         "actions": [
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
                     "args": [
                        {
                           "type": "str",
                           "val": "http://frag.kobj.net/widgets/weather.pl?zip="
                        },
                        {
                           "args": [
                              {
                                 "type": "var",
                                 "val": "zip"
                              },
                              {
                                 "args": [
                                    {
                                       "type": "str",
                                       "val": "&city="
                                    },
                                    {
                                       "args": [
                                          {
                                             "type": "var",
                                             "val": "city"
                                          },
                                          {
                                             "args": [
                                                {
                                                   "type": "str",
                                                   "val": "&state="
                                                },
                                                {
                                                   "type": "var",
                                                   "val": "state"
                                                }
                                             ],
                                             "op": "+",
                                             "type": "prim"
                                          }
                                       ],
                                       "op": "+",
                                       "type": "prim"
                                    }
                                 ],
                                 "op": "+",
                                 "type": "prim"
                              }
                           ],
                           "op": "+",
                           "type": "prim"
                        }
                     ],
                     "op": "+",
                     "type": "prim"
                  }
               ],
               "modifiers": [
                  {
                     "name": "delay",
                     "value": {
                        "type": "num",
                        "val": 0
                     }
                  },
                  {
                     "name": "draggable",
                     "value": {
                        "type": "bool",
                        "val": "true"
                     }
                  },
                  {
                     "name": "effect",
                     "value": {
                        "type": "str",
                        "val": "appear"
                     }
                  }
               ],
               "name": "float",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "kynetx_12"
                  },
                  {
                     "type": "str",
                     "val": "/kynetx/google_ad.inc"
                  }
               ],
               "modifiers": null,
               "name": "float",
               "source": null
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "args": [],
            "predicate": "search_engine_referer",
            "source": "referer",
            "type": "qualified"
         },
         "emit": null,
         "foreach": [],
         "name": "test_rule_2",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "/foo/bazz.html",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [],
         "state": "active"
      },
      {
         "actions": [
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
                     "args": [
                        {
                           "type": "str",
                           "val": "http://frag.kobj.net/widgets/weather.pl?zip="
                        },
                        {
                           "args": [
                              {
                                 "type": "var",
                                 "val": "zip"
                              },
                              {
                                 "args": [
                                    {
                                       "type": "str",
                                       "val": "&city="
                                    },
                                    {
                                       "args": [
                                          {
                                             "type": "var",
                                             "val": "city"
                                          },
                                          {
                                             "args": [
                                                {
                                                   "type": "str",
                                                   "val": "&state="
                                                },
                                                {
                                                   "type": "var",
                                                   "val": "state"
                                                }
                                             ],
                                             "op": "+",
                                             "type": "prim"
                                          }
                                       ],
                                       "op": "+",
                                       "type": "prim"
                                    }
                                 ],
                                 "op": "+",
                                 "type": "prim"
                              }
                           ],
                           "op": "+",
                           "type": "prim"
                        }
                     ],
                     "op": "+",
                     "type": "prim"
                  }
               ],
               "modifiers": [
                  {
                     "name": "delay",
                     "value": {
                        "type": "num",
                        "val": 0
                     }
                  },
                  {
                     "name": "draggable",
                     "value": {
                        "type": "bool",
                        "val": "true"
                     }
                  },
                  {
                     "name": "effect",
                     "value": {
                        "type": "str",
                        "val": "appear"
                     }
                  }
               ],
               "name": "float",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "kynetx_12"
                  },
                  {
                     "type": "str",
                     "val": "/kynetx/google_ad.inc"
                  }
               ],
               "modifiers": null,
               "name": "float",
               "source": null
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "args": [],
            "predicate": "search_engine_referer",
            "source": "referer",
            "type": "qualified"
         },
         "emit": null,
         "foreach": [],
         "name": "test_rule_3",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "/foo/bazz.html",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [],
         "state": "inactive"
      }
   ],
   "ruleset_name": "cs_test"
}
