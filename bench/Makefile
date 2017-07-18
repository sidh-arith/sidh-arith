CC=gcc

all: bench_ms.exe bench_ours.exe bench_shifted.exe bench_double.exe bench_1988.exe test.exe test_newprime.exe

debug: CCFLAGS += -g
debug: all

benchmark: all
	@echo "MS"
	@./bench_ms.exe
	@echo "\nOURS"
	@./bench_ours.exe
	@echo "\nMS SHIFTED"
	@./bench_shifted.exe
	@echo "\nMS/KCM DOUBLELIMB"
	@./bench_double.exe
	@echo "\nMS/KCM 2^391 * 19^88 - 1"
	@./bench_1988.exe

count:
	./count.py shifted.S
	./count.py better_prime.S
	./count.py fp_x64_asm.S
	./count.py doublelimb_asm.S
	./count.py interleaved_asm.S

test: test.exe test_newprime.exe
	./test.exe
	./test_newprime.exe

bench_ms.exe: benchmark.c fp_x64_asm.o 
	$(CC) $(CCFLAGS) -o $@ -DFUNNAME=rdc751_asm $^ -L/usr/local/lib -lgmp -lm

# $@, $^ are left and right of :
bench_ours.exe: benchmark.c interleaved_asm.o
	$(CC) $(CCFLAGS) -o $@ -DFUNNAME=interleaved_asm_rdc_mont $^ -L/usr/local/lib -lgmp -lm

bench_shifted.exe: benchmark.c shifted.o
	$(CC) $(CCFLAGS) -o $@ -DFUNNAME=shifted_rdc_mont $^ -L/usr/local/lib -lgmp -lm

bench_double.exe: benchmark.c doublelimb_asm.o
	$(CC) $(CCFLAGS) -o $@ -DFUNNAME=doublelimb_asm_rdc_mont $^ -L/usr/local/lib -lgmp -lm

bench_1988.exe: benchmark.c better_prime.o
	$(CC) $(CCFLAGS) -o $@ -DFUNNAME=rdcnewp $^ -L/usr/local/lib -lgmp -lm

interleavedMontgomery1.o: interleavedMontgomery.c
	$(CC) $(FLAGS) -D VERSION1 -o $@ -c $^

interleavedMontgomery2.o: interleavedMontgomery.c
	$(CC) $(FLAGS) -D VERSION2 -o $@ -c $^

interleaved_asm.o: interleaved_asm.S
	gcc $(FLAGS) -c $^

doublelimb_asm.o: doublelimb_asm.S
	gcc $(FLAGS) -c $^

better_prime.o: better_prime.S
	gcc $(FLAGS) -c $^

shifted.o: shifted.S
	gcc $(FLAGS) -c $^

fp_x64_asm.o: fp_x64_asm.S
	gcc $(FLAGS) -c $^

# std1 vs std2 vs std_asm vs doublimb
test.exe: test.c interleavedMontgomery1.o interleavedMontgomery2.o interleaved_asm.o shifted.o doublelimb_asm.o p751.o
	$(CC) $(FLAGS) -o $@ $^ -L/usr/local/lib -lgmp

test_newprime.exe: test_newprime.c better_prime.o
	$(CC) $(FLAGS) -o $@ $^ -L/usr/local/lib -lgmp

p751.o: p751.c
	$(CC) $(FLAGS) -c $^


.PHONY: clean all benchmark debug test

clean:
	$(RM) *.exe *.o
