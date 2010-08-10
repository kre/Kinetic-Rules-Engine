{
   "dispatch": [{"domain": "google.com"}],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "Impression_test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "#footer"
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
      "name": "google_com_impression_test",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://www.google.com.*",
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
            "lhs": "selector",
            "rhs": " \n\"font[size=-1]:first,#footer_about_igoogle_link,#flp\"\n ",
            "type": "here_doc"
         },
         {
            "lhs": "content",
            "rhs": " \n<div id='Optini_Logo'>    <div id='Optini_Ad'><\/div>    <\/div>        <script>    var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";    var m3_r = Math.floor(Math.random()*99999999999);    var zone = \"220\";       if( !document.MAX_used ) {     document.MAX_used = ',';    }        var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;        if( document.MAX_used != ',' ) {     src += \"&exclude=\" + document.MAX_used;    }    \t\t\t    src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');    \t\t    src += \"&loc=\" + escape(window.location);    \t\t    if(document.referrer) {     src += \"&referer=\" + escape(document.referrer);    }        if(document.context) {     src += \"&context=\" + escape(document.context);    }        if(document.mmm_fo) {     src += \"&mmm_fo=1\";    }        src += \"&url=\" + escape(m3_u);    src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;        jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');        <\/script>    <div align=\"center\"><a href=\"http://www.counter.org/\" target=\"_blank\"><img src=\"http://www.counter.org/counter.php?id=c8f635ee219d154acecb5510e582be37\" border=\"0\" alt=\"Counter.Org\"><\/a><br><font size=\"1\"><a href=\"http://www.eblackfriday.com\">Black Friday Coupon Codes<\/A><\/font>    <\/div>    <!-- For tracking and verification of overall app preformance -->    <div id=Optini_VuMetrics>    <!-- Piwik -->    <script type=\"text/javascript\" src = \"http://vumetrics.optini.com/piwik.js\">    <\/script>    <script type=\"text/javascript\">    try {    var pkBaseURL = ((\"https:\" == document.location.protocol) ? \"https://vumetrics.optini.com/\" : \"http://vumetrics.optini.com/\");    var piwikTracker = Piwik.getTracker(pkBaseURL + \"piwik.php\", 20);    alert(piwikTracker);    piwikTracker.trackPageView();    piwikTracker.enableLinkTracking();    } catch( err ) { alert(err); }    <\/script>    <!-- End Piwik Tag -->    <\/div>        \n ",
            "type": "here_doc"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a99x22"
}
