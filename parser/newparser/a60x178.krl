{
   "dispatch": [{"domain": "www.familysearch.org"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "logging": "on",
      "name": "App inject app into iframe"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "I have run!"
               },
               {
                  "type": "str",
                  "val": "look at me"
               }
            ],
            "modifiers": null,
            "name": "notify",
            "source": null
         }},
         {"emit": "\nif( $K(\"iframe#main\").length !== 0 ) {          $K(\"iframe#main\").contents().find(\"head\").append(appMagic);        }                      "}
      ],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": null,
      "foreach": [],
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://www.familysearch.org/eng/search/frameset_search.asp.*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "appMagic",
         "rhs": " \n<script type=\"text/javascript\" charset=\"utf-8\">          var config = {\"rids\":[\"a60x178\"],'a60x178:kynetx_app_version':'dev'}; KOBJ.eval(config);              <\/script>      \n ",
         "type": "here_doc"
      }],
      "state": "active"
   }],
   "ruleset_name": "a60x178"
}
