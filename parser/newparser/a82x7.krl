{
   "dispatch": [{"domain": "finance.yahoo.com"}],
   "global": [],
   "meta": {
      "author": "Azigo",
      "description": "\nOpenX Ad Demo     \n",
      "logging": "off",
      "name": "AARP Ad Demo"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "#yfi_fp_ad_lrec"
            },
            {
               "type": "var",
               "val": "yfi_fp_aarp"
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
      "name": "yahoo_finance",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://finance.yahoo.com",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "r",
            "rhs": {
               "args": [{
                  "type": "num",
                  "val": 999
               }],
               "predicate": "random",
               "source": "math",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "yfi_fp_aarp",
            "rhs": " \n<div>  <iframe id=\"a6911fb5\" name=\"a6911fb5\" src=\"http://ads.ingenistics.com/www/delivery/afr.php?zoneid=10&cb=#{r}\" frameborder=\"0\" scrolling=\"no\" width=\"300\" height=\"250\"><a href=\"http://ads.ingenistics.com/www/delivery/ck.php?n=a805bcba&cb=#{r}\" target=\"_blank\"><img src=\"http://ads.ingenistics.com/www/delivery/avw.php?zoneid=10&cb=#{r}&n=a805bcba\" border=\"0\" alt=\"\" /><\/a><\/iframe>  <\/div>     \n ",
            "type": "here_doc"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a82x7"
}
