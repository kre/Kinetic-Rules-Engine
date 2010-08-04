{
   "dispatch": [],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "Runtime Local Search"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "type": "var",
            "val": "my_selector"
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
      "emit": "\nbusinessData = {    \t'8014929012': 'www.bobstowing.com',  \t'8017565883': 'www.geneharvey.com',  \t'8013415088': 'www.bobstowing.com',  \t'4162912868': 'www.bobstowing.com',  \t'8012255404': 'www.geneharvey.com'  };    domainData = {  \t'www.geneharvey.com': {'url':'www.geneharvey.com'},  \t'www.bobstowing.com': {'url':'www.bobstowing.com'}  };        my_selector = function(obj){    \tdomain = $K(obj).data(\"domain\");  \tphone = $K(obj).data(\"phone\");  \tcompact = $K(obj).data(\"compact\");  \theight = $K(obj).data(\"height\");    \tconsole.log(\"Domain:\",domain,\"\\nPhone:\",phone);\t    \tvar p = businessData[phone];  \tif(!p){  \t\tp = domainData[domain];  \t\tif(p){  \t\t\tp = businessData[p];  \t\t}  \t}  \tif(p && compact) {  \t\treturn \"<img src='http://k-misc.s3.amazonaws.com/resources/a8x17/bbbaccredited.png'/>\";  \t} else if(p && !compact) {  \t\treturn \"<img src='http://k-misc.s3.amazonaws.com/resources/a8x17/bbb-full.jpg' />\";  \t} else {  \t\treturn false;  \t}  };             ",
      "foreach": [],
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a41x63"
}
