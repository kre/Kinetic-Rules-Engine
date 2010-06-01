#!/usr/bin/perl -w 

#
# Copyright 2007-2009, Kynetx Inc.  All rights reserved.
# 
# This Software is an unpublished, proprietary work of Kynetx Inc.
# Your access to it does not grant you any rights, including, but not
# limited to, the right to install, execute, copy, transcribe, reverse
# engineer, or transmit it by any means.  Use of this Software is
# governed by the terms of a Software License Agreement transmitted
# separately.
# 
# Any reproduction, redistribution, or reverse engineering of the
# Software not in accordance with the License Agreement is expressly
# prohibited by law, and may result in severe civil and criminal
# penalties. Violators will be prosecuted to the maximum extent
# possible.
# 
# Without limiting the foregoing, copying or reproduction of the
# Software to any other server or location for further reproduction or
# redistribution is expressly prohibited, unless such reproduction or
# redistribution is expressly permitted by the License Agreement
# accompanying this Software.
# 
# The Software is warranted, if at all, only according to the terms of
# the License Agreement. Except as warranted in the License Agreement,
# Kynetx Inc. hereby disclaims all warranties and conditions
# with regard to the software, including all warranties and conditions
# of merchantability, whether express, implied or statutory, fitness
# for a particular purpose, title and non-infringement.
# 
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


my $test_count = 0;

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
$test_count++;

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
$test_count++;


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
$test_count++;


$result = <<_RES_;
ruleset 10 {

 rule here_doc0 is active {
    select using "/identity-policy/" setting ()

    pre {

	city = "I live in Lindon // This is NOT a comment ";

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

	city = "I live in Lindon // This is NOT a comment";

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


is_string_nows(remove_comments($krl_src), $result, "Comments in string escaped");
$test_count++;


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

//
// AAA
//

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
$test_count++;


$result = <<_RES_;
ruleset 10 {
 rule here_doc0 is active {
    select using "/identity-policy/" setting ()

    pre {


      first_thing = <<
<div id="second">
<p>This is the second div If you want to say something is much
greater, use &gt;&gt; and say #{city}</p> <a href="http://www.foo.com">link</a>
</div>
      >>;

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

//
// AAA
//

 rule here_doc0 is active {
    select using "/identity-policy/" setting ()

    pre {


      first_thing = <<
<div id="second">
<p>This is the second div If you want to say something is much
greater, use &gt;&gt; and say #{city}</p> <a href="http://www.foo.com">link</a>
</div>
      >>;
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
$test_count++;


$result = <<_RES_;
ruleset 10 {
 rule here_doc0 is active {
    select using "/identity-policy/" setting ()

    pre {


      first_thing = <<
<div id="second">
<p>This is the second div If you want to say something is much
greater, use &gt;&gt; and say #{city}</p> <a href="http://www.foo.com">link</a>
</div>
      >>;

      second_thing = <<
<div id="second">
<p>This is the second div If you want to say something is much
greater, use &gt;&gt; and say #{city}</p> <a href="http://www.foo.com">link</a>
</div>
      >>;

    }

    {
    emit <<
          // this is a test comment.  Should not be stripped!
          if(KOBJ.watching){ } else {
            KOBJ.watchDOM("#rso>li:last",function(){
              KOBJ.get_application("a41x98").reload();
              KOBJ.watching = true;
            });
          }
>>
    }

  }

}
_RES_


$krl_src = <<_KRL_;
ruleset 10 {

//
// AAA
//

 rule here_doc0 is active {
    select using "/identity-policy/" setting ()

    pre {


      first_thing = <<
<div id="second">
<p>This is the second div If you want to say something is much
greater, use &gt;&gt; and say #{city}</p> <a href="http://www.foo.com">link</a>
</div>
      >>;
// this is
      second_thing = <<
<div id="second">
<p>This is the second div If you want to say something is much
greater, use &gt;&gt; and say #{city}</p> <a href="http://www.foo.com">link</a>
</div>
      >>;

    }

    {
    // this should go!!
    emit <<
          // this is a test comment.  Should not be stripped!
          if(KOBJ.watching){ } else {
            KOBJ.watchDOM("#rso>li:last",function(){
              KOBJ.get_application("a41x98").reload();
              KOBJ.watching = true;
            });
          }
>>
    }

  }

}
_KRL_


is_string_nows(remove_comments($krl_src), $result, "Comments in extended quote");
$test_count++;



$krl_src = <<_KRL_;
ruleset a41x98 {
    meta {
        name "Shop Local"
        author "Grigglee"
        description <<
          Spanish Fork Chamber of Commerce - Shop Local           
        >>
        
        logging on    
    }
    dispatch {
        domain "google.com"
        domain "bing.com"
        domain "search.yahoo.com"
        domain "1800contacts.com"
        domain "1800flowers.com"
	domain "local.yahoo.com"
    }
    
    global {
      datasource chamber_listings <- "http://grigglee.com/random/chamber/chamber_search.php" cachable for 1 minute;
    }

    
    rule local_annotate is active {
      select using "^http://(?:www|search).(?:bing|google|yahoo).com/.*(?:search|#hl|webhp).*(?:&|\?)(?:p|q)=(.*?)(:?&|$)" setting(searchTerms)
        pre {
          ad_data = datasource:chamber_listings({"searchTerms":searchTerms,"adSize":"ad_300x250"});
          random = math:random(ad_data.length());
          ad = ad_data[random].pick("$.ad_300x250");
        }
        
        emit <<
          if(KOBJ.watching){ } else {
            KOBJ.watchDOM("#rso>li:last",function(){
              KOBJ.get_application("a41x98").reload();
              KOBJ.watching = true;
            });
          }
	function chamber_local_annotate(thisData){
		if(thisData){
			if(thisData.key){
				var element;
				KOBJ.a41x98.num = KOBJ.a41x98.num - 1 || thisData.num;
				if(\$K("."+thisData.key)[0].tagName == "TR"){
					element = \$K("."+thisData.key);
				} else {
					element = \$K("."+thisData.key).parent();
				}
				var shopLocalImg = '<img src="http:\/\/grigglee.com/random/chamber/shoplocal.png" />';
	
				if(!\$K('.griggleeChamber').length){
					\$K(element).siblings(':first').before(\$K(element));
				} else {
					var randomLength = Math.floor(Math.random() * (thisData.num - KOBJ.a41x98.num));
					if(Math.floor(Math.random() * 2)){
						\$K('.griggleeChamber:eq('+randomLength+')').before(\$K(element));
					} else {
						\$K('.griggleeChamber:eq('+randomLength+')').after(\$K(element));
					}
				}

				\$K(">td:eq(1)",element).after('<td valign="top" style="width: 59px; height: 62px; padding-left:4px;padding-bottom:2px; padding-top:2px;"><div class="shopLocalLogo">'+shopLocalImg+'</div></td>');
				\$K(">td:gt(0)",element).css({"background-color":"#d6ecff"});
				\$K(">td:eq(1)",element).addClass("griggleeBorderLeft");
				\$K(">td:eq(2)",element).addClass("griggleeBorderRight");
				if(thisData.local_annotation){
					\$K(">td:eq(1)",element).append(\$K('<div>'+thisData.local_annotation+'</div>').addClass("griggleeAnnotation"));
				}
				
				\$K(element).addClass("griggleeChamber");
				\$K(".griggleeChamber").removeClass("griggleeFirst").removeClass("griggleeLast");
				\$K(".griggleeChamber:first").addClass("griggleeFirst");
				\$K(".griggleeChamber:last").addClass("griggleeLast");
			}
		}
           
		return false;
	}
        >>
        {
          annotate_local_search_results(chamber_local_annotate)
            with
            remote = "http://grigglee.com/random/chamber/chamber_annotation.php?jsoncallback=?" and domains = {"www.google.com":{"watcher":""}};
          replace_html("#tads","");
          move_to_top("#res li.g:has([href^=http://maps])");
          prepend("#rhs_block,#rhsline",ad);
        }
    }

}
_KRL_


is_string_nows(remove_comments($krl_src), 
	       $krl_src, 
	       "Jesse's problem");
$test_count++;



#-----------------------------------------------------------------------------

done_testing($test_count);




1;


