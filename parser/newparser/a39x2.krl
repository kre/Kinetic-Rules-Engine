{
   "dispatch": [{"domain": "google.com"}],
   "global": [],
   "meta": {
      "description": "\nTest     \n",
      "logging": "off",
      "name": "Test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "#res"
            },
            {
               "type": "var",
               "val": "story"
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
      "name": "replace_fun",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "story",
         "rhs": " \n<div>  <ol>  <li class=\"g w0\">  <h3 class=\"r\">  <a class=\"l\" onmousedown=\"return rwt(this,'','','res','13','AFQjCNHaRd5Sn-HvyF4ZlUHEIueAkbyh-w','','0CE8QFjAM')\" href=\"http://www.house.leg.state.mn.us/\">  Welcome to the Minnesota  House  of Representatives  <\/a>  <\/h3>  <span style=\"display: inline-block;\">  <\/span>  <div class=\"s\">  Skip to search and help navigation; Skip to legislative homepage navigation; Skip to the Minnesota  House  of Representatives page section navigation  <b>...<\/b>  <br/>  <cite>  www.  <b>house<\/b>  .leg.state.mn.us/ -  <\/cite>  <span class=\"gl\">  <a onmousedown=\"return rwt(this,'','','clnk','13','AFQjCNGtqXJXEv0MV6SRuvDW9SbnBX0RPg','')\" href=\"http://74.125.93.132/search?q=cache:Xu5U7y5cklkJ:www.house.leg.state.mn.us/+house&cd=13&hl=en&ct=clnk&gl=us\">Cached<\/a>  -  <a href=\"/search?hl=en&q=related:www.house.leg.state.mn.us/&sa=X&ei=B6oFS_-SDMfVlAeB2-XECw&ved=0CFEQHzAM\">Similar<\/a>  -  <button class=\"wci\" title=\"Comment\"/>  <button class=\"w4\" title=\"Promote\"/>  <button class=\"w5\" title=\"Remove\"/>  <\/span>  <\/div>  <div class=\"wce\"/>  <\/li>  <div/>  <\/div>  <\/ol>  \n ",
         "type": "here_doc"
      }],
      "state": "active"
   }],
   "ruleset_name": "a39x2"
}
