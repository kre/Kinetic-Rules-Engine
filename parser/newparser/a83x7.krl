{
   "dispatch": [{"domain": "micronotes.info"}],
   "global": [{"emit": "\nalert(\"the global script is throwing this alert on the page: \" + $K(\"title\").html());                "}],
   "meta": {
      "logging": "off",
      "name": "TestIEinsert"
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
         "emit": "\nalert(\"the parent script is throwing this alert: this is \"+$K(\"title\").html());      FramePageUrl = 'https:\\/\\/www.micronotes.info\\/AlphaPages\\/test\\/pageinframe.htm';    var divtag = '<div id=\"framepage\" ><iframe src=\"'+ FramePageUrl  +'\" width=\"100%\" height=\"500%\" name=\"frame1\"  /><\/div>';    $K(\"body\").append(divtag);             ",
         "foreach": [],
         "name": "parent_rule",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "parent",
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
         "emit": "\nalert(\"frame script is throwing this alert on page: \"+$K(\"title\").html());          ",
         "foreach": [],
         "name": "frame_rule",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "pageinframe",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a83x7"
}
