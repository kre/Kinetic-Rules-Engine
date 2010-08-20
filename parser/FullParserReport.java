package com.kynetx;
import org.antlr.runtime.*;
import java.io.*;
import org.json.*;
import java.util.*;

public class FullParserReport
	{

        public static ArrayList<String> skipped_files = new ArrayList<String>();
        public static HashMap<String, ArrayList> errors = new HashMap<String, ArrayList>();
        public static ArrayList<String> success =  new ArrayList<String>();

		public static void main(String[] args) throws Exception
		{
			File f = new File(args[0]);
			File[] files = null;
			if(f.isDirectory())
			{
				files = f.listFiles();
			}

			for(int i =0;i< files.length;i++)
			{
				File thefile = files[i];
				long start = System.currentTimeMillis();
				boolean  skipfile = false;

				if(thefile.length() == 0 || thefile.length() == 31 ||  thefile.length() == 162 || skipfile)
				{
                    skipped_files.add(thefile.toString());
					continue;
				}
				try
				{
				    //System.out.println(thefile);
					ANTLRFileStream input = new ANTLRFileStream(thefile.getCanonicalPath() );
					com.kynetx.RuleSetLexer lexer = new com.kynetx.RuleSetLexer(input);
					CommonTokenStream tokens = new CommonTokenStream(lexer);
					com.kynetx.RuleSetParser parser = new com.kynetx.RuleSetParser(tokens);
					parser.ruleset();
					JSONObject js = new JSONObject(parser.rule_json);
                    if(parser.parse_errors.size() >0)
                    {
                        errors.put(thefile.toString(),parser.parse_errors);
                    }
                    else
                    {
                        success.add(thefile.toString());
                    }
				}
				catch(Exception e)
				{
				    System.out.println("Execption " + e.getMessage());
				}
			}
			System.out.println("Not Parsed " + skipped_files.size());
			System.out.println("Success Parsed " + success.size());

              Object[]  keys = errors.keySet().toArray();
			 System.out.println("Error Parsed " + keys.length);
			  for(int iii = 0;iii < keys.length ;iii++)
			  {
			            String name = (String)keys[iii];
			            System.out.println(name);
			            ArrayList elist = errors.get(name);
			            for(int ii = 0;ii < elist.size() ;ii++)
                        {
                            System.out.println("\tERROR FOUND " + elist.get(ii));
                        }
              }

		}
}
