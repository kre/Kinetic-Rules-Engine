{"global":[{"rhs":{"source":"page","predicate":"env","args":[{"val":"caller","type":"str"}],"type":"qualified"},"lhs":"url","type":"expr"},{"rhs":{"source":"page","predicate":"env","args":[{"val":"ip","type":"str"}],"type":"qualified"},"lhs":"ip","type":"expr"},{"rhs":{"source":"page","predicate":"env","args":[{"val":"referer","type":"str"}],"type":"qualified"},"lhs":"referer","type":"expr"},{"rhs":{"source":"page","predicate":"env","args":[{"val":"rid","type":"str"}],"type":"qualified"},"lhs":"rid","type":"expr"},{"rhs":{"source":"page","predicate":"url","args":[{"val":"hostname","type":"str"}],"type":"qualified"},"lhs":"host","type":"expr"},{"rhs":{"source":"page","predicate":"url","args":[{"val":"path","type":"str"}],"type":"qualified"},"lhs":"path","type":"expr"},{"rhs":{"source":"page","predicate":"url","args":[{"val":"query","type":"str"}],"type":"qualified"},"lhs":"query","type":"expr"},{"emit":"var os=escape(navigator.platform);        var ua=escape(navigator.userAgent);        var browser=escape(navigator.appName);        errorStack = function(url,referer,rid,host){    \t\tvar txt=\"_s=8ec21aa3544cef2568e58944698e4c67&_r=img\";    \t\ttxt+=\"&Msg=foo\";    \t\ttxt+=\"&URL=\"+escape(url);    \t\ttxt+=\"&Line=0\";    \t\ttxt+=\"&Platform=\"+escape(navigator.platform);    \t\ttxt+=\"&UserAgent=\"+escape(navigator.userAgent);                    txt+=\"&referer=\"+escape(referer);                    txt+=\"&rid=\"+escape(rid);                    txt+=\"&host=\"+escape(host);        \t\tvar i = document.createElement(\"img\");    \t\ti.setAttribute(\"src\", ((\"https:\" == document.location.protocol) ?     \t\t\t\"https://errorstack.appspot.com\" : \"http://www.errorstack.com\") + \"/submit?\" + txt);    \t\tdocument.body.appendChild(i);    \t\tvar x='msg sent';                    return x;    }                "}],"global_start_line":13,"dispatch":[{"domain":"www.azigo.com","ruleset_id":null}],"dispatch_start_col":5,"meta_start_line":2,"rules":[{"cond":{"val":"true","type":"bool"},"blocktype":"every","actions":[{"action":{"source":null,"name":"notify","args":[{"val":"ErrorStack Test","type":"str"},{"val":"msg","type":"var"}],"modifiers":[{"value":{"val":"true","type":"bool"},"name":"sticky"},{"value":{"val":"#66FF33","type":"str"},"name":"background_color"},{"value":{"val":"#000000","type":"str"},"name":"text_color"},{"value":{"val":1,"type":"num"},"name":"opacity"}]},"label":null}],"post":null,"pre":[{"rhs":"url = #{url} <br />  ip = #{ip} <br />  referer = #{referer} <br />  rid = #{rid} <br />  host = #{host} <br />  path = #{path} <br />  query = #{query} <br />  os = #{os} <br />  browser = #{browser} <br />  ua = #{ua} <br />  \n ","lhs":"msg","type":"here_doc"}],"name":"alert","start_col":5,"emit":"var x=errorStack(url,referer,rid,host);   msg.=x;          ","state":"active","callbacks":null,"pagetype":{"event_expr":{"pattern":"www.azigo.com","legacy":1,"type":"prim_event","vars":[],"op":"pageview"},"foreach":[]},"start_line":17}],"meta_start_col":5,"meta":{"logging":"off","name":"ErrorStack Test","meta_start_line":2,"author":"tjc","description":"just for testing ErrorStack stuff     \n","meta_start_col":5},"dispatch_start_line":10,"global_start_col":5,"ruleset_name":"a82x2"}