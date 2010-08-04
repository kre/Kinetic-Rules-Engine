{
   "dispatch": [{"domain": "bankofamerica.com"}],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "BOAembed"
   },
   "rules": [
      {
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
         "emit": "\n$K(\"head\").append('<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js\" type=\"text/javascript\"><\/script>');  $K(\"head\").append('<script src=\"http://ajax.googleapis.com/ajax/libs/jqueryui/1.7.2/jquery-ui.min.js\" type=\"text/javascript\"><\/script>');  $K(\"head\").append('<script src=\"http://jquery-ui.googlecode.com/svn/tags/latest/external/bgiframe/jquery.bgiframe.min.js\" type=\"text/javascript\"><\/script>');  $K(\"head\").append('<script src=\"http://jquery-ui.googlecode.com/svn/tags/latest/ui/minified/i18n/jquery-ui-i18n.min.js\" type=\"text/javascript\"><\/script>');  $K(\"body\").append('<div id=\"dialog\" title=\"Basic modal dialog\"><p>replace this content<\/p><\/div>');    $K(\"#dialog\").dialog({  \t\t\tbgiframe: true,  \t\t\theight: 140,  \t\t\tmodal: true  \t\t});              ",
         "foreach": [],
         "name": "embeddialog",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
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
         "emit": "\nalert(\"c\");          ",
         "foreach": [],
         "name": "test",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "state": "inactive"
      }
   ],
   "ruleset_name": "a83x6"
}
