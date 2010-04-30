if (typeof($KOBJ) == 'undefined') {

    /* If there is a $ then we need to track it so we can set it back when we are done loading */
    if(typeof($) != 'undefined')
    {
        $$PREKOBJ = $;
    }
    window['kobj_fn'] = '$kobj_file';
    window['kobj_ts'] = '$dstamp$hstamp';