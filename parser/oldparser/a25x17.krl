{"global":[{"source":"http://preview.kiimby.com/npo/json","name":"ilhigh_dataset","type":"dataset","datatype":"JSON","cachable":{"period":"hours","value":"23"}},{"rhs":{"val":"ilhigh_dataset","type":"var"},"lhs":"sites","type":"expr"},{"emit":"var sites_list = new Array();\r\n       for (i=0;i<sites.ilhigh.length;i++) {\r\n            var temp_url = new String(sites.ilhigh[i].npo.url);\r\n            if ( temp_url.match(/org$/) != null) \r\n               sites_list[temp_url + '/'] = true;\r\n           else\r\n                sites_list[temp_url] = true;\r\n        }\r\n       "}],"global_start_line":14,"dispatch":[{"domain":"google.com","ruleset_id":null},{"domain":"bing.com","ruleset_id":null},{"domain":"yahoo.com","ruleset_id":null}],"dispatch_start_col":5,"meta_start_line":2,"rules":[{"cond":{"val":"true","type":"bool"},"blocktype":"every","actions":[{"label":null,"emit":"var percolated = false;\r\n        var toPercolateOrNot = function(obj) {\r\n          if (!percolated) {\r\n            var url = $K(obj).data(\"url\");\r\n       /*     for (i=0;i<sites.ilhigh.length;i++) {\r\n                var url_db = sites.ilhigh[i].npo.url;\r\n                if(url_db === url || (url_db + '/') === url || url_db === (url + '/') || (url_db + '/') === (url + '/') ) {             \r\n                    percolated = true;\r\n                    return true;\r\n                }              \r\n            } \r\n            return false;*/\r\n             var o = sites_list[url];\r\n             if (o) {\r\n               percolated = true;\r\n               return true;\r\n             }\r\n             else\r\n                return false;\r\n          }\r\n          else\r\n            return false;\r\n        };\r\n        \r\n        var toAnnotateOrNot = function(obj) {\r\n           var url = $K(obj).data(\"url\");\r\n           var o = sites_list[url];\r\n             if (o)\r\n                return '<a href=\"http://www.ilivehereigivehere.org/\"><img alt=\"Your Partnership puts you right in front of DONORS who want to give\" src=\"http://preview.kiimby.com/files/npo/logo/ilhigh.jpg\" title=\"I Live Here I Give Here\" /></a>';\r\n             else\r\n                return false;\r\n        };\r\n    "},{"action":{"source":null,"name":"percolate","args":[{"val":"toPercolateOrNot","type":"var"}],"modifiers":[{"value":{"val":[{"rhs":{"val":[{"rhs":{"val":"num=100","type":"str"},"lhs":"resultNumParem"}],"type":"hashraw"},"lhs":"www.google.com"},{"rhs":{"val":[{"rhs":{"val":"num=100","type":"str"},"lhs":"resultNumParem"}],"type":"hashraw"},"lhs":"search.yahoo.com/search"},{"rhs":{"val":[{"rhs":{"val":"num=100","type":"str"},"lhs":"resultNumParem"}],"type":"hashraw"},"lhs":"bing.com/search"}],"type":"hashraw"},"name":"site"}],"vars":null},"label":null},{"action":{"source":null,"name":"annotate_search_results","args":[{"val":"toAnnotateOrNot","type":"var"}],"modifiers":[{"value":{"val":[{"rhs":{"val":[{"rhs":{"val":"num=100","type":"str"},"lhs":"resultNumParem"}],"type":"hashraw"},"lhs":"www.google.com"},{"rhs":{"val":[{"rhs":{"val":"num=100","type":"str"},"lhs":"resultNumParem"}],"type":"hashraw"},"lhs":"search.yahoo.com/search"},{"rhs":{"val":[{"rhs":{"val":"num=100","type":"str"},"lhs":"resultNumParem"}],"type":"hashraw"},"lhs":"bing.com/search"}],"type":"hashraw"},"name":"site"}],"vars":null},"label":null}],"post":null,"pre":null,"name":"annotate_and_percolate","start_col":1,"emit":null,"state":"active","callbacks":null,"pagetype":{"event_expr":{"pattern":"google.com|bing.com|yahoo.com","legacy":1,"type":"prim_event","vars":[],"op":"pageview"},"foreach":[]},"start_line":31}],"meta_start_col":5,"meta":{"keys":{"errorstack":"247356e0dd953d77e86278417290b9ca"},"logging":"off","name":"ILHIGH RemindMe","meta_start_line":2,"meta_start_col":5},"dispatch_start_line":9,"global_start_col":5,"ruleset_name":"a25x17"}