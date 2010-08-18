{"global":[],"dispatch":[{"domain":"google.com"},{"domain":"yahoo.com"},{"domain":"bing.com"},{"domain":"example.com"}],"ruleset_name":"a60x168","rules":[{"blocktype":"every","emit":null,"pre":[{"rhs":{"source":"amazon","args":[{"val":[{"rhs":{"val":"all","type":"str"},"lhs":"index"},{"rhs":{"val":"searchterm","type":"var"},"lhs":"keywords"},{"rhs":{"val":[{"val":"Reviews","type":"str"}],"type":"array"},"lhs":"response_group"}],"type":"hashraw"}],"predicate":"item_search","type":"qualified"},"type":"expr","lhs":"amazon_data"},{"rhs":{"args":[{"val":"$..Item","type":"str"}],"name":"pick","obj":{"val":"amazon_data","type":"var"},"type":"operator"},"type":"expr","lhs":"item"}],"name":"response_group","callbacks":null,"state":"active","pagetype":{"foreach":[],"event_expr":{"vars":["domain","searchterm"],"pattern":".*(bing|google|yahoo?)\\.com.*[\\?,&][p,q]=(.*?)&.*","op":"pageview","type":"prim_event","legacy":1}},"cond":{"val":"true","type":"bool"},"actions":[{"action":{"source":null,"args":[{"val":"Search Engine","type":"str"},{"val":"domain","type":"var"}],"name":"notify","modifiers":[{"name":"sticky","value":{"val":"true","type":"bool"}}]}},{"action":{"source":null,"args":[{"val":"Searched","type":"str"},{"val":"searchterm","type":"var"}],"name":"notify","modifiers":[{"name":"sticky","value":{"val":"true","type":"bool"}}]}},{"emit":"\nconsole.log(\"====================================\");      console.log(amazon_data);      console.log(\"====================================\");                    "}]}],"meta":{"description":"\nTesting amazon lookup   \n","name":"Amazon Test","logging":"off"}}