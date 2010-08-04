{
   "dispatch": [{"domain": "optini.com"}],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "vugrid_lemma"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "#vugrid"
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
      "emit": "\nmakeBig = function(){   \t$K(\"#vidGrid\").width(940);  \t$K(\"#vidGrid\").height(833);  };    makeSmall = function(){  \t$K(\"#vidGrid\").width(234);  \t$K(\"#vidGrid\").height(195);   };          ",
      "foreach": [],
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "^http://vutest.optini.com/vugrid.html",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "content",
         "rhs": " \n<!--  <div id=\"vugrid\">;kafhawuhghu;ag;hugu;  <embed id=\"vidGrid\" width=\"234\" height=\"195\" align=\"middle\" pluginspage=\"http://www.adobe.com/go/getflashplayer\" type=\"application/x-shockwave-flash\" allowfullscreen=\"false\" allowscriptaccess=\"always\" name=\"videogrid\" bgcolor=\"#ffffff\" salign=\"rt\" scale=\"noscale\" quality=\"high\" src=\"http://vugrid.com/videogrid.swf\" style=\"width: 234px; height: 195px;\"/>  -->          <embed src=\"http://www.vugrid.com/videogrid.swf\" quality=\"high\" scale=\"noscale\" salign=\"rt\" bgcolor=\"#ffffff\" width=\"234\" height=\"195\" name=\"videogrid\" align=\"middle\" allowScriptAccess=\"always\" allowFullScreen=\"false\" type=\"application/x-shockwave-flash\" pluginspage=\"http://www.adobe.com/go/getflashplayer\"  id=\"vidGrid\"/>    <\/div>  \n ",
         "type": "here_doc"
      }],
      "state": "active"
   }],
   "ruleset_name": "a99x14"
}
