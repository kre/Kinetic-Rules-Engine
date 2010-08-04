{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "yahoo.com"},
      {"domain": "bing.com"}
   ],
   "global": [],
   "meta": {
      "logging": "on",
      "name": "search annotate js scope test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "type": "var",
            "val": "my_select"
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
      "emit": "\n$K(\"body\").append(\"<div id='noticebox' style='background-color:white;border:double;border-color:blue;position:fixed;height:40;width:100;color:white;visibility:hidden;-moz-box-shadow: 3px 2px 5px #444444;-webkit-box-shadow: 3px 2px 5px #444444;padding-left:5px;'>hi<\/div>\");    function noticeAlert(event) {      var x = event.clientX;    var y = event.clientY - 40;    document.getElementById(noticebox\").style.visibility = \"visible\";    document.getElementById(\"noticebox\").style.top = y;    document.getElementById(\"noticebox\").style.left = x;  }    function hide() {    document.getElementById(\"noticebox\").style.visibility = \"hidden\";  }      function my_select(obj) {    var ftext = $K(obj).text();    var htext = $K(obj).html();    KOBJ.log(htext);    if (ftext.match(/usaa.com/)) {      return \"<img class='devexrocks' src='http:  } else {      false;    }  }          ",
      "foreach": [],
      "name": "alert_test",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x61"
}
