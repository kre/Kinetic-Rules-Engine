ruleset a16x78 {
  meta {
    name "cs_module"
    description <<
      For testing modules
      System tests depend on this ruleset.  
    >>

   key flippy "hello"
   key floppy {"a" : "six",
               "b" : "seven"}

   configure using c = "Hello"

   provide a,f,search_twitter,flippy,floppy, g

	provide keys foo to loo


  }


  global {
     a = 5;
     b = 6;     
     f = function(x){(x + b)};  
     g = function(){c};     
     datasource twitter_search <- "http://search.twitter.com/search.json";
     search_twitter = function(query) {
        datasource:twitter_search({"q": query,
                                   "rpp": 1
                                   })                    
     };
     flippy = keys:flippy(); 
     floppy = keys:floppy("a");
     calling_rid = meta:callingRid();
     calling_ver = meta:callingVersion();
     my_rid = meta:rid();
     my_ver = meta:version();
 }

}
