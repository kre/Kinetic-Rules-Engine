{
   "dispatch": [{"domain": "google.com"}],
   "global": [],
   "meta": {
      "author": "Nathan Whiting",
      "description": "\nDetermine 2000 Points of Axiom data     \n",
      "logging": "on",
      "name": "WhereAmi"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "WhereAmi"
            },
            {
               "type": "var",
               "val": "msg"
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
               "name": "pos",
               "value": {
                  "type": "str",
                  "val": "bottom-right"
               }
            },
            {
               "name": "opacity",
               "value": {
                  "type": "num",
                  "val": 0.9
               }
            },
            {
               "name": "color",
               "value": {
                  "type": "str",
                  "val": "#81cd00"
               }
            },
            {
               "name": "background_color",
               "value": {
                  "type": "str",
                  "val": "#3d5e48"
               }
            }
         ],
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
      "name": "whereami",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "ctrycode",
            "rhs": {
               "args": [],
               "predicate": "country_code",
               "source": "location",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "ctryname",
            "rhs": {
               "args": [],
               "predicate": "country_name",
               "source": "location",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "state",
            "rhs": {
               "args": [],
               "predicate": "region",
               "source": "location",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "city",
            "rhs": {
               "args": [],
               "predicate": "city",
               "source": "location",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "pcode",
            "rhs": {
               "args": [],
               "predicate": "postal_code",
               "source": "location",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "lat",
            "rhs": {
               "args": [],
               "predicate": "latitude",
               "source": "location",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "long",
            "rhs": {
               "args": [],
               "predicate": "longitude",
               "source": "location",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "dmacode",
            "rhs": {
               "args": [],
               "predicate": "dma_code",
               "source": "location",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "areacode",
            "rhs": {
               "args": [],
               "predicate": "area_code",
               "source": "location",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "bname",
            "rhs": {
               "args": [],
               "predicate": "browser_name",
               "source": "useragent",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "bver",
            "rhs": {
               "args": [],
               "predicate": "browser_version",
               "source": "useragent",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "dtime",
            "rhs": {
               "args": [],
               "predicate": "daytime",
               "source": "time",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "mmarket",
            "rhs": {
               "args": [],
               "predicate": "household",
               "source": "mediamarket",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "msg",
            "rhs": " \n<hr />          <h5>Country_Code: #{ctrycode}<br/>          Country_Name: #{ctryname}<br/>          State: #{state}<br/>          City: #{city}<br/>          Zip: #{pcode}<br/>          <hr />          <br/>          Latitude: #{lat}<br/>          Longitude: #{long}<br/>          Dma_Code: #{dmacode}<br/>          Area_Code: #{areacode}<br/>          Tvs In Area: #{mmarket}<br/>          <hr />          <br/>          #{bname}/#{bver}<br/><h5/>          <style>            .KOBJ_message { font-size: 16px; }            .KOBJ_header { font-size: 20px !important; }          <\/style>            \n ",
            "type": "here_doc"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a381x2"
}
