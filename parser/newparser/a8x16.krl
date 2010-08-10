{
   "dispatch": [],
   "global": [{
      "cachable": 0,
      "datatype": "JSON",
      "name": "statravel",
      "source": "http://www.azigo.com/sales-demo/statravel.json",
      "type": "dataset"
   }],
   "meta": {
      "description": "\ntesting dataset interaction   \n",
      "logging": "off",
      "name": "STATest"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "<img src='http://frag.kobj.net/clients/azigo_citi_demo/images/azigo_logo_black_34.png'>"
               },
               {
                  "type": "str",
                  "val": "<p>TEST<\/p>"
               }
            ],
            "modifiers": [
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               },
               {
                  "name": "opacity",
                  "value": {
                     "type": "num",
                     "val": 1
                  }
               },
               {
                  "name": "background_color",
                  "value": {
                     "type": "str",
                     "val": "#000"
                  }
               }
            ],
            "name": "notify",
            "source": null
         }},
         {"action": {
            "args": [{
               "type": "str",
               "val": "span.no_thanks"
            }],
            "modifiers": null,
            "name": "close_notification",
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
      "name": "testrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://www.google.com",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [],
      "state": "active"
   }],
   "ruleset_name": "a8x16"
}
