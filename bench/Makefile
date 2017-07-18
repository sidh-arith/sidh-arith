CC=gcc

all: bench_ms.exe bench_ours.exe bench_shifted.exe bench_double.exe bench_1988.exe

debug: CCFLAGS += -g
debug: all

run: all
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

bench_ms.exe: benchmark.c fp_x64_asm.o 
	$(CC) $(CCFLAGS) -o $@ -DFUNNAME=rdc751_asm $^ -L/usr/local/lib -lgmp -lm

# $@, $^ are left and right of :
bench_ours.exe: benchmark.c interleaved_asm.o
	$(CC) $(CCFLAGS) -o $@ -DFUNNAME=interleaved_asm_rdc_mont $^ -L/usr/local/lib -lgmp -lm

bench_shifted.exe: benchmark.c shifted.o
	$(CC) $(CCFLAGS) -o $@ -DFUNNAME=rdc751_asm $^ -L/usr/local/lib -lgmp -lm

bench_double.exe: benchmark.c doublelimb_asm.o
	$(CC) $(CCFLAGS) -o $@ -DFUNNAME=doublelimb_asm_rdc_mont $^ -L/usr/local/lib -lgmp -lm

bench_1988.exe: benchmark.c better_prime.o
	$(CC) $(CCFLAGS) -o $@ -DFUNNAME=rdcnewp $^ -L/usr/local/lib -lgmp -lm

shifted.o: shifted.S
	gcc $(FLAGS) -c $^

better_prime.o: better_prime.S
	gcc $(FLAGS) -c $^

fp_x64_asm.o: fp_x64_asm.S
	gcc $(FLAGS) -c $^

doublelimb_asm.o: doublelimb_asm.S
	gcc $(FLAGS) -c $^

interleaved_asm.o: interleaved_asm.S
	gcc $(FLAGS) -c $^

.PHONY: clean all run debug

clean:
	$(RM) *.exe *.o
