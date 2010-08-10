{
   "dispatch": [{"domain": "last.fm"}],
   "global": [{
      "cachable": {
         "period": "hours",
         "value": "10"
      },
      "datatype": "XML",
      "name": "tabs",
      "source": "http://www.ultimate-guitar.com/search.php?view_state=advanced",
      "type": "datasource"
   }],
   "meta": {
      "author": "",
      "description": "\n      \n    ",
      "logging": "off",
      "name": "Guitar Lover"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "type": "var",
            "val": "tabs"
         }],
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
      "name": "last_fm",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "^http://www.last.fm/music/(.*?)/(.*?)/(.*?)$",
         "type": "prim_event",
         "vars": [
            "artist",
            "album",
            "song"
         ]
      }},
      "pre": [{
         "lhs": "tabs",
         "rhs": {
            "args": [{
               "type": "hashraw",
               "val": [
                  {
                     "lhs": "band_name",
                     "rhs": {
                        "type": "str",
                        "val": "doors"
                     }
                  },
                  {
                     "lhs": "song_name",
                     "rhs": {
                        "type": "str",
                        "val": "ship"
                     }
                  }
               ]
            }],
            "predicate": "tabs",
            "source": "datasource",
            "type": "qualified"
         },
         "type": "expr"
      }],
      "state": "active"
   }],
   "ruleset_name": "a41x109"
}
