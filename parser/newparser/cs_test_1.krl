{
   "dispatch": [
      {"domain": "www.windley.com"},
      {"domain": "www.kynetx.com"}
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
      {"emit": " var foobar = 4;    "}
   ],
   "meta": {
      "author": "Phil Windley",
      "description": "\nRuleset that the eval servers use for self testing (cs.t)    \n",
      "logging": "off",
      "name": "CS Test 2"
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
            "pattern": "/foo/bar.html",
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
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Rule 4"
               },
               {
                  "type": "str",
                  "val": "bar"
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
         "name": "test_rule_4",
         "pagetype": {
            "event_expr": {
               "domain": "web",
               "op": "pageview",
               "pattern": "/archives/(\\d+)/foo.html",
               "type": "prim_event",
               "vars": ["year"]
            },
            "foreach": []
         },
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Rule 5"
               },
               {
                  "type": "str",
                  "val": "foo"
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
         "name": "test_rule_5",
         "pagetype": {
            "event_expr": {
               "args": [
                  {
                     "domain": "web",
                     "op": "pageview",
                     "pattern": "bar.html",
                     "type": "prim_event"
                  },
                  {
                     "domain": "web",
                     "op": "pageview",
                     "pattern": "/archives/(\\d+)/foo.html",
                     "type": "prim_event",
                     "vars": ["year"]
                  }
               ],
               "op": "before",
               "type": "complex_event"
            },
            "foreach": []
         },
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Testing And"
               },
               {
                  "type": "str",
                  "val": "foo"
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
         "name": "test_rule_and",
         "pagetype": {
            "event_expr": {
               "args": [
                  {
                     "domain": "web",
                     "op": "pageview",
                     "pattern": "and1.html",
                     "type": "prim_event"
                  },
                  {
                     "domain": "web",
                     "op": "pageview",
                     "pattern": "and2.html",
                     "type": "prim_event"
                  }
               ],
               "op": "and",
               "type": "complex_event"
            },
            "foreach": []
         },
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Or Test Rule"
               },
               {
                  "type": "str",
                  "val": "foo"
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
         "name": "test_rule_or",
         "pagetype": {
            "event_expr": {
               "args": [
                  {
                     "domain": "web",
                     "op": "pageview",
                     "pattern": "or(1).html",
                     "type": "prim_event",
                     "vars": ["num"]
                  },
                  {
                     "domain": "web",
                     "op": "pageview",
                     "pattern": "or(2).html",
                     "type": "prim_event",
                     "vars": ["num"]
                  }
               ],
               "op": "or",
               "type": "complex_event"
            },
            "foreach": []
         },
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Test Rule Then"
               },
               {
                  "type": "str",
                  "val": "foo"
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
         "name": "test_rule_then",
         "pagetype": {
            "event_expr": {
               "args": [
                  {
                     "domain": "web",
                     "op": "pageview",
                     "pattern": "then(1).html",
                     "type": "prim_event",
                     "vars": ["one"]
                  },
                  {
                     "domain": "web",
                     "op": "pageview",
                     "pattern": "then(2).html",
                     "type": "prim_event",
                     "vars": ["two"]
                  }
               ],
               "op": "then",
               "type": "complex_event"
            },
            "foreach": []
         },
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Between Test Rule"
               },
               {
                  "type": "str",
                  "val": "foo"
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
         "name": "test_rule_between",
         "pagetype": {
            "event_expr": {
               "first": {
                  "domain": "web",
                  "op": "pageview",
                  "pattern": "firs(t).html",
                  "type": "prim_event",
                  "vars": ["a"]
               },
               "last": {
                  "domain": "web",
                  "op": "pageview",
                  "pattern": "las(t).html",
                  "type": "prim_event",
                  "vars": ["c"]
               },
               "mid": {
                  "domain": "web",
                  "op": "pageview",
                  "pattern": "mi(d).html",
                  "type": "prim_event",
                  "vars": ["b"]
               },
               "op": "between",
               "type": "complex_event"
            },
            "foreach": []
         },
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Not Between Test Rule"
               },
               {
                  "type": "str",
                  "val": "foo"
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
         "name": "test_rule_notbetween",
         "pagetype": {
            "event_expr": {
               "first": {
                  "domain": "web",
                  "op": "pageview",
                  "pattern": "firs(t)n.html",
                  "type": "prim_event",
                  "vars": ["a"]
               },
               "last": {
                  "domain": "web",
                  "op": "pageview",
                  "pattern": "las(t)n.html",
                  "type": "prim_event",
                  "vars": ["c"]
               },
               "mid": {
                  "domain": "web",
                  "op": "pageview",
                  "pattern": "mi(d)n.html",
                  "type": "prim_event",
                  "vars": ["b"]
               },
               "op": "notbetween",
               "type": "complex_event"
            },
            "foreach": []
         },
         "state": "active"
      },
      {
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
         "name": "test_rule_submit",
         "pagetype": {
            "event_expr": {
               "domain": "web",
               "element": "#my_form",
               "op": "submit",
               "type": "prim_event",
               "vars": ["my_form"]
            },
            "foreach": []
         },
         "state": "active"
      },
      {
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
         "name": "test_rule_google_1",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com/(search)",
            "type": "prim_event",
            "vars": ["search"]
         }},
         "state": "active"
      },
      {
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
         "name": "test_rule_google_2",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": [
               {
                  "name": "address",
                  "value": {
                     "type": "str",
                     "val": "pjw@kynetx.com"
                  }
               },
               {
                  "name": "msg_id",
                  "value": {
                     "type": "num",
                     "val": 15
                  }
               }
            ],
            "name": "forward",
            "source": "email"
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "email_received",
         "pagetype": {
            "event_expr": {
               "domain": "mail",
               "op": "received",
               "type": "prim_event"
            },
            "foreach": []
         },
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": [
               {
                  "name": "to",
                  "value": {
                     "type": "str",
                     "val": "qwb@kynetx.com"
                  }
               },
               {
                  "name": "msg_id",
                  "value": {
                     "type": "num",
                     "val": 35
                  }
               }
            ],
            "name": "send",
            "source": "email"
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "email_sent",
         "pagetype": {
            "event_expr": {
               "domain": "mail",
               "op": "sent",
               "type": "prim_event"
            },
            "foreach": []
         },
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": [
               {
                  "name": "address",
                  "value": {
                     "type": "var",
                     "val": "mail_id"
                  }
               },
               {
                  "name": "return_path",
                  "value": {
                     "type": "var",
                     "val": "rp"
                  }
               },
               {
                  "name": "msg_id",
                  "value": {
                     "type": "num",
                     "val": 25
                  }
               }
            ],
            "name": "forward",
            "source": "email"
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "email_received_from",
         "pagetype": {
            "event_expr": {
               "domain": "mail",
               "filters": [[{
                  "pattern": "(.*)@windley.com",
                  "type": "from"
               }]],
               "op": "received",
               "type": "prim_event",
               "vars": ["mail_id"]
            },
            "foreach": []
         },
         "pre": [{
            "lhs": "rp",
            "rhs": {
               "args": [],
               "name": "c",
               "obj": {
                  "args": [{
                     "type": "str",
                     "val": "msg"
                  }],
                  "predicate": "param",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "operator"
            },
            "type": "expr"
         }],
         "state": "active"
      }
   ],
   "ruleset_name": "cs_test_1"
}
