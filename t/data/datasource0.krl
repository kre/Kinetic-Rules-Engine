// datasets and emits mixes with some rules
ruleset 10 {

   global {
      dataset aaa <- "aaa.json";
      dataset aarp <- "aarp.json";

      emit <<
var pagename = 'foobar';
>>;

      datasource fliip:HTML <- "http://clearplay.com/filtercart.aspx?" cachable for 1 days;


   }

    rule testa is active {
        select using "/test/" setting()
        replace("test","test");
    }

    rule testb is active {
        select using "/test/" setting()
        replace("test","test");
    }


}
