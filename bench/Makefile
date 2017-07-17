CC=gcc

all: bench_ms bench_ours bench_shifted bench_double bench_1988

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

bench_ms: fp_x64_asm.o 
	$(CC) $(CCFLAGS) benchmark.c -DFUNNAME=rdc751_asm fp_x64_asm.o -o $@.exe -L/usr/local/lib -lgmp -lm

# $@, $^ are left and right of :
bench_ours: interleaved_asm.o
	$(CC) $(CCFLAGS) benchmark.c -DFUNNAME=rdc_mont interleaved_asm.o -o $@.exe -L/usr/local/lib -lgmp -lm

bench_shifted: shifted.o
	$(CC) $(CCFLAGS) benchmark.c -DFUNNAME=rdc751_asm shifted.o -o $@.exe -L/usr/local/lib -lgmp -lm

bench_double: doublelimb_asm.o
	$(CC) $(CCFLAGS) benchmark.c -DFUNNAME=rdc_mont doublelimb_asm.o -o $@.exe -L/usr/local/lib -lgmp -lm

bench_1988: msr_better_prime.o
	$(CC) $(CCFLAGS) benchmark.c -DFUNNAME=rdcnewp msr_better_prime.o -o $@.exe -L/usr/local/lib -lgmp -lm

shifted.o:
	gcc $(FLAGS) -c shifted.S

msr_better_prime.o:
	gcc $(FLAGS) -c msr_better_prime.S

fp_x64_asm.o:
	gcc $(FLAGS) -c fp_x64_asm.S

doublelimb_asm.o:
	gcc $(FLAGS) -c doublelimb_asm.S

interleaved_asm.o: interleaved_asm.S
	gcc $(FLAGS) -c interleaved_asm.S

.PHONY: clean all run debug

clean:
	$(RM) *.exe *.o
