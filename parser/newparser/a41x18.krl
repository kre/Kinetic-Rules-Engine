{
   "dispatch": [{"domain": "www.youtube.com"}],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "YouTube"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Download"
            },
            {
               "args": [
                  {
                     "type": "var",
                     "val": "msg"
                  },
                  {
                     "args": [
                        {
                           "type": "var",
                           "val": "video_id"
                        },
                        {
                           "args": [
                              {
                                 "type": "var",
                                 "val": "msg2"
                              },
                              {
                                 "args": [
                                    {
                                       "type": "var",
                                       "val": "t_id"
                                    },
                                    {
                                       "type": "var",
                                       "val": "msg3"
                                    }
                                 ],
                                 "op": "+",
                                 "type": "prim"
                              }
                           ],
                           "op": "+",
                           "type": "prim"
                        }
                     ],
                     "op": "+",
                     "type": "prim"
                  }
               ],
               "op": "+",
               "type": "prim"
            }
         ],
         "modifiers": [{
            "name": "sticky",
            "value": {
               "type": "bool",
               "val": "true"
            }
         }],
         "name": "notify",
         "source": null
      }}],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": "\nflashVars = $K(\"#movie_player\").attr(\"flashvars\");  \tt_id = flashVars.match(/\\&t=([^(\\&|$)]*)/i)[1];  \tvar video_id = flashVars.match(/video_id=([^(\\&|$)]*)/)[1];                ",
      "foreach": [],
      "name": "youtubedownload",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "www.youtube.com/watch\\?v=(\\w+)",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "msg",
            "rhs": " \nThe download of this video is available <a href=\"http://www.youtube.com/get_video?video_id=\n ",
            "type": "here_doc"
         },
         {
            "lhs": "msg2",
            "rhs": " \n&t=\n ",
            "type": "here_doc"
         },
         {
            "lhs": "msg3",
            "rhs": " \n&fmt=18\" target=\"blank\">here<\/a> \n ",
            "type": "here_doc"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a41x18"
}
