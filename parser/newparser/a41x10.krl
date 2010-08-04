{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "bing.com"},
      {"domain": "yahoo.com"}
   ],
   "global": [],
   "meta": {
      "description": "\nAnnotates Google Search     \n",
      "logging": "off",
      "name": "Search Annotate Test"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "test_selector"
            }],
            "modifiers": null,
            "name": "annotate_search_results",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nKOBJ.tempCount = 0;    function test_selector(obj){    \tstring = '<div id=\"KOBJ_append'+KOBJ.tempCount+'\">Domain'+KOBJ.tempCount+':'+$K(obj).data(\"domain\")+'<\/div>';    \tKOBJ.tempCount++;  \treturn string;  }            ",
         "foreach": [],
         "name": "annotate",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "food.84660",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": [{
               "name": "remote",
               "value": {
                  "type": "str",
                  "val": "http://chevelle.caandb.com/annotate_remote.php?jsoncallback=?"
               }
            }],
            "name": "annotate_search_results",
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
         "name": "remote_annotate",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "burgers.84660",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "test_selector"
            }],
            "modifiers": null,
            "name": "annotate_local_search_results",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nKOBJ.tempCountLocal = 0;    function test_selector(obj){    \tstring = '<div id=\"KOBJ_append_local'+KOBJ.tempCountLocal+'\">Phone'+KOBJ.tempCountLocal+':'+$K(obj).data(\"phone\")+'<\/div>';  \t  \tKOBJ.tempCountLocal++;  \treturn string;  }            ",
         "foreach": [],
         "name": "local",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "food.*84660",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": [{
               "name": "remote",
               "value": {
                  "type": "str",
                  "val": "http://chevelle.caandb.com/annotate_remote.php?jsoncallback=?"
               }
            }],
            "name": "annotate_local_search_results",
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
         "name": "remote_local",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "burgers.*84660",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "test_selector"
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
         "emit": "\ntest_data = {  \t\t\"www.eco-furniture.com\" : {}  \t};      \tfunction test_selector(obj){  \t\tvar host = $K(obj).data(\"domain\");  \t\t  \t\tvar o = test_data[host];  \t\tif(o){  \t\t\treturn true;  \t\t} else {  \t\t\treturn false;  \t\t}  \t}\t\t              ",
         "foreach": [],
         "name": "percolate",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "furniture",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a41x10"
}
