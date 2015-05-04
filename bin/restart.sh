#!/bin/bash
(cd ~/lib/perl/parser; ./buildjava.sh);perl -MInline::Java::Server=restart;sudo /etc/init.d/httpd restart
