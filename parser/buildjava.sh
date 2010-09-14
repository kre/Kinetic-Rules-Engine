. ./myclasspath.sh
java org.antlr.Tool RuleSet.g -o output
mkdir output/classes
javac -d output/classes  output/RuleSet*.java json_java/*.java ParseRuleset.java FullParserReport.java SimpleMethod.java
