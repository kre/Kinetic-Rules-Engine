{"global":[{"content":".content    {        color:#FFFFFF;    \tfont-family:Arial, Helvetica, sans-serif;    \tfont-size:12px;    \tpadding:5px;    }         .content a:link    {    \tcolor: #FFFFFF;    \tfont-weight:bold;    \ttext-decoration:none;    }         .content a:hover    {    \tcolor: #FFFF00;    \tfont-weight:bold;    \ttext-decoration: underline;    }         .content a:visited    {    \tcolor: #FFFF00;    \tfont-weight:bold;    \ttext-decoration:none;    }         .content a:visited:hover    {    \tcolor: #FFFF00;    \tfont-weight:bold;    \ttext-decoration: underline;    }                 ","type":"css"}],"dispatch":[{"domain":"www.google.com"},{"domain":"www.youtube.com"}],"ruleset_name":"a425x1","rules":[{"blocktype":"every","emit":null,"pre":[{"rhs":" \n<div >                  <p class=\"content\" >You've just found Custom Youtube Video Players Available On: <a href=\"http://www.stagegold.com\">StageGold<\/a><\/p>              <\/div>      \n ","type":"here_doc","lhs":"msg"}],"name":"rule_one","callbacks":null,"state":"active","pagetype":{"foreach":[],"event_expr":{"vars":[],"pattern":"http://www.google.com","op":"pageview","type":"prim_event","legacy":1}},"cond":{"val":"true","type":"bool"},"actions":[{"action":{"source":null,"args":[{"val":"Great News!","type":"str"},{"val":"msg","type":"var"}],"name":"notify","modifiers":[{"name":"sticky","value":{"val":"true","type":"bool"}}]}}]},{"blocktype":"every","emit":null,"pre":[{"rhs":" \n<div >                  <p class=\"content\" >Fun Custom Youtube Video Players Available On: <a href=\"http://www.stagegold.com\">StageGold<\/a><\/p>              <\/div>      \n ","type":"here_doc","lhs":"msg"}],"name":"rule_two","callbacks":null,"state":"active","pagetype":{"foreach":[],"event_expr":{"vars":[],"pattern":"http://www.youtube.com","op":"pageview","type":"prim_event","legacy":1}},"cond":{"val":"true","type":"bool"},"actions":[{"action":{"source":null,"args":[{"val":"Great News!","type":"str"},{"val":"msg","type":"var"}],"name":"notify","modifiers":[{"name":"sticky","value":{"val":"true","type":"bool"}}]}}]}],"meta":{"description":"\nYoutube Connect   \n","name":"StageGold","logging":"off"}}