{"global":[{"rhs":{"val":[{"rhs":{"val":[],"type":"hashraw"},"lhs":"ecommunity.unisys.com"},{"rhs":{"val":[],"type":"hashraw"},"lhs":"www.unisys.com"},{"rhs":{"val":[],"type":"hashraw"},"lhs":"www.unite.org"},{"rhs":{"val":[],"type":"hashraw"},"lhs":"www.wikipedia.org"},{"rhs":{"val":[],"type":"hashraw"},"lhs":"www.ibm.com"}],"type":"hashraw"},"lhs":"sites","type":"expr"}],"global_start_line":18,"dispatch":[{"domain":"google.com","ruleset_id":null},{"domain":"bing.com","ruleset_id":null},{"domain":"yahoo.com","ruleset_id":null}],"dispatch_start_col":2,"meta_start_line":2,"rules":[{"cond":{"val":"true","type":"bool"},"blocktype":"every","actions":[{"action":{"source":null,"name":"annotate_search_results","args":[{"val":"selector","type":"var"}],"modifiers":null,"vars":null},"label":null}],"post":null,"pre":null,"name":"annotate","start_col":1,"emit":"var selector =  function(obj) { \n            if ($K(obj).data(\"domain\") in sites ) {\n              return '<img src=\"http://www.unisys.com/unisys/inc/img/ui/logo.jpg\"/>'; \n            } else {\n              return false;\n           }\n           };\n       ","state":"active","callbacks":null,"pagetype":{"event_expr":{"pattern":"google.com/search|bing.com/search|search.yahoo.com/search","legacy":1,"type":"prim_event","vars":[],"op":"pageview"},"foreach":[]},"start_line":28},{"cond":{"val":"true","type":"bool"},"blocktype":"every","actions":[{"action":{"source":null,"name":"percolate","args":[{"val":"selector","type":"var"}],"modifiers":null,"vars":null},"label":null}],"post":null,"pre":null,"name":"percolate","start_col":1,"emit":"function selector(obj) { \n                var domain = $K(obj).data(\"domain\");\n                  return (domain in sites);\n              }\n         ","state":"active","callbacks":null,"pagetype":{"event_expr":{"pattern":"google.com/search|bing.com/search|search.yahoo.com/search","legacy":1,"type":"prim_event","vars":[],"op":"pageview"},"foreach":[]},"start_line":42}],"meta_start_col":5,"meta":{"logging":"on","name":"ClearPath Search Percolation","meta_start_line":2,"description":"Adjusts search results to bring Unisys ClearPath hits higher   \n","meta_start_col":5},"dispatch_start_line":10,"global_start_col":1,"ruleset_name":"a143x5"}