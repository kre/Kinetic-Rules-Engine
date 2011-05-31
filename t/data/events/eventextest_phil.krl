ruleset a16x78 {
  meta {
    name "cs_module"
    description <<
      For testing modules
      System tests depend on this ruleset.  
    >>

   configure using c = "Hello"

   provide a,f,search_twitter,flippy,floppy, g, calling_rid, calling_ver, my_rid, my_ver

   key flippy "hello"
   key floppy {"a" : "six",
               "b" : "seven"}

  }

  dispatch {
  }

  global {
     a = 5;
     b = 6;     
     f = function(x){x + b};  
     g = function(){c}     
     datasource twitter_search <- "http://search.twitter.com/search.json";
     search_twitter = function(query) {
        datasource:twitter_search({"q": query,
                                   "rpp": 1
                                   });                    
     }     
     
     flippy = keys:flippy(); 
     floppy = keys:floppy("a");
     calling_rid = meta:callingRID();
     calling_ver = meta:callingVersion();
     my_rid = meta:moduleRID();
     my_ver = meta:moduleVersion();
     inM = meta:inModule() => "In a module" | "Not in a module";
     
  }
}