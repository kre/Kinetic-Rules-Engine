{"global":[],"dispatch":[{"domain":"google.com"},{"domain":"bing.com"},{"domain":"search.yahoo.com"}],"ruleset_name":"a381x4","rules":[{"blocktype":"every","emit":"\nfunction percolate_select_function(obj){     var regex_test = $K(obj).data(\"domain\").match(/syntech/gi);       if(regex_test){        return true;     } else {        return false;     }  }            ","name":"search","callbacks":null,"state":"active","pagetype":{"foreach":[],"event_expr":{"vars":[],"pattern":"google.com|search.yahoo.com|bing.com","op":"pageview","type":"prim_event","legacy":1}},"cond":{"val":"true","type":"bool"},"actions":[{"action":{"source":null,"args":[{"val":"percolate_select_function","type":"var"}],"name":"percolate","modifiers":null}}]}],"meta":{"author":"Nathan Whiting","description":"\nDemonstration of Percolate     \n","name":"SPercolate","logging":"on"}}