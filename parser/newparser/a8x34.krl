{
   "dispatch": [{"domain": "k-misc.s3.amazonaws.com"}],
   "global": [],
   "meta": {
      "description": "\nAutoshrinksAutoJam test results   \n",
      "logging": "off",
      "name": "AutoJam Terse Mode"
   },
   "rules": [{
      "actions": [{"emit": "\n$K(\"dd.spec.failed .failed_spec_name\").css('cursor', 'pointer').click(function(){  \t$K(\".backtrace, .ruby\", $K(this).parent()).toggle();  });  $K(\".backtrace, .ruby\").hide();                    "}],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "args": [],
         "function_expr": {
            "type": "var",
            "val": "truth"
         },
         "type": "app"
      },
      "emit": null,
      "foreach": [],
      "name": "cleanup",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a8x34"
}
