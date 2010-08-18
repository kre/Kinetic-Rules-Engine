{"global":[{"content":".wt a {color: white; font-size: 12pt;}        .wt a:visted {color: blue; font-size: 12pt;}        .bordered { border: blue 5px solid; }        #borderedA { border: blue 5px solid; }        ","type":"css"}],"dispatch":[{"domain":"kynetx.com"}],"ruleset_name":"a41x38","rules":[{"blocktype":"every","emit":"\nsetTimeout(function() {  \t\t$K(\"#WalkthroughYes\").click(function() {   \t\t\t$K(\"#WalkthroughContinue\").slideDown(\"slow\");  \t\t\t$K(\"#WalkthroughAsk\").slideUp(\"slow\");  \t\t\t$K(\"input[value=New App]\").addClass(\"bordered\");  \t\t});  \t},800);          ","pre":[{"rhs":" \n<div class=\"wt\">  \t\t<p>  \t\tHello and welcome to the Kynetx appBuilder! This is the center console for developers, marketers, and managers. This is where developers create rules! Would you like to get started?  \t\t<\/p>  \t\t<table id=\"WalkthroughAsk\">  \t\t\t<tr>  \t\t\t\t<td><a href=\"#\" id=\"WalkthroughYes\">Yes<\/a><\/td>  \t\t\t\t<td><a href=\"#\" id=\"WalkthroughNo\">No<\/a><\/td>  \t\t\t<\/tr>  \t\t<\/table>  \t\t  \t\t<div id=\"WalkthroughContinue\" style=\"display: none;\">  \t\t\tOkay! Let's get started! To begin, click the \"New App\" button on the left!  \t\t<\/div>  \t  \t<\/div>     \n ","type":"here_doc","lhs":"msg"}],"name":"new_app","callbacks":null,"state":"active","pagetype":{"foreach":[],"event_expr":{"vars":[],"pattern":"appbuilder.kynetx.com/apps$","op":"pageview","type":"prim_event","legacy":1}},"cond":{"val":"true","type":"bool"},"actions":[{"action":{"source":null,"args":[{"val":"Kynetx Walkthrough","type":"str"},{"val":"msg","type":"var"}],"name":"notify","modifiers":[{"name":"position","value":{"val":"bottom-right","type":"str"}},{"name":"sticky","value":{"val":"true","type":"bool"}}]}},{"action":{"source":null,"args":[{"val":"#WalkthroughNo","type":"str"}],"name":"close_notification","modifiers":null}}]},{"blocktype":"every","emit":"\nsetTimeout( function() {  \t\t$K(\"#clickyclicky\").click(function() {  \t\t\t$K(\"#website\").val(\"Hello World\");  \t\t\t$K(\"#description\").val(\"This is a sample app that creates a basic hello world\");  \t\t\t$K(\"#first\").slideUp(\"slow\");  \t\t\t$K(\"#second\").slideDown(\"slow\");  \t\t\t$K(\"input[value=Create]\").addClass(\"bordered\");  \t\t});  \t},200);            ","pre":[{"rhs":" \n<div class=\"wt\"><div id=\"first\"><p>This is where you would create your new app. Enter a name and description and click create, or click<\/p><p><a href=\"#\" id=\"clickyclicky\">here<\/a><\/p><p> to have it be filled in automatically<\/p><\/div><div id=\"second\" style=\"display: none\"><p>Great! Now click create!<\/p><\/div><\/div>  \t\n ","type":"here_doc","lhs":"msg"}],"name":"name_description","callbacks":null,"state":"active","pagetype":{"foreach":[],"event_expr":{"vars":[],"pattern":"appbuilder.kynetx.com/apps/new$","op":"pageview","type":"prim_event","legacy":1}},"cond":{"val":"true","type":"bool"},"actions":[{"action":{"source":null,"args":[{"val":"Create a New Rule","type":"str"},{"val":"msg","type":"var"}],"name":"notify","modifiers":[{"name":"position","value":{"val":"bottom-right","type":"str"}},{"name":"sticky","value":{"val":"true","type":"bool"}}]}}]},{"blocktype":"every","emit":"\n$K(\"#nav_rules\").attr(\"style\",\"border: blue 5px solid;\");              ","pre":[{"rhs":" \n<div class=\"wt\"><p>This is the meta page of your first app! If you ever need to edit the title, description, author, or other parts of information, this is where you'll do that!<\/p><p>To continue on the tour, click the \"Rules\" button on the left<\/p><\/div>  \t\n ","type":"here_doc","lhs":"msg"}],"name":"click_rules___","callbacks":null,"state":"active","pagetype":{"foreach":[],"event_expr":{"vars":[],"pattern":"appbuilder.kynetx.com/apps/meta/","op":"pageview","type":"prim_event","legacy":1}},"cond":{"val":"true","type":"bool"},"actions":[{"action":{"source":null,"args":[{"val":"Your first rule!","type":"str"},{"val":"msg","type":"var"}],"name":"notify","modifiers":[{"name":"position","value":{"val":"bottom-right","type":"str"}},{"name":"sticky","value":{"val":"true","type":"bool"}}]}}]},{"blocktype":"every","emit":"\n$K(\"input[value=New Rule]\").addClass(\"bordered\");            ","pre":[{"rhs":" \n<div class=\"wt\"><p>This is the rule management page. If you have multiple rules for an app, this is where you can manage and perform bulk actions on those rules as well as create new rules.<\/p><p>To create a new rule now, click the \"New Rule\" button.<\/p>  \t  \t\n ","type":"here_doc","lhs":"msg"}],"name":"rules","callbacks":null,"state":"active","pagetype":{"foreach":[],"event_expr":{"vars":[],"pattern":"appbuilder.kynetx.com/apps/rules/","op":"pageview","type":"prim_event","legacy":1}},"cond":{"val":"true","type":"bool"},"actions":[{"action":{"source":null,"args":[{"val":"Create a new rule","type":"str"},{"val":"msg","type":"var"}],"name":"notify","modifiers":[{"name":"position","value":{"val":"bottom-right","type":"str"}},{"name":"sticky","value":{"val":"true","type":"bool"}}]}}]},{"blocktype":"every","emit":"\nsetTimeout(function() {    \t\t$K(\"#enter__\").click(function() {   \t\t\t$K(\"#story_rule_code\").val('select using \"http://www.kynetx.com/\" setting()');  \t\t});    \t\t$K(\"#notify\").click(function() {   \t\t\tvar text = $K(\"#story_rule_code\").val();  \t\t\ttext += '\\n\\nnotify(\"Hello\",\"Hello World!\");';  \t\t\t$K(\"#story_rule_code\").val(text);  \t\t\t$K(\".section-field\").attr(\"style\",\"background-color: blue\");  \t\t\t$K(\"input[value=Save]\").addClass(\"bordered\");  \t\t\t$K(\"#actions input[name=save]\").fadeIn();   \t\t});    \t},800);                ","pre":[{"rhs":" \n<div class=\"wt\"><p>Here is where we program the rules<\/p><p>Type in 'select using \"http://www.kynetx.com/\" setting()' or click <a href=\"#\" id=\"enter__\">here<\/a> to do it automatically. This tells the rule where to fire, or where you want this action to happen.<\/p><p>Once you've done this, now add 'notify(\"Hello\",\"Hello World!\");' to the text box or click <a href=\"#\" id=\"notify\">here.<\/a> This makes a small notify, like the one you're reading, appear with the header \"Hello\" and the text \"Hello World!\" Make sure the \"Rule Active\" check box is clicked, then click \"Save\" (It's under this notify)!    \t\n ","type":"here_doc","lhs":"msg"}],"name":"created_rule","callbacks":null,"state":"active","pagetype":{"foreach":[],"event_expr":{"vars":[],"pattern":"appbuilder.kynetx.com/apps/newrule/","op":"pageview","type":"prim_event","legacy":1}},"cond":{"val":"true","type":"bool"},"actions":[{"action":{"source":null,"args":[{"val":"Your new rule","type":"str"},{"val":"msg","type":"var"}],"name":"notify","modifiers":[{"name":"position","value":{"val":"bottom-right","type":"str"}},{"name":"sticky","value":{"val":"true","type":"bool"}}]}}]},{"blocktype":"every","emit":"\n$K(\"#nav_dispatch\").attr(\"style\",\"border: blue 5px solid;\");            ","pre":[{"rhs":" \n<div class=\"wt\">  \t\t\t<p>Great! You've successfully created a rule! Now click on the button that says \"Dispatch\"<\/p>  \t\t<\/div>    \t\n ","type":"here_doc","lhs":"msg"}],"name":"rules_sucess","callbacks":null,"state":"active","pagetype":{"foreach":[],"event_expr":{"vars":[],"pattern":"appbuilder.kynetx.com/apps/rule/","op":"pageview","type":"prim_event","legacy":1}},"cond":{"val":"true","type":"bool"},"actions":[{"action":{"source":null,"args":[{"val":"Great!","type":"str"},{"val":"msg","type":"var"}],"name":"notify","modifiers":[{"name":"position","value":{"val":"bottom-right","type":"str"}},{"name":"sticky","value":{"val":"true","type":"bool"}}]}}]},{"blocktype":"every","emit":"\nsetTimeout(function() {    \t\t$K(\"#clicky\").click(function() {   \t\t\t$K(\"#dispatch\").val('domain \"kynetx.com\"');    \t\t\t$K(\"input[value=Save]\").addClass(\"bordered\");  \t\t\t$K(\"input[value=Save]\").slideDown(\"slow\");    \t\t});    \t},200);    \t\t$K(\"#nav_publish\").attr(\"style\",\"border: blue 5px solid;\");    \t\t$K(\"#nav_publish\").click(function() {  \t\t\t$K(\"input[value=Continue]\").addClass(\"bordered\");  \t\t});    \t\t$K(\"input[value=Continue]\").click(function() {  \t\t\t$K(\"#nav_publish\").removeClass(\"bordered\");  \t\t\t$K(\"#nav_publish\").attr(\"style\",\"border: none\");  \t\t\t$K(\"#nav_view\").attr(\"style\",\"border: blue 5px solid;\");  \t\t});          ","pre":[{"rhs":" \n<div class=\"wt\">  \t\t\t<p>  \t\t\t\tThis is where you tell your application where it should try to fire. This is a lot more broad than the \"select using...\" we entered on the rule page. Type 'domain \"kynetx.com\"' in the box or click <a href=\"#\" id=\"clicky\">here.<\/a>  \t\t\t<\/p>  \t\t\t<p>  \t\t\t\tAfter doing that, click \"Save\".  \t\t\t<\/p>  \t\t\t<p>  \t\t\t\tClick \"Publish\" to the left now and then click \"Continue\". This publishes the changes we've made to our application. Each time we want to make our changes active, we have to click publish.    \t\t\t<\/p>  \t\t\t<p>  \t\t\t\tWe're now through with creating our App. To continue, click on the \"Dashboard\" link at the left.  \t\t\t<\/p>  \t\t<\/div>    \t\n ","type":"here_doc","lhs":"msg"}],"name":"dispatch","callbacks":null,"state":"active","pagetype":{"foreach":[],"event_expr":{"vars":[],"pattern":"appbuilder.kynetx.com/apps/dispatch/","op":"pageview","type":"prim_event","legacy":1}},"cond":{"val":"true","type":"bool"},"actions":[{"action":{"source":null,"args":[{"val":"Dispatch","type":"str"},{"val":"msg","type":"var"}],"name":"notify","modifiers":[{"name":"position","value":{"val":"bottom-right","type":"str"}},{"name":"sticky","value":{"val":"true","type":"bool"}}]}}]},{"blocktype":"every","emit":"\n$K(\"#nav_cardinfo\").attr(\"style\",\"border: blue 5px solid\");            ","pre":[{"rhs":" \n<div class=\"wt\">  \t\t\t<p>  \t\t\t\tClick \"Generate Card\" at the left to continue.  \t\t\t<\/p>  \t\t<\/div>    \t\n ","type":"here_doc","lhs":"msg"}],"name":"generate_dash","callbacks":null,"state":"active","pagetype":{"foreach":[],"event_expr":{"vars":[],"pattern":"appbuilder.kynetx.com/apps/view/","op":"pageview","type":"prim_event","legacy":1}},"cond":{"val":"true","type":"bool"},"actions":[{"action":{"source":null,"args":[{"val":"Generate","type":"str"},{"val":"msg","type":"var"}],"name":"notify","modifiers":[{"name":"position","value":{"val":"bottom-right","type":"str"}},{"name":"sticky","value":{"val":"true","type":"bool"}}]}}]},{"blocktype":"every","emit":"\n$K(\"input[value=Make Card]\").addClass(\"bordered\");            ","pre":[{"rhs":" \n<div class=\"wt\">  \t\t\t<p>  \t\t\t\tThis is where you make the card to import into your card selector. If you don't have a card selector, click <a href=\"http://www.azigo.com\">here.<\/a>  \t\t\t<\/p>  \t\t\t<p>  \t\t\t\tSelect an image if you'd like, otherwise click, \"Make Card\"  \t\t\t<\/p>  \t\t\t<p>  \t\t\t\tNext, after importing your card into your selector, go to \"http://www.kynetx.com/\" or just click <a href=\"http://www.kynetx.com/\">here<\/a>  \t\t\t<\/p>  \t\t<\/div>    \t\n ","type":"here_doc","lhs":"msg"}],"name":"card_info","callbacks":null,"state":"active","pagetype":{"foreach":[],"event_expr":{"vars":[],"pattern":"appbuilder.kynetx.com/apps/cardinfo","op":"pageview","type":"prim_event","legacy":1}},"cond":{"val":"true","type":"bool"},"actions":[{"action":{"source":null,"args":[{"val":"Make A Card!","type":"str"},{"val":"msg","type":"var"}],"name":"notify","modifiers":[{"name":"position","value":{"val":"bottom-right","type":"str"}},{"name":"sticky","value":{"val":"true","type":"bool"}}]}}]},{"blocktype":"every","emit":null,"pre":[{"rhs":" \n<div class=\"wt\">  \t\t<p>  \t\t\tCongratulations! Hopefully everything worked out okay! If not, try refreshing your Browser Extention.  \t\t<\/p>  \t<\/div>    \t\n ","type":"here_doc","lhs":"msg"}],"name":"kynetx","callbacks":null,"state":"active","pagetype":{"foreach":[],"event_expr":{"vars":[],"pattern":"www.kynetx.com","op":"pageview","type":"prim_event","legacy":1}},"cond":{"val":"true","type":"bool"},"actions":[{"action":{"source":null,"args":[{"val":"Moment of truth!","type":"str"},{"val":"msg","type":"var"}],"name":"notify","modifiers":[{"name":"position","value":{"val":"bottom-right","type":"str"}},{"name":"sticky","value":{"val":"true","type":"bool"}}]}}]}],"meta":{"author":"Jessie Morris","description":"\nWalks you through your first Kynetx Rule!     \n","name":"Hello World Tutorial","logging":"off"}}