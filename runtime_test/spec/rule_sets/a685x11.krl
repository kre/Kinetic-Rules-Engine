ruleset a685x11 {
    meta {
        name "domTest"
        logging off
    }
    rule domtester is active {
        select using "http://k-misc.s3.amazonaws.com/runtime-dependencies/domWatch.html" setting()

        emit <<
$K('body').append('<div id="kobj_loaded"></div>');  $K('#domTestClicker').bind('click',function(){      $K('#domTestContent').html('<div id="domTestPresent">Clicked</div>');  });  KOBJ.watchDOM('#domTestContent',function(){         $K('body').append('<div id="domTestWorked">DOM Test Worked</div>');  });            >>
        noop();
    }

}