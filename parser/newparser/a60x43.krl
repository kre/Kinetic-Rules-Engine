{
   "dispatch": [{"domain": "craigslist.org"}],
   "global": [],
   "meta": {
      "author": "MikeGrace",
      "description": "\nTesting the jQuery .getJSON method    \n",
      "logging": "on",
      "name": ".getJSON"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Hello"
            },
            {
               "type": "str",
               "val": "I'm done running now."
            }
         ],
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
      "emit": "\nalert(\"emit worked!\");    var yqlUrl1= \"http://query.yahooapis.com/v1/public/yql?callback=?&diagnostics=false&format=json&q=select * from html where url=%22http://eastidaho.craigslist.org/sys/1503372271.html%22 and xpath=%22//img%22\";    $K.getJSON(\"yqlUrl1\",itRan);    function itRan(data) {    alert(\"haha! I ran!!!\");    alert(data);  }          ",
      "foreach": [],
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x43"
}
