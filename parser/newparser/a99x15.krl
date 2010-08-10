{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "optini.com"}
   ],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "tabout_lemma"
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
         "name": "before",
         "source": null
      }}],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": "\n<script src=\"http://tab-slide-out.googlecode.com/files/jquery.tabSlideOut.v1.3.js\"><\/script>      $K(function(){          $K('.slide-out-div').tabSlideOut({              tabHandle: '.handle',                                 pathToTabImage: 'images/contact_tab.gif',             imageHeight: '122px',                                 imageWidth: '40px',                                   tabLocation: 'left',                                  speed: 300,                                           action: 'click',                                      topPos: '200px',                                      leftPos: '20px',                                      fixedPosition: false                              });        });          ",
      "foreach": [],
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "^http://vutest.optini.com/$",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "content",
         "rhs": " \n<style type=\"text/css\">                .slide-out-div {            padding: 20px;            width: 250px;            background: #ccc;            border: 1px solid #29216d;        }              <\/style>              <div class=\"slide-out-div\">              <a class=\"handle\" href=\"http://link-for-non-js-users.html\">Content<\/a>              <h3>Contact me<\/h3>              <p>Thanks for checking out my jQuery plugin, I hope you find this useful.              <\/p>              <p>This can be a form to submit feedback, or contact info<\/p>          <\/div>    <!--  <span>test<\/span>    -->              \n ",
         "type": "here_doc"
      }],
      "state": "active"
   }],
   "ruleset_name": "a99x15"
}
