#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;

use APR::URI;
use APR::Pool ();


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::JavaScript qw/:all/;



plan tests => 5;

my ($krl_src,$result);

$result = <<_RES_;
ruleset 10 {

 rule here_doc0 is active {
    select using "/identity-policy/" setting ()

    pre {

	city = "I live in Lindon";

      second_thing = <<
<div id="second">
<p>This is the second div If you want to say something is much
greater, use &gt;&gt; and say #{city}</p>  
</div>
      >>;

    }

    replace("kobj_test", city_announcement + second_thing);

  }

}
_RES_

$krl_src = <<_KRL_;
ruleset 10 {

 rule here_doc0 is active {
    select using "/identity-policy/" setting ()

    pre {

	city = "I live in Lindon";

      second_thing = <<
<div id="second">
<p>This is the second div If you want to say something is much
greater, use &gt;&gt; and say #{city}</p>  
</div>
      >>;

    }

    replace("kobj_test", city_announcement + second_thing);

  }

}
_KRL_


is_string_nows(remove_comments($krl_src), $result, "No comments leaves it unchanged");


$krl_src = <<_KRL_;
// This is a comment
ruleset 10 {

 rule here_doc0 is active {
    select using "/identity-policy/" setting ()

    pre {

	city = "I live in Lindon";

      second_thing = <<
<div id="second">
<p>This is the second div If you want to say something is much
greater, use &gt;&gt; and say #{city}</p>  
</div>
      >>;

    }

    replace("kobj_test", city_announcement + second_thing);

  }

}
// This is the end
_KRL_


is_string_nows(remove_comments($krl_src), $result, "Comments at the start and end");


$krl_src = <<_KRL_;
ruleset 10 {
// This is a comment

 rule here_doc0 is active {
    select using "/identity-policy/" setting ()

    pre {

	city = "I live in Lindon";
// This is a comment

      second_thing = <<
<div id="second">
<p>This is the second div If you want to say something is much
greater, use &gt;&gt; and say #{city}</p>  
</div>
      >>;

    }
// This is a comment

    replace("kobj_test", city_announcement + second_thing);

  }

}
_KRL_


is_string_nows(remove_comments($krl_src), $result, "Comments inside");


$result = <<_RES_;
ruleset 10 {

 rule here_doc0 is active {
    select using "/identity-policy/" setting ()

    pre {

	city = "I live in Lindon // This is NOT a comment ";

      second_thing = <<
<div id="second">
<p>This is the second div If you want to say something is much
greater, use &gt;&gt; and say #{city}</p> // This is NOT a comment  
</div>
      >>;

    }

    replace("kobj_test", city_announcement + second_thing);

  }

}
_RES_


$krl_src = <<_KRL_;
ruleset 10 {

 rule here_doc0 is active {
    select using "/identity-policy/" setting ()

    pre {

	city = "I live in Lindon // This is NOT a comment";

      second_thing = <<
<div id="second">
<p>This is the second div If you want to say something is much
greater, use &gt;&gt; and say #{city}</p>   // This is NOT a comment
</div>
      >>;

    }

    replace("kobj_test", city_announcement + second_thing);

  }

}
_KRL_


is_string_nows(remove_comments($krl_src), $result, "Comments in string escaped");


$result = <<_RES_;
ruleset 10 {

 rule here_doc0 is active {
    select using "/identity-policy/" setting ()

    pre {

	city = "I live in Lindon // This is NOT a comment ";

      second_thing = <<
<div id="second">
<p>This is the second div If you want to say something is much
greater, use &gt;&gt; and say #{city}</p> <a href="http://www.foo.com">link</a>
</div>
      >>;

    }

    replace("kobj_test", city_announcement + second_thing);

  }

}
_RES_


$krl_src = <<_KRL_;
ruleset 10 {

 rule here_doc0 is active {
    select using "/identity-policy/" setting ()

    pre {

	city = "I live in Lindon // This is NOT a comment";

// this is
      second_thing = <<
<div id="second">
<p>This is the second div If you want to say something is much
greater, use &gt;&gt; and say #{city}</p> <a href="http://www.foo.com">link</a>
</div>
      >>;

    }

    replace("kobj_test", city_announcement + second_thing); // comment at end

  }

}
_KRL_


is_string_nows(remove_comments($krl_src), $result, "Comments in extended quote");




1;


