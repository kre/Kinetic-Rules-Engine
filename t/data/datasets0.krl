// dataset with some rules
ruleset 10 {

   dataset {
      aaa = "aaa.json";
      aarp = "aarp.json";
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
