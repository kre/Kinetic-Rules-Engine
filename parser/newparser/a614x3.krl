{
   "dispatch": [
      {"domain": "facebook.com"},
      {"domain": "myspace.com"},
      {"domain": "twitter.com"}
   ],
   "global": [],
   "meta": {
      "description": "\nA panic button for social networking sites that allows users to report suspicious activity   \n",
      "logging": "off",
      "name": "CEOP Panic Button"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "h4.uiHeaderTitle"
               },
               {
                  "type": "str",
                  "val": "<a href=http://www.ceop.police.uk/reportabuse/index.asp target=_blank><img src=http://esfa.co.uk/_images/uploaded/website/home/CEOP_logo.gif height=25><\/a>"
               }
            ],
            "modifiers": null,
            "name": "after",
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
         "name": "facebook",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.facebook.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "div.profile_actions"
               },
               {
                  "type": "str",
                  "val": "<a href=http://www.ceop.police.uk/reportabuse/index.asp target=_blank><img src=http://esfa.co.uk/_images/uploaded/website/home/CEOP_logo.gif><\/a>"
               }
            ],
            "modifiers": null,
            "name": "after",
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
         "name": "facebook_under_profile_photo",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.facebook.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "h6.uiStreamMessage"
               },
               {
                  "type": "str",
                  "val": "<a href=http://www.ceop.police.uk/reportabuse/index.asp target=_blank><img src=http://esfa.co.uk/_images/uploaded/website/home/CEOP_logo.gif height=25><\/a>"
               }
            ],
            "modifiers": null,
            "name": "after",
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
         "name": "facebook_main_mini_profile_pic",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.facebook.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "a.UIIntentionalStory_Pic"
               },
               {
                  "type": "str",
                  "val": "<a href=http://www.ceop.police.uk/reportabuse/index.asp target=_blank><img src=http://esfa.co.uk/_images/uploaded/website/home/CEOP_logo.gif height=25><\/a>"
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
         "emit": null,
         "foreach": [],
         "name": "fb_inprofile_above_minipics",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.facebook.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "a.UIImageBlock_Image.UIImageBlock_SMALL_Image"
               },
               {
                  "type": "str",
                  "val": "<a href=http://www.ceop.police.uk/reportabuse/index.asp target=_blank><img src=http://esfa.co.uk/_images/uploaded/website/home/CEOP_logo.gif height=25><\/a>"
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
         "emit": null,
         "foreach": [],
         "name": "fb_above_minipics_instream",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.facebook.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "div.adcolumn_header"
               },
               {
                  "type": "str",
                  "val": "<a href=http://www.ceop.police.uk/reportabuse/index.asp target=_blank><img src=http://esfa.co.uk/_images/uploaded/website/home/CEOP_logo.gif><\/a>"
               }
            ],
            "modifiers": null,
            "name": "after",
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
         "name": "fb_ad_column",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.facebook.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a614x3"
}
