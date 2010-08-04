{
   "dispatch": [],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "PiwikTest"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "#medium_rectangle"
            },
            {
               "type": "var",
               "val": "content"
            }
         ],
         "modifiers": null,
         "name": "prepend",
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
      "name": "piwik_rule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://www.cnn.com/|http://www.cnn.com/?.*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "cb",
            "rhs": {
               "args": [{
                  "type": "num",
                  "val": 999999999999
               }],
               "predicate": "random",
               "source": "math",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "content",
            "rhs": " \n<!-- Piwik -->        <script type=\"text/javascript\" src = \"http://vumetrics.optini.com/piwik.js\">    <\/script>        <!--    <script type=\"text/javascript\">    var pkBaseURL = ((\"https:\" == document.location.protocol) ? \"https://vumetrics.optini.com/\" : \"http://vumetrics.optini.com/\");    alert('hi');    document.write(unescape(\"%3Cscript src='\" + pkBaseURL + \"piwik.js' type='text/javascript'%3E%3C/script%3E\"));    <\/script>    -->        <script type=\"text/javascript\">    try {    var pkBaseURL = ((\"https:\" == document.location.protocol) ? \"https://vumetrics.optini.com/\" : \"http://vumetrics.optini.com/\");    var piwikTracker = Piwik.getTracker(pkBaseURL + \"piwik.php\", 15);    alert(piwikTracker);    piwikTracker.trackPageView();    piwikTracker.enableLinkTracking();    } catch( err ) { alert(err); }    <\/script><noscript><p><img src=\"http://vumetrics.optini.com/piwik.php?idsite=15\" style=\"border:0\" alt=\"\" /><\/p><\/noscript>    <!-- End Piwik Tag -->        \n ",
            "type": "here_doc"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a437x5"
}
