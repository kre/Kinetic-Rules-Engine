


;
FixedElement=Class.create();

FixedElement.prototype={
    initialize:function(_44){
	this.elem=_44;
	new ScrollWatcher(this.handle_scroll.bind(this));
	this.scrolling=false;
	this.newy=0;
    },
    handle_scroll:function(y,x){
	if(this.scrolling){
	    this.newy+=y;
	}else{
	    this.scrolling=true;
	    new Effect.MoveBy(this.elem,y,x,{duration:0.25,afterFinish:function(){
		this.done();
	    }.bind(this)});
	}
    },
    done:function(){
	if(this.newy!=0){
	    new Effect.MoveBy(this.elem,this.newy,0,{duration:0.25,afterFinish:function(){
		this.done();
	    }.bind(this)});
	    this.newy=0;
	}else{
	    this.scrolling=false;
	}
    }};

ScrollWatcher=Class.create();
ScrollWatcher.prototype={initialize:function(cb){
    this.y_previous=0;
    this.callback=cb;
    setInterval(function(){
	this.watch();
    }.bind(this),100);
},watch:function(){
    if(y=this.y_scrolledby()){
	this.y_previous=this.y_current();
	this.callback(y,0);
    }
},y_scrolledby:function(){
    return (this.y_current()-this.y_previous);
},y_current:function(){
    var sy=0;
    if(document.documentElement&&document.documentElement.scrollTop){
	sy=document.documentElement.scrollTop;
    }else{
	if(document.body&&document.body.scrollTop){
	    sy=document.body.scrollTop;
	}else{
	    if(window.pageYOffset){
		sy=window.pageYOffset;
	    }else{
		if(window.scrollY){
		    sy=window.scrollY;
		}
	    }
	}
    }
    return sy;
}};



