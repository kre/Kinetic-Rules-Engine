{
   "dispatch": [{"domain": "facebook.com"}],
   "global": [{"emit": "\nfunction kNotifyDup(config, header, msg) {    \t        uniq = (Math.round(Math.random()*100000000)%100000000);    \t\t$K.kGrowl.defaults.header = header;    \t\tif(typeof config === 'object') {    \t\t\tjQuery.extend($K.kGrowl.defaults,config);    \t\t}    \t\t$K.kGrowl(msg);    \t\t\t    \t}                        "}],
   "meta": {
      "logging": "off",
      "name": "Facebook"
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
         "emit": "\nfunction getImages() {        posts = $K(\".UIIntentionalStory_Content:has(.UIMediaItem_Photo)\");        postSize = posts.size();        if(postSize > 0) {              \t   \t  \tstrMsg = \"Here are \" + postSize + \" images posted within this news feed.\";  \tposts.each(function(posts){    \t\tpostToIterate = $K(this);  \t\timgStuff = $K(\".UIStoryAttachment\",postToIterate).html();  \t\tcommentStuff= $K(\".comment_box\",postToIterate).html();  \t\tstrMsg += \"<p>\" + imgStuff + commentStuff + \"<\/p>\";    \t});      \tkNotifyDup({txn_id: 'C21CE5BA-5B86-11DE-8D16-C767F8606F2B',rule_name: 'facebookimage','opacity':.95,'width':'600px'},'Facebook Images',strMsg);        }            }         getImages();          ",
         "foreach": [],
         "name": "facebookimage",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "facebook.com/",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "postSize",
               "rhs": {
                  "type": "num",
                  "val": 1
               },
               "type": "expr"
            },
            {
               "lhs": "strMsg",
               "rhs": {
                  "type": "str",
                  "val": ""
               },
               "type": "expr"
            }
         ],
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
         "emit": null,
         "foreach": [],
         "name": "facebookmessage",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.facebook.com/home.php?ref=home",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "messagePage",
            "rhs": {
               "type": "var",
               "val": "getMessagePage"
            },
            "type": "expr"
         }],
         "state": "inactive"
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
         "emit": "\n        ",
         "foreach": [],
         "name": "facebookchat",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "facebook.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a41x16"
}
