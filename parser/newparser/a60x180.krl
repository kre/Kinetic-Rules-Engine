{
   "dispatch": [{"domain": "www.familysearch.org"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "logging": "on",
      "name": "Family Search example"
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
                  "val": "Check your console for example output."
               }
            ],
            "modifiers": null,
            "name": "notify",
            "source": null
         }},
         {"emit": "\n$K(\"iframe\").contents().find(\"table:eq(0) table:eq(1) tr\").each(function() {            var number = $K(this).find(\"td:eq(1) strong\").text();            var link = $K(this).find(\"td:eq(1) a\").attr(\"href\");            var name = $K(this).find(\"td:eq(1) a\").text();            var meta = $K(this).find(\"td:eq(1) span\").text();            if( number == 23 ) {              console.log(found);            }            console.log(\"Number: \" + number + \"\\nName: \" + name + \"\\nMeta: \" + meta + \"\\nLink: \" + link);          });                        "}
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
         "lhs": "found",
         "rhs": " \n###########################\\n###########################\\n## I found 23!!!!!\\n###########################\\n###########################        \n ",
         "type": "here_doc"
      }],
      "state": "active"
   }],
   "ruleset_name": "a60x180"
}
