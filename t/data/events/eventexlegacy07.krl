ruleset two_rules_first_raises_second {
     rule t10 is active {
       select when pageview ".*"
       noop();
       fired {
         raise explicit event foo;
       }
     }
     rule t12 is active {
       select when explicit foo
       pre {
         x = 5;
       }
       noop();
     }
 }