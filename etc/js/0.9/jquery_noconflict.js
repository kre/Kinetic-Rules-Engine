$$KOBJ = jQuery.noConflict();
/*  This will be set if there was a $ variable set before we started  */
if(typeof($$PREKOBJ) != 'undefined')
{
    $ = $$PREKOBJ;    
}
