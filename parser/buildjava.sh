. ./myclasspath.sh
java org.antlr.Tool RuleSet2.g -o output
mkdir output/classes
javac -d output/classes  output/RuleSet2*.java json_java/*.java ParseRuleset.java
