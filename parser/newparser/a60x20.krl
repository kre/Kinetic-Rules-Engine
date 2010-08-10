{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "images.google.com"},
      {"domain": "news.google.com"},
      {"domain": "books.google.com"},
      {"domain": "scholar.google.com"},
      {"domain": "blogsearch.google.com"},
      {"domain": "youtube.com"},
      {"domain": "picasaweb.google.com"},
      {"domain": "groups.google.com"}
   ],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "Google Enhanced"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Kynetx Rocks!"
            },
            {
               "type": "str",
               "val": "You are now searching with the power of Kynetx. Just scroll down the results to get more!"
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
      "emit": "\n$K(document).ready(function() {        $K(window).scroll(function(){      if ($K(window).scrollTop() == $K(document).height() - $K(window).height()){        loadMore();          }    });      start = 0;       $K('<div id=\"tempresults\" class=\"moreloaded\"><\/div>').insertAfter(\"#res\");  });    function loadMore() {    start += 10;    var nextlink = $K(\"#nav tr td:last a\").attr('href');    var currenturl = window.location;    url = currenturl + '&start=' + start;    $K(\"#tempresults\").get(\"http://www.google.com/webhp?hl=en#hl=en&source=hp&q=nice&aq=f&aqi=g10&oq=&fp=25d2df88517031cf&start=10\");    $K(\"#tempresults\").append(\"onetuhonethuasnotehunsoaethunsotehunotehus nath oenth uoenst hu\");    $K(\"#tempresults\").attr('id', 'oldtemp');    $K('<div id=\"tempresults\" class=\"moreloaded\"><\/div>').insertAfter(\".moreloaded:last\");  }                              ",
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
   "ruleset_name": "a60x20"
}
