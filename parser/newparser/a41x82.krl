{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "cnn.com"}
   ],
   "global": [{
      "cachable": {
         "period": "seconds",
         "value": "1"
      },
      "datatype": "JSON",
      "name": "yql",
      "source": "http://query.yahooapis.com/v1/public/yql?",
      "type": "datasource"
   }],
   "meta": {
      "logging": "off",
      "name": "VoxPop"
   },
   "rules": [{
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
      "emit": "\nfunction notify(header,msg,config){    \t\t$K.kGrowl.defaults.header = header;    \t\tif(typeof config === 'object') {  \t\t\tjQuery.extend($K.kGrowl.defaults,config);  \t\t}  \t\t$K.kGrowl(msg);   \t  \t}    \tfunction returnGoodJson(badJson) {  \t\tgoodJson = {};  \t\trows = badJson.query.results.row;                  if($K(rows).length != 1){  \t\t    $K.each(rows,function(key,data){  \t\t    \t    row = this;  \t\t\t    url = row.col0;  \t\t\t    text = row.col1;  \t  \t\t\t  \t\t\t    goodJson[url] = {'text':text};  \t    \t    });                  } else {                      goodJson[rows.col0] = rows.col1                  }  \t\treturn goodJson;    \t}    \tspreadSheet = returnGoodJson(yqlResults);    \tif(spreadSheet[window.location.href]){  \t\tnotify(\"VoxPop\",spreadSheet[window.location.href].text.replace(/\"\"/g,\"\\\"\").replace(/(^\"|\"$)/g,\"\"),{\"sticky\":true, \"width\":\"auto\"});  \t}  \t  \t  \t          ",
      "foreach": [],
      "name": "notifier",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "yqlResults",
         "rhs": {
            "args": [{
               "type": "hashraw",
               "val": [{
                  "lhs": "q",
                  "rhs": {
                     "type": "str",
                     "val": "select%20*%20from%20csv%20where%20url%3D'http%3A%2F%2Fspreadsheets.google.com%2Fpub%3Fkey%3DtvlWHDSrYgrUz9sKZd0064Q%26output%3Dcsv'&format=json&callback="
                  }
               }]
            }],
            "predicate": "yql",
            "source": "datasource",
            "type": "qualified"
         },
         "type": "expr"
      }],
      "state": "inactive"
   }],
   "ruleset_name": "a41x82"
}
