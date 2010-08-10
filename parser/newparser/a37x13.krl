{
   "dispatch": [
      {"domain": "yellowpages.superpages.com"},
      {"domain": "www.superpages.com"},
      {"domain": "mapserver.superpages.com"}
   ],
   "global": [{"emit": "\nvar d=document;    var s = d.createElement(\"script\");    s.src = \"http://jeesmon.csoft.net/smt2/core/js/smt-aux.js\";    var s2 = d.createElement(\"script\");    s2.src = \"http://jeesmon.csoft.net/smt2/core/js/smt-record.js\";    var st = d.createElement(\"script\");    st.text = 'try {        smt2.record({             dirPath: \"http://jeesmon.csoft.net/smt2\",             postInterval: 2        });    } catch(err) {alert(err)}';    d.body.appendChild(s);    d.body.appendChild(s2);    d.body.appendChild(st);                    "}],
   "meta": {
      "logging": "off",
      "name": "smt2"
   },
   "rules": [{
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
      "emit": null,
      "foreach": [],
      "name": "search",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a37x13"
}
