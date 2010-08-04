{
   "dispatch": [],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "FILLTHEFORMS"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "type": "var",
            "val": "data"
         }],
         "modifiers": null,
         "name": "fill_forms",
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
      "name": "fill",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "data",
         "rhs": {
            "type": "hashraw",
            "val": [
               {
                  "lhs": "personal",
                  "rhs": {
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "firstname",
                           "rhs": {
                              "type": "str",
                              "val": "John"
                           }
                        },
                        {
                           "lhs": "lastname",
                           "rhs": {
                              "type": "str",
                              "val": "Doe"
                           }
                        },
                        {
                           "lhs": "email",
                           "rhs": {
                              "type": "str",
                              "val": "john_doe@gmail.com"
                           }
                        },
                        {
                           "lhs": "phone",
                           "rhs": {
                              "type": "str",
                              "val": "8015555432"
                           }
                        }
                     ]
                  }
               },
               {
                  "lhs": "billto",
                  "rhs": {
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "firstname",
                           "rhs": {
                              "type": "str",
                              "val": "John"
                           }
                        },
                        {
                           "lhs": "country",
                           "rhs": {
                              "type": "str",
                              "val": "USA"
                           }
                        },
                        {
                           "lhs": "city",
                           "rhs": {
                              "type": "str",
                              "val": "Schenectady"
                           }
                        },
                        {
                           "lhs": "street2",
                           "rhs": {
                              "type": "str",
                              "val": ""
                           }
                        },
                        {
                           "lhs": "street1",
                           "rhs": {
                              "type": "str",
                              "val": "432 State Street"
                           }
                        },
                        {
                           "lhs": "state",
                           "rhs": {
                              "type": "str",
                              "val": "NY"
                           }
                        },
                        {
                           "lhs": "phone",
                           "rhs": {
                              "type": "str",
                              "val": "5122668140"
                           }
                        },
                        {
                           "lhs": "zip",
                           "rhs": {
                              "type": "str",
                              "val": "12345"
                           }
                        },
                        {
                           "lhs": "lastname",
                           "rhs": {
                              "type": "str",
                              "val": "Doe"
                           }
                        }
                     ]
                  }
               },
               {
                  "lhs": "shipto",
                  "rhs": {
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "firstname",
                           "rhs": {
                              "type": "str",
                              "val": "John"
                           }
                        },
                        {
                           "lhs": "country",
                           "rhs": {
                              "type": "str",
                              "val": "USA"
                           }
                        },
                        {
                           "lhs": "city",
                           "rhs": {
                              "type": "str",
                              "val": "Schenectady"
                           }
                        },
                        {
                           "lhs": "street2",
                           "rhs": {
                              "type": "str",
                              "val": ""
                           }
                        },
                        {
                           "lhs": "street1",
                           "rhs": {
                              "type": "str",
                              "val": "432 State Street"
                           }
                        },
                        {
                           "lhs": "state",
                           "rhs": {
                              "type": "str",
                              "val": "NY"
                           }
                        },
                        {
                           "lhs": "phone",
                           "rhs": {
                              "type": "str",
                              "val": "5122668140 "
                           }
                        },
                        {
                           "lhs": "zip",
                           "rhs": {
                              "type": "str",
                              "val": "12345"
                           }
                        },
                        {
                           "lhs": "lastname",
                           "rhs": {
                              "type": "str",
                              "val": "Doe"
                           }
                        }
                     ]
                  }
               },
               {
                  "lhs": "card",
                  "rhs": {
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "nameoncard",
                           "rhs": {
                              "type": "str",
                              "val": "John Doe"
                           }
                        },
                        {
                           "lhs": "type",
                           "rhs": {
                              "type": "str",
                              "val": "Visa"
                           }
                        },
                        {
                           "lhs": "expiration",
                           "rhs": {
                              "type": "str",
                              "val": "02/2012"
                           }
                        },
                        {
                           "lhs": "verificationcode",
                           "rhs": {
                              "type": "str",
                              "val": "121"
                           }
                        },
                        {
                           "lhs": "number",
                           "rhs": {
                              "type": "str",
                              "val": "4111111111111111"
                           }
                        }
                     ]
                  }
               }
            ]
         },
         "type": "expr"
      }],
      "state": "active"
   }],
   "ruleset_name": "a41x104"
}
