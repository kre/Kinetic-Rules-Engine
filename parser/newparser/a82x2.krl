{
   "dispatch": [{"domain": "www.azigo.com"}],
   "global": [
      {
         "lhs": "url",
         "rhs": {
            "args": [{
               "type": "str",
               "val": "caller"
            }],
            "predicate": "env",
            "source": "page",
            "type": "qualified"
         },
         "type": "expr"
      },
      {
         "lhs": "ip",
         "rhs": {
            "args": [{
               "type": "str",
               "val": "ip"
            }],
            "predicate": "env",
            "source": "page",
            "type": "qualified"
         },
         "type": "expr"
      },
      {
         "lhs": "referer",
         "rhs": {
            "args": [{
               "type": "str",
               "val": "referer"
            }],
            "predicate": "env",
            "source": "page",
            "type": "qualified"
         },
         "type": "expr"
      },
      {
         "lhs": "rid",
         "rhs": {
            "args": [{
               "type": "str",
               "val": "rid"
            }],
            "predicate": "env",
            "source": "page",
            "type": "qualified"
         },
         "type": "expr"
      },
      {
         "lhs": "host",
         "rhs": {
            "args": [{
               "type": "str",
               "val": "hostname"
            }],
            "predicate": "url",
            "source": "page",
            "type": "qualified"
         },
         "type": "expr"
      },
      {
         "lhs": "path",
         "rhs": {
            "args": [{
               "type": "str",
               "val": "path"
            }],
            "predicate": "url",
            "source": "page",
            "type": "qualified"
         },
         "type": "expr"
      }
   ],
   "meta": {
      "author": "tjc",
      "description": "\njust for testing ErrorStack stuff     \n",
      "logging": "off",
      "name": "ErrorStack Test"
   },
   "rules": [],
   "ruleset_name": "a82x2"
}
