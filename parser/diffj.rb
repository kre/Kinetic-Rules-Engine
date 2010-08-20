require "rubygems"
require "json"

@@keystack = [];
@@keyarraycount = [];


def showkeys
  result = " ";
  @@keystack.each_index do |idx|
    result = result + @@keystack[idx] + "(" + @@keyarraycount[idx].to_s + ")=>"
  end
  result
end

def diff_hash(left,right)
  
  left.each do |key,value|
    if(["start_col","start_line","meta_start_col","global_start_col","meta_start_line","dispatch_start_col","global_start_line","dispatch_start_line"].include?(key))
      next;
    end
    # if(key == "meta" || key == "rules" || key == "global" || key == "dispatch"  )
    #   puts "====================== " + key + "====================== "
    # end
    @@keystack.push(key);

      rightval = right[key];

      if !check_types(value,rightval)
        @@keystack.pop();
        next
      end

      if(rightval.kind_of? Hash)
#        puts("process hash")
        @@keyarraycount.push(0);
        diff_hash(value,rightval)
        @@keyarraycount.pop();
      elsif (rightval.kind_of?Array)
#        puts("process array")
        @@keyarraycount.push(0);
        diff_array(value,rightval)
        @@keyarraycount.pop();
      else
#        puts("process value")
        check_value(value,rightval);
      end

    @@keystack.pop();
    
  end  
  
end

def blank(thestring)
  return !thestring || thestring.strip().length == 0
end

def check_value(lvalue,rvalue)
  if(rvalue.kind_of?(String) && lvalue.kind_of?(String))
    rvalue = rvalue.strip().gsub("\n","").gsub("\t","");
    lvalue = lvalue.strip().gsub("\n","").gsub("\t","");
  end
  if(rvalue != lvalue)
    puts "E-RVNM" + showkeys + " R[" + (rvalue ? rvalue.to_s : "missing") + "] L[" + (lvalue ? lvalue.to_s : "missing") + "]" 
  end
  
end

def check_types(lvalue,rvalue)

    
    if(lvalue.class.name == rvalue.class.name)
      return true;
    end
    
#    lblank = !lvalue || ((lvalue.kind_of?(Array) || lvalue.kind_of?(Hash)) && lvalue.empty? || lvalue.size() == 0) if !lvalue.kind_of?(String)
#    rblank = !rvalue || ((rvalue.kind_of?(Array) || rvalue.kind_of?(Hash)) && rvalue.empty? || rvalue.size() == 0) if !rvalue.kind_of?(String)
#
#    lblank = blank(lvalue) if lvalue.kind_of?(String)
#    rblank = blank(lvalue) if rvalue.kind_of?(String)
#
#    if( lblank && rblank )
#      # puts "W-LRNBE "  + showkeys + " L[" +  lvalue.class.name + "] R[" +  rvalue.class.name + "]"
#      return false;
#    end

#    if(lvalue.class.name != rvalue.class.name)
     puts "E-LRCM" + showkeys + " L[" +  lvalue.class.name + "] R[" +  rvalue.class.name + "]" + "LV[" +  lvalue.to_s + "] RV[" +  rvalue.to_s + "]"
     return false;
#    end
#    return true;
end

def diff_array(larray,rarray)
  larray.each_index do |idx|
    @@keyarraycount[@@keyarraycount.size - 1] = @@keyarraycount.last + 1;
    lvalue = larray[idx];
    rvalue = rarray[idx];

    if !check_types(lvalue,rvalue)
      next
    end

    if(rvalue.kind_of? Hash)
#      puts("process hash")
      diff_hash(lvalue,rvalue)
    elsif (rvalue.kind_of?Array)
#      puts("process array")
      diff_array(lvalue,rvalue)
    else
#      puts("process value")
      check_value(lvalue,rvalue);
    end

    
  end
    
end



if(!File.exist?(ARGV[0]))
#  puts("Left file Not Found " + ARGV[0]);
  exit(1);
end
if(!File.exist?(ARGV[1]))
  puts("Right file Not Found " +ARGV[1]);
  exit(1);
end

leftside = ""
File.open(ARGV[0]).each_line{ |s|
  leftside << s;
}
rightside = ""
File.open(ARGV[1]).each_line{ |s|
  rightside << s;
}

if leftside.strip.size != 0 && rightside.strip.size != 0
  puts ARGV[0]
  leftj = JSON.parse(leftside,:max_nesting => 50);
  rightj = JSON.parse(rightside,:max_nesting => 50);
  diff_hash(leftj,rightj)
else
  if leftside.strip.size == 0
    exit();
  end
  if rightside.strip.size == 0
    puts "#{ARGV[1]} - right side #{rightside.strip.size} empty "
  end

end


