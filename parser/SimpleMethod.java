package com.kynetx;
import org.antlr.runtime.*;
import java.io.*;
import org.json.*;
import java.util.*;

public class SimpleMethod
	{

		public static void main(String[] args) throws Exception
		{

				File thefile = new File(args[0]);
				try
				{
					ANTLRFileStream input = new ANTLRFileStream(thefile.getCanonicalPath() );
					com.kynetx.RuleSetLexer lexer = new com.kynetx.RuleSetLexer(input);
					CommonTokenStream tokens = new CommonTokenStream(lexer);
					com.kynetx.RuleSetParser parser = new com.kynetx.RuleSetParser(tokens);
					ArrayList block_array = new ArrayList();
					com.kynetx.RuleSetParser.expr_return result = parser.expr();

					HashMap map = new HashMap();
					map.put("result",result.result);
					JSONObject js = new JSONObject(map);
                    if(parser.parse_errors.size() >0)
                    {
                        for(int ii = 0;ii < parser.parse_errors.size() ;ii++)
                        {
                            System.err.println("ERROR FOUND " + parser.parse_errors.get(ii));
                        }
                    }
					System.out.println(js.toString());
				}
				catch(Exception e)
				{
				}

		}
}
