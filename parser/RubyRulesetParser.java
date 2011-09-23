package com.kynetx;

//
// This file is part of the Kinetic Rules Engine (KRE)
// Copyright (C) 2007-2011 Kynetx, Inc. 
//
// KRE is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License as
// published by the Free Software Foundation; either version 2 of
// the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public
// License along with this program; if not, write to the Free
// Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
// MA 02111-1307 USA
//

import org.antlr.runtime.*;
import java.io.*;
import org.json.*;

public class RubyRulesetParser
{ 
		
		public static void main(String[] args) throws Exception 
		{
			File thefile = new File(args[0]);
			String result_type = args[1];
			
				try
				{
					ANTLRFileStream input = new ANTLRFileStream(thefile.getCanonicalPath() );
					com.kynetx.RuleSetLexer lexer = new com.kynetx.RuleSetLexer(input); 
					CommonTokenStream tokens = new CommonTokenStream(lexer); 
					com.kynetx.RuleSetParser parser = new com.kynetx.RuleSetParser(tokens);
					parser.ruleset();			
					JSONObject js = new JSONObject(parser.rule_json);
					if(result_type.equals("validate"))
					{
                    	if(parser.parse_errors.size() > 0 )
                    	{
                        	for(int ii = 0;ii < parser.parse_errors.size() ;ii++)
                        	{
                            	System.out.println("ERROR: " + parser.parse_errors.get(ii));
                        	}
						}
                    }
					else
					{
						System.out.println(js.toString());
//						System.out.println(unescapeUnicode(js.toString()));
					}
				}
				catch(Exception e)
				{
					System.out.println("SYSTEM ERROR : " + e.getMessage());
				}

		}

        private static String unescapeUnicode(String source) {
             /* could use regular expression, but not this time... */
             final int srcLen = source.length();
             char c;

             StringBuffer buffer = new StringBuffer(srcLen);

             // Must have format \\uXXXX where XXXX is a hexadecimal number
             int i=0;
             while (i <srcLen-5) {

                    c = source.charAt(i++);

                    if (c=='\\') {
                        char nc = source.charAt(i);
                        if (nc == 'u') {

                            // Now we found the u we need to find another 4 hex digits
                            // Note: shifting left by 4 is the same as multiplying by 16
                            int v = 0; // Accumulator
                            for (int j=1; j < 5; j++) {
                                nc = source.charAt(i+j);
                                switch(nc)
                                {
                                    case 48: // '0'
                                    case 49: // '1'
                                    case 50: // '2'
                                    case 51: // '3'
                                    case 52: // '4'
                                    case 53: // '5'
                                    case 54: // '6'
                                    case 55: // '7'
                                    case 56: // '8'
                                    case 57: // '9'
                                        v = ((v << 4) + nc) - 48;
                                        break;

                                    case 97: // 'a'
                                    case 98: // 'b'
                                    case 99: // 'c'
                                    case 100: // 'd'
                                    case 101: // 'e'
                                    case 102: // 'f'
                                        v = ((v << 4)+10+nc)-97;
                                        break;

                                    case 65: // 'A'
                                    case 66: // 'B'
                                    case 67: // 'C'
                                    case 68: // 'D'
                                    case 69: // 'E'
                                    case 70: // 'F'
                                        v = ((v << 4)+10+nc)-65;
                                        break;
                                    default:
                                        // almost but no go
                                        j = 6;  // terminate the loop
                                        v = 0;  // clear the accumulator
                                        break;
                                }
                            } // for each of the 4 digits

                            if (v > 0) {      // We got a full conversion
                                c = (char)v;  // Use the converted char
                                i += 5;       // skip the numeric values
                            }
                        }
                    }
                    buffer.append(c);
                }

        	// Fill in the remaining characters from the buffer
        	while (i <srcLen) {
        		buffer.append(source.charAt(i++));
        	}
        	return buffer.toString();
        }

}

