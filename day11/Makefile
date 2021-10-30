all: clean run

solution.jar:
	kotlinc solution.kt -include-runtime -d solution.jar

clean:
	rm -rf solution.jar

run: solution.jar
	java -jar solution.jar