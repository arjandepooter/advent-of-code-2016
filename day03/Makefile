all: run
solution.beam: 
	erl -compile solution.erl
clean:
	rm -f solution.beam
run: clean solution.beam
	erl -run solution -run init stop -noshell