{
   "dispatch": [{"domain": "www.google.com"}],
   "global": [{"emit": "\ntry {    (function(){        throw \"foo\";            })();        } catch(e) {    \tconsole.log(\"caught error\", e);    \tvar txt=\"_s=8bc7319f4229852c12380ccc96d452e6&_r=img\";    \ttxt+=\"&Msg=\"+escape(e.message ? e.message : e);    \ttxt+=\"&URL=\"+escape(e.fileName ? e.fileName : \"\");    \ttxt+=\"&Line=\"+ (e.lineNumber ? e.lineNumber : 0);    \ttxt+=\"&name=\"+escape(e.name ? e.name : e);    \ttxt+=\"&Platform=\"+escape(navigator.platform);    \ttxt+=\"&UserAgent=\"+escape(navigator.userAgent);    \ttxt+=\"&stack=\"+escape(e.stack ? e.stack : \"\");    \tvar i = document.createElement(\"img\");    \ti.setAttribute(\"src\", \"http://www.errorstack.com/submit?\" + txt);    \tdocument.body.appendChild(i);        }                        "}],
   "meta": {
      "description": "\ntestError \n",
      "name": "Testing Error Submission"
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
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "www.google.com",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a8x6"
}
