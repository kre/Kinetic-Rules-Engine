{
   "dispatch": [],
   "global": [{
      "content": "\n\t\t\t.percolated {\n\t\t\t    \tbackground-color : #F80000;    \n\t\t\t}\n\t\t\t\n\t\t\t#kGrowl {\n\t\t\t\tright:100% !important;\n\t\t\t\tleft:0px !important;\n\t\t\t}\n\t\t",
      "type": "css"
   }],
   "meta": {
      "author": "AKO & JAM",
      "description": "\n\t\t\tA demo of the action Percolate    \n\t\t\t",
      "logging": "off",
      "name": "Percolate Demo"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "selector"
            }],
            "modifiers": null,
            "name": "percolate",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\n\t\t\t\tKOBJ.randomNumber = 0;\n\t\t\t\tfunction selector(obj){\n\t\t\t\t\tKOBJ.randomNumber++;\n\t\t\t\t\tif(KOBJ.randomNumber == 26 || KOBJ.randomNumber == 45 || KOBJ.randomNumber == 89 || KOBJ.randomNumber == 94){\n\t\t\t\t\t\treturn true;\n\t\t\t\t\t} else {\n\t\t\t\t\t\treturn false;\n\t\t\t\t\t}\n\t\t\t\t}\n\t\t\t",
         "foreach": [],
         "name": "percolate_via_result_num",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com|search.yahoo.com|bing.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "inactive"
      },
      {
         "actions": [
            {"emit": "\n\t\t\t\t$K('#undoify').live('click', function() {\n\t\t\t\t\tKOBJ.log(\"Unhighlightified!\");\n\t\t\t\t});\n\n\t\t\t\tKOBJ.a41x93.num = 1;\n\t\t\t\tKOBJ.a41x93.cutoff = 10;\n\t\t\t\tvar mySelectorFunc = function(obj) {\n\t\t\t\t\tvar thisObject = $K(obj);\n\t\t\t\t\tvar normLogs = [];\n\t\t\t\t\tvar logicLogs = [];\n\t\t\t\t\tKOBJ.log(\"Current DOM object:\");\n\t\t\t\t\tKOBJ.log(thisObject);\n\t\t\t\t\tvar boolToReturn = false;\n\t\t\t\t\tif(a41x93.num <= KOBJ.a41x93.cutoff){\n\t\t\t\t\t\tboolToRetun = true;\n\t\t\t\t\t}\n\t\t\t\t\tnormLogs.push(\"Return value for search result \" +KOBJ.a41x93.num+ \":\");\n\t\t\t\t\tnormLogs.push(boolToReturn);    \n\t\t\t\t\tKOBJ.log(normLogs);   \n\t\t\t\t\tif (boolToReturn) {\n\t\t\t\t\t\tlogicLogs.push(\"Percolating search result: \" +KOBJ.a41x93.num);   \n\t\t\t\t\t\t$K('.KOBJ_item',obj).addClass('percolated'); \n\t\t\t\t\t} else {    \n\t\t\t\t\t\tlogicLogs.push(\"Not percolating result: \" +KOBJ.a41x93.num+ \", because it is greater than \" +KOBJ.a41x93.cutoff+ \".\"); \n\t\t\t\t\t}\n\t\t\t\t\tKOBJ.log(logicLogs);      \n\t\t\t\t\tKOBJ.log(\"\\n\");   \n\t\t\t\t\tKOBJ.a41x93.num++;  \n\t\t\t\t\treturn boolToReturn;\n\t\t\t\t};             \n\n\t\t\t"},
            {"action": {
               "args": [{
                  "type": "var",
                  "val": "mySelectorFunc"
               }],
               "modifiers": null,
               "name": "percolate",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "Percolate Example"
                  },
                  {
                     "type": "var",
                     "val": "msg"
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
         "name": "percolate_first_n_results",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com/search|bing.com/search|search.yahoo.com/search",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "msg",
            "rhs": " \n\t\t\t\t\t<div id=\"notifyMsg\">Hello There! Percolated results have been turned <span style=\"color:#F80000;\">this color<\/span>. If you would no longer like to have them highlighted, <div id=\"undoify\" style=\"cursor:pointer;color:#0a94d6\">click here<\/div><\/div>    \t     \n\t\t\t\t",
            "type": "here_doc"
         }],
         "state": "active"
      }
   ],
   "ruleset_name": "a41x93"
}
