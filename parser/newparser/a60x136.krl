{"global":[],"dispatch":[{"domain":"example.com"}],"ruleset_name":"a60x136","rules":[{"blocktype":"every","emit":null,"pre":[{"rhs":{"vars":["x"],"decls":[],"expr":{"op":"+","args":[{"val":"x","type":"var"},{"val":5,"type":"num"}],"type":"prim"},"type":"function"},"type":"expr","lhs":"add5"},{"rhs":{"args":[{"val":15,"type":"num"}],"type":"app","function_expr":{"val":"add5","type":"var"}},"type":"expr","lhs":"newnum"}],"name":"newrule","callbacks":null,"state":"active","pagetype":{"foreach":[],"event_expr":{"vars":[],"pattern":".*","op":"pageview","type":"prim_event","legacy":1}},"cond":{"val":"true","type":"bool"},"actions":[{"action":{"source":null,"args":[{"val":"15 + 5 is ...","type":"str"},{"val":"newnum","type":"var"}],"name":"notify","modifiers":null}}]}],"meta":{"author":"Mike Grace","name":"Function sandbox","logging":"on"}}