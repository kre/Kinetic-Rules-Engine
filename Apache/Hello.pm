package Apache::Hello;
# file: Apache/Hello.pm

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Const -compile => qw(OK);

sub handler {
    my $r = shift;

    $r->content_type('text/html');
    my $host = $r->connection->get_remote_host;
    print <<END;
<html>
<head>
<title>Hello World</title>
</head>
<body>
<h1>Hello $host</h1>
<p>
This is the hello world apache module!
</p>
</body>
</html>
END

    return Apache2::Const::OK;
}




1;

