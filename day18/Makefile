all: clean run

solution.o:
	nasm -f elf64 solution.nasm -o solution.o
solution: solution.o
	ld solution.o -o solution
clean:
	rm -f solution
	rm -f solution.o

run: solution
	./solution
