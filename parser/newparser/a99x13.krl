{
   "dispatch": [{"domain": "optini.com"}],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "statsTest"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "#vutest_optini"
            },
            {
               "type": "var",
               "val": "content"
            }
         ],
         "modifiers": null,
         "name": "replace_html",
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
      "name": "vutest",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "^http://vutest.optini.com/$",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "cb",
            "rhs": {
               "args": [{
                  "type": "num",
                  "val": 999999999
               }],
               "predicate": "random",
               "source": "math",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "content",
            "rhs": " \n<div id=\"vutest_optini\">  <center>  <iframe id='a0c42e23' name='a0c42e23' width=\"468\" height=\"60\" src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/afr.php?zoneid=80&amp;cb=#{cb}' framespacing='0' frameborder='no' scrolling='no' allowtransparency='true'><a href='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/ck.php?n=a6ce1358&amp;cb=#{cb}' target='_blank'><img src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/avw.php?zoneid=80&amp;cb=#{cb}&amp;n=a6ce1358' border='0' alt='' /><\/a><\/iframe>  <center>  <\/div>  <br>  <br>  <div id=\"b-rse_counter\">  <center>  <span>B-RSE Counter<\/span>  <!-- GoStats Simple HTML Based Code -->  <a target=\"_blank\" title=\"advanced web statistics\" href=\"http://gostats.com\"><img alt=\"advanced web statistics\"   src=\"http://c5.gostats.com/bin/count/a_1012336/z_1/t_4/i_1/counter.png\"   style=\"border-width:0\" /><\/a>  <!-- End GoStats Simple HTML Based Code -->  <\/center>  <\/div>  <br>  <br>  \n ",
            "type": "here_doc"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a99x13"
}
