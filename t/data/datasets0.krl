// dataset with some rules
ruleset 10 {
   datasets {
      aaa = "aaa.json";
      aarp = "aarp.json";
      fizz_data = "http://www.foo.com/data.json" cachable;
      foo_data = "http://www.foo.com/data.json" cachable for 20 minutes;
   }

    rule testa is active {
        select using "/test/" setting()
        pre { 
        } 
        replace("test","test");
    }

    rule testb is active {
        select using "/test/" setting()
        pre { 
        } 
        replace("test","test");
    }


}
