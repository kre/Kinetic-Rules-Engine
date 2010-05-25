
if (typeof($KOBJ) != 'undefined') {
    //KOBJ.log("Runtime Already Active");
//    alert("Reuntime Active");
}

//if (typeof($KOBJ) == 'undefined' || (typeof($KOBJ) != 'undefined' && typeof(KOBJ_Sandbox) != "undefined")) {
if (typeof($KOBJ) == 'undefined') {
//    alert("Setting up runtime");
    //KOBJ.log("Runtime Not Active");

    /* If there is a $ then we need to track it so we can set it back when we are done loading */
    if(typeof($) != 'undefined')
    {
        $$PREKOBJ = $;
    }
    window['kobj_fn'] = '$kobj_file';
    window['kobj_ts'] = '$dstamp$hstamp';