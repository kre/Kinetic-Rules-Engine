KOBJ.watchDOM = function(selector,callBackFunc,time){
  if(!KOBJ.watcherRunning){
    KOBJ.log("Starting the DOM Watcher");
    var KOBJ_setInterval = 0;
    if(typeof(setInterval_native) != "undefined"){
      KOBJ_setInterval = setInterval_native;
    } else {
      KOBJ_setInterval = setInterval;
    }
    if(KOBJ.watcherRunning){clearInterval(KOBJ.watcherRunning);}
	    KOBJ.watcherData = KOBJ.watcherData || [];
	    KOBJ.log("DOM Watcher Callback for new selector " +selector+ " added");
	    $K(selector+" :first").addClass("KOBJ_AjaxWatcher");
	    var there = false;
	    if($K(selector+" :first").is(".KOBJ_AjaxWatcher")){
		    there = true;
	    }
	    KOBJ.watcherData.push({"selector": selector,"callBacks": [callBackFunc], "there": there});
	    KOBJ.watcher = function(){
	      $K(KOBJ.watcherData).each(function(){
					  var data = this;
					  var selectorExists = $K(selector).length;
					  if(!selectorExists|| !data.there){return;}
					  var hasNotChanged = $K(data.selector+" :first").is(".KOBJ_AjaxWatcher");
					  if(!hasNotChanged){
					    $K(data.callBacks).each(function(){
								      callBack = this;
								      KOBJ.log("Running call back on selector " + selector);
								      callBack();
								    });
					    $K(data.selector+" :first").addClass("KOBJ_AjaxWatcher");
					  }
	      });
	    };
	KOBJ.watcherRunning = KOBJ_setInterval(KOBJ.watcher,time||500);
   } else {
		$K(KOBJ.watcherData).each(function(){
			dataObj = this;
			if(dataObj.selector == selector){
				dataObj.callBacks.push(callBackFunc);
				$K(selector+" :first").addClass("KOBJ_AjaxWatcher");
				
				if($K(selector+" :first").is(".KOBJ_AjaxWatcher")){
					dataObj.there = true;
				} else {
					dataObj.there = false;
				}
			
				KOBJ.log("DOM Watcher Callback for previous selector " +selector+ " added");
				return false;//breaks out of the loop.
			
			} else {
				var there = false;
				
				if($K(selector+" :first").is(".KOBJ_AjaxWatcher")){
					there = true;
				}

				KOBJ.watcherData.push({"selector": selector,"callBacks": [callBackFunc], "there": there});
				$K(selector+" :first").addClass("KOBJ_AjaxWatcher");
				KOBJ.log("DOM Watcher Call for new selector "+selector+" added");
			}
		});//end each
  }//end if/else
};
