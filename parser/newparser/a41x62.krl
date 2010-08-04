{
   "dispatch": [{"domain": "facebook.com"}],
   "global": [
      {
         "cachable": {
            "period": "seconds",
            "value": "1"
         },
         "datatype": "JSON",
         "name": "consoleFeed",
         "source": "http://pipes.yahoo.com/pipes/pipe.run?_id=ac275506c188c0ae69a33899b6941a88&_render=json",
         "type": "dataset"
      },
      {
         "cachable": {
            "period": "seconds",
            "value": "1"
         },
         "datatype": "JSON",
         "name": "tweets",
         "source": "http://kynetxtweets:fizzbazz@twitter.com/statuses/user_timeline/bharward.json",
         "type": "datasource"
      }
   ],
   "meta": {
      "logging": "on",
      "name": "FB Console"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "#home_sidebar"
            },
            {
               "type": "var",
               "val": "message"
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
      "name": "facebook",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "www.facebook.com/home.php",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "tweets",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "?a"
               }],
               "predicate": "tweets",
               "source": "datasource",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "res",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$.[0]..text"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "tweets"
               },
               "type": "operator"
            },
            "type": "expr"
         },
         {
            "lhs": "img",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$.[0]..profile_image_url"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "tweets"
               },
               "type": "operator"
            },
            "type": "expr"
         },
         {
            "lhs": "user",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$.[0]..screen_name"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "tweets"
               },
               "type": "operator"
            },
            "type": "expr"
         },
         {
            "lhs": "rssFeed",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$..items[0]"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "consoleFeed"
               },
               "type": "operator"
            },
            "type": "expr"
         },
         {
            "lhs": "message",
            "rhs": " \n<div id=\"KOBJ_FaceBook\" style=\"background: #E7F2F6; padding: 10px 10px 2px 10px; margin-bottom: 15px;\">      \t\t<div class=\"UIHomeBox UITitledBox\" id=\"KOBJ_CB_Logo\" style=\"margin-bottom: 0px;\">  \t\t\t<div class=\"UITitledBox_TitleBar\" style=\"margin-bottom: 30px;\">  \t\t\t\t<span class=\"UITitle UITitle_h4\">  \t\t\t\t\tBrett's Voicebox  \t\t\t\t<\/span>  \t\t\t<\/div>  \t\t\t  \t\t<\/div>      \t\t<div class=\"UIHomeBox UITitledBox\" id=\"FB_consoleVideo\" style=\"text-align: center;\">  \t\t\t<div class=\"UITitledBox_Top\">  \t\t\t\t<div class=\"UITitledBox_TitleBar\">  \t\t\t\t\t<span class=\"UITitle UITitle_h5\">  \t\t\t\t\t\tFeatured Video  \t\t\t\t\t<\/span>  \t\t\t\t<\/div>  \t\t\t<\/div>  \t\t\t<div class=\"UITitledBox_Content KOBJ_fb_console\">  \t\t\t\t<object width=\"230\" height=\"160\"><param name=\"movie\" value=\"http://www.youtube.com/v/il59EKRoz24&hl=en&fs=1&\"><\/param><param name=\"allowFullScreen\" value=\"true\"><\/param><param name=\"allowscriptaccess\" value=\"always\"><\/param><embed src=\"http://www.youtube.com/v/il59EKRoz24&hl=en&fs=1&\" type=\"application/x-shockwave-flash\" allowscriptaccess=\"always\" allowfullscreen=\"true\" width=\"230\" height=\"160\"><\/embed><\/object>  \t\t\t<\/div>  \t\t<\/div>  \t  \t  \t  \t\t  \t\t<div id=\"FB_consoleFeed\">  \t\t\t<div class=\"UIHomeBox UITitledBox\" id=\"FB_feedContainer\" style=\"margin-bottom: 0px;\">  \t\t\t\t<div class=\"UITitledBox_Top\">  \t\t\t\t\t<div class=\"UITitledBox_TitleBar\">  \t\t\t\t\t\t<span class=\"UITitle UITitle_h5\">  \t\t\t\t\t\t\tTweets  \t\t\t\t\t\t<\/span>  \t\t\t\t\t<\/div>  \t\t\t\t\t<div class=\"UIHomeBox_More\">  \t\t\t\t\t\t<small>  \t\t\t\t\t\t\t<a class=\"UIHomeBox_MoreLink KOBJ_fb_console\" href=\"http:\\/\\/www.twitter.com/#{user}\">  \t\t\t\t\t\t\t\tSee All  \t\t\t\t\t\t\t<\/a>  \t\t\t\t\t\t<\/small>  \t\t\t\t\t<\/div>  \t\t\t\t<\/div>  \t  \t\t\t\t<div class=\"UITitledBox_Content\">  \t\t\t\t  \t\t\t\t\t<a href=\"http:\\/\\/www.twitter.com/#{user}\" style=\"float: left; margin-right: 20px;\" class=\"KOBJ_fb_console\">  \t\t\t\t\t\t<img src=\"#{img}\" />  \t\t\t\t\t<\/a>  \t\t  \t\t\t\t\t<p>  \t\t\t\t\t\t#{res}  \t\t\t\t\t<\/p>  \t\t\t\t\t<p>  \t\t\t\t\t\tby <a href=\"http:\\/\\/www.twitter.com/#{user}\" class=\"KOBJ_fb_console\">#{user}<\/a>  \t\t\t\t\t<\/p>  \t\t\t\t<\/div>  \t\t\t<\/div>        \t\t\t<div id=\"FB_consoleFeedWrapper\" class=\"UIHomeBox UITitledBox\" style=\"margin-top: 15px;\">  \t\t\t\t<div class=\"UITitledBox_Top\">  \t\t\t\t\t<div class=\"UITitledBox_TitleBar\">  \t\t\t\t\t\t<span class=\"UITitle UITitle_h5\">  \t\t\t\t\t\t\tBlog  \t\t\t\t\t\t<\/span>  \t\t\t\t\t<\/div>  \t\t\t\t\t<div class=\"UIHomeBox_More\">  \t\t\t\t\t\t<small>  \t\t\t\t\t\t\t<a class=\"UIHomeBox_MoreLink KOBJ_fb_console\" href=\"http:\\/\\/www.offendertrackingsolutions.com/#{user}\">  \t\t\t\t\t\t\t\tSee All  \t\t\t\t\t\t\t<\/a>  \t\t\t\t\t\t<\/small>  \t\t\t\t\t<\/div>  \t\t\t\t<\/div>  \t\t\t\t<div id=\"consoleFeed\" class=\"UITitledBox_Content\">  \t\t\t\t\t<p>  \t\t\t\t\t\t<a href=\"#{rssFeed.link}\" class=\"KOBJ_fb_console\">  \t\t\t\t\t\t\t#{rssFeed[\"y:title\"]}  \t\t\t\t\t\t<\/a>  \t\t\t\t\t<\/p>  \t\t\t\t\t<p>  \t\t\t\t\t\tby <a href=\"http:\\/\\/www.offendertrackingsolutions.com/\" class=\"KOBJ_fb_console\">#{user}<\/a>  \t\t\t\t\t<\/p>  \t\t\t\t<\/div>    \t\t\t<\/div>              \t\t<\/div>  \t<\/div>     \n ",
            "type": "here_doc"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a41x62"
}
