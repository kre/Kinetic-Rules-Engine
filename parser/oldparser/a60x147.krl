{"global":[],"global_start_line":null,"dispatch":[{"domain":"example.com","ruleset_id":null}],"dispatch_start_col":5,"meta_start_line":2,"rules":[{"cond":{"val":"true","type":"bool"},"blocktype":"every","actions":[{"action":{"source":null,"name":"notify","args":[{"val":"'same' == 'same'?","type":"str"},{"val":"shouldBeSame","type":"var"}],"modifiers":[{"value":{"val":"true","type":"bool"},"name":"sticky"}]},"label":null},{"action":{"source":null,"name":"notify","args":[{"val":"'different' == 'yes'?","type":"str"},{"val":"shouldBeDifferent","type":"var"}],"modifiers":[{"value":{"val":"true","type":"bool"},"name":"sticky"}]},"label":null}],"post":null,"pre":[{"rhs":{"expr":{"args":[{"val":"string1","type":"var"},{"val":"string2","type":"var"}],"type":"ineq","op":"=="},"vars":["string1","string2"],"type":"function","decls":[]},"lhs":"isSame","type":"expr"},{"rhs":{"expr":{"test":{"args":[{"val":"num","type":"var"},{"val":0,"type":"num"}],"type":"ineq","op":"=="},"then":{"val":"false ","type":"str"},"else":{"val":"true ","type":"str"},"type":"condexpr"},"vars":["num"],"type":"function","decls":[]},"lhs":"convertBool","type":"expr"},{"rhs":{"args":[{"val":"same","type":"str"},{"val":"same","type":"str"}],"function_expr":{"val":"isSame","type":"var"},"type":"app"},"lhs":"same","type":"expr"},{"rhs":{"args":[{"val":"different","type":"str"},{"val":"yes","type":"str"}],"function_expr":{"val":"isSame","type":"var"},"type":"app"},"lhs":"different","type":"expr"},{"rhs":{"args":[{"val":"same","type":"var"}],"function_expr":{"val":"convertBool","type":"var"},"type":"app"},"lhs":"shouldBeSame","type":"expr"},{"rhs":{"args":[{"val":"different","type":"var"}],"function_expr":{"val":"convertBool","type":"var"},"type":"app"},"lhs":"shouldBeDifferent","type":"expr"}],"name":"simple_string_compare_using_function","start_col":5,"emit":null,"state":"active","callbacks":null,"pagetype":{"event_expr":{"pattern":".*","legacy":1,"type":"prim_event","vars":[],"op":"pageview"},"foreach":[]},"start_line":10}],"meta_start_col":5,"meta":{"logging":"on","name":"String Comparison","meta_start_line":2,"author":"Mike Grace","meta_start_col":5},"dispatch_start_line":7,"global_start_col":null,"ruleset_name":"a60x147"}