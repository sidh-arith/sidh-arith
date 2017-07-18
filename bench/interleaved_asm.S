// vim: set ft=asm foldmethod=marker:
.intel_syntax noprefix 

#define reg_p1 rdi
#define reg_p2 rsi
#define reg_p3 rdx
#define reg_p4 rcx

.text

.global interleaved_asm_rdc_mont
interleaved_asm_rdc_mont:

//void rdc_mont(mp_limb_t *a, mp_limb_t *c) {
#define ap rdi
#define cp rsi

/* Precomputed value: 3^239*2^372 / 2^(256+64) */
#define mp1_0 0xeeb0000000000000
#define mp1_1 0xe3ec968549f878a8
#define mp1_2 0xda959b1a13f7cc76
#define mp1_3 0x084e9867d6ebe876
#define mp1_4 0x8562b5045cb25748
#define mp1_5 0x0e12909f97badc66
#define mp1_6 0x00006fe5d541f71c

#define p751_0     0xFFFFFFFFFFFFFFFF
#define p751_5     0xEEAFFFFFFFFFFFFF
#define p751_6     0xE3EC968549F878A8
#define p751_7     0xDA959B1A13F7CC76
#define p751_8     0x084E9867D6EBE876
#define p751_9     0x8562B5045CB25748
#define p751_10    0x0E12909F97BADC66
#define p751_11    0x00006FE5D541F71C
rdc_mont:
prologue:
    push rbp // save base pointer

    mov rbp, rsp // stack top is new base

    push rbp // I am going to hell..

    // rax and rdx are used by mul
    // rsi and rdi are used for arguments
    // looks like we do have 12 left...
    // rbx, rcx, rbp, rsp, r8, r9, r10, r11, r12, r13, r14, r15
    // push all you will use
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    push rbx
    push rcx

    // mp_limb_t t1[24] = {0}
    sub rsp, 24*8
    // mp_limb_t A[24];
    sub rsp, 24*8
    #define t1 rsp+24*8
    #define A rsp

    mov rcx, 24
    zero:
        //movq [rsp+rcx*8], 0xffffffffffffffff
        dec rcx
        //movq [A + rcx*8], 0
        movq [t1 + rcx*8], 0
        jnz zero

actualcode:

    //  /* We do on purpose longer additions than needed. */
    //  mul_modulus_1 (t1, a[0]);                /* t2 = a[0] * (p+1) */
    // where 
    //      #define mul_modulus_1(c,a) c[0] = 0; c[1] = 0; c[2] = 0; c[3] = 0; c[4] = 0; c[12] = mpn_mul_1 (c+5, mp1, 7, a)
    // =~  bigcarry = mpn_mul_1 (out, x, lnx, y)

    // mul r11 * rax -> rdx.rax
    //adc [cp+56], rdx
    // can this carry? highpart + 1?
    // a <= 2**64 - 1 
    // b <= 2**64 - 1 
    // a*b <= (2^64 - 1)^2 < (2^64 - 1) * 2^64
    // which is highest part filled only => NO
    //addc [cp+8], 0 

    //            mpn_add_n (A, a+1, t1+1, 23);   /* (t1+t2)/2^64 */
    // =~ carry = mpn_add_n(rp, s1p,  s2p, n);    /* (t1+t2)/2^64 */

    //adc [A + 8], [t1 + 16] // could this carry 2? a + b < 2^(k+1) - 2 => NO.

    // <((1))> {{{
    // multiplication: t1 <- mp1 * ap
    mov r8, [ap]
    mov rax, mp1_0
    mul r8
    mov /*T5*/r10, rax
    mov /*T6*/r11, rdx
    movq /*T7*/r12, 0
    mov rax, mp1_1
    mul r8
    add /*T6*/r11, rax
    adc /*T7*/r12, rdx
    xor /*T8*/r13, /*T8*/r13
    mov rax, mp1_2
    mul r8
    add /*T7*/r12, rax
    adc /*T8*/r13, rdx
    xor /*T9*/r15, /*T9*/r15
    mov rax, mp1_3
    mul r8
    add /*T8*/r13, rax
    adc /*T9*/r15, rdx
    xor /*T10*/rcx, /*T10*/rcx
    mov rax, mp1_4
    mul r8
    add /*T9*/r15, rax
    adc /*T10*/rcx, rdx
    xor /*T11*/rbx, /*T11*/rbx
    mov rax, mp1_5
    mul r8
    add /*T10*/rcx, rax
    adc /*T11*/rbx, rdx
    xor /*T12*/rbp, /*T12*/rbp
    mov rax, mp1_6
    mul r8
    add /*T11*/rbx, rax
    adc /*T12*/rbp, rdx
    // addition
    mov r8, [ap + 8]
    mov [A], r8
    mov r8, [ap + 16]
    mov [A + 8], r8
    mov r8, [ap + 24]
    mov [A + 16], r8
    mov r8, [ap + 32]
    mov [A + 24], r8
    mov r8, [ap + 40]
    add r8, /*T5*/r10
    mov [A + 32], r8
    mov r8, [ap + 48]
    adc r8, /*T6*/r11
    mov [A + 40], r8
    mov r8, [ap + 56]
    adc r8, /*T7*/r12
    mov [A + 48], r8
    mov r8, [ap + 64]
    adc r8, /*T8*/r13
    mov [A + 56], r8
    mov r8, [ap + 72]
    adc r8, /*T9*/r15
    mov [A + 64], r8
    mov r8, [ap + 80]
    adc r8, /*T10*/rcx
    mov [A + 72], r8
    mov r8, [ap + 88]
    adc r8, /*T11*/rbx
    mov [A + 80], r8
    mov r8, [ap + 96]
    adc r8, /*T12*/rbp
    mov [A + 88], r8
    movq r14, 0
    adcq r14, 0
    // }}} </((1))>

    //#define R(i) mul_modulus_1 (t1, A[0]); mpn_add_n (A, A+1, t1+1, (24-1-i))
    // <((R1))> {{{
    // multiplication: t1 <- mp1 * A
    mov r8, [A]
    mov rax, mp1_0
    mul r8
    mov /*T5*/r10, rax
    mov /*T6*/r11, rdx
    movq /*T7*/r12, 0
    mov rax, mp1_1
    mul r8
    add /*T6*/r11, rax
    adc /*T7*/r12, rdx
    xor /*T8*/r13, /*T8*/r13
    mov rax, mp1_2
    mul r8
    add /*T7*/r12, rax
    adc /*T8*/r13, rdx
    xor /*T9*/r15, /*T9*/r15
    mov rax, mp1_3
    mul r8
    add /*T8*/r13, rax
    adc /*T9*/r15, rdx
    xor /*T10*/rcx, /*T10*/rcx
    mov rax, mp1_4
    mul r8
    add /*T9*/r15, rax
    adc /*T10*/rcx, rdx
    xor /*T11*/rbx, /*T11*/rbx
    mov rax, mp1_5
    mul r8
    add /*T10*/rcx, rax
    adc /*T11*/rbx, rdx
    xor /*T12*/rbp, /*T12*/rbp
    mov rax, mp1_6
    mul r8
    add /*T11*/rbx, rax
    adc /*T12*/rbp, rdx
    // addition
    adc [A + 40], /*T5*/r10
    adc [A + 48], /*T6*/r11
    adc [A + 56], /*T7*/r12
    adc [A + 64], /*T8*/r13
    adc [A + 72], /*T9*/r15
    adc [A + 80], /*T10*/rcx
    adc [A + 88], /*T11*/rbx
    adc /*T12*/rbp, r14
    movq r14, 0
    adcq r14, 0
    add /*T12*/rbp, [ap + 104]
    adcq r14, 0
    mov [A + 96], /*T12*/rbp
    // }}} </((R1))>
    // <((R2))> {{{
    // multiplication: t1 <- mp1 * A
    mov r8, [A + 8]
    mov rax, mp1_0
    mul r8
    mov /*T5*/r10, rax
    mov /*T6*/r11, rdx
    movq /*T7*/r12, 0
    mov rax, mp1_1
    mul r8
    add /*T6*/r11, rax
    adc /*T7*/r12, rdx
    xor /*T8*/r13, /*T8*/r13
    mov rax, mp1_2
    mul r8
    add /*T7*/r12, rax
    adc /*T8*/r13, rdx
    xor /*T9*/r15, /*T9*/r15
    mov rax, mp1_3
    mul r8
    add /*T8*/r13, rax
    adc /*T9*/r15, rdx
    xor /*T10*/rcx, /*T10*/rcx
    mov rax, mp1_4
    mul r8
    add /*T9*/r15, rax
    adc /*T10*/rcx, rdx
    xor /*T11*/rbx, /*T11*/rbx
    mov rax, mp1_5
    mul r8
    add /*T10*/rcx, rax
    adc /*T11*/rbx, rdx
    xor /*T12*/rbp, /*T12*/rbp
    mov rax, mp1_6
    mul r8
    add /*T11*/rbx, rax
    adc /*T12*/rbp, rdx
    // addition
    adc [A + 48], /*T5*/r10
    adc [A + 56], /*T6*/r11
    adc [A + 64], /*T7*/r12
    adc [A + 72], /*T8*/r13
    adc [A + 80], /*T9*/r15
    adc [A + 88], /*T10*/rcx
    adc [A + 96], /*T11*/rbx
    adc /*T12*/rbp, r14
    movq r14, 0
    adcq r14, 0
    add /*T12*/rbp, [ap + 112]
    adcq r14, 0
    mov [A + 104], /*T12*/rbp
    // }}} </((R2))>
    // <((R3))> {{{
    // multiplication: t1 <- mp1 * A
    mov r8, [A + 16]
    mov rax, mp1_0
    mul r8
    mov /*T5*/r10, rax
    mov /*T6*/r11, rdx
    movq /*T7*/r12, 0
    mov rax, mp1_1
    mul r8
    add /*T6*/r11, rax
    adc /*T7*/r12, rdx
    xor /*T8*/r13, /*T8*/r13
    mov rax, mp1_2
    mul r8
    add /*T7*/r12, rax
    adc /*T8*/r13, rdx
    xor /*T9*/r15, /*T9*/r15
    mov rax, mp1_3
    mul r8
    add /*T8*/r13, rax
    adc /*T9*/r15, rdx
    xor /*T10*/rcx, /*T10*/rcx
    mov rax, mp1_4
    mul r8
    add /*T9*/r15, rax
    adc /*T10*/rcx, rdx
    xor /*T11*/rbx, /*T11*/rbx
    mov rax, mp1_5
    mul r8
    add /*T10*/rcx, rax
    adc /*T11*/rbx, rdx
    xor /*T12*/rbp, /*T12*/rbp
    mov rax, mp1_6
    mul r8
    add /*T11*/rbx, rax
    adc /*T12*/rbp, rdx
    // addition
    adc [A + 56], /*T5*/r10
    adc [A + 64], /*T6*/r11
    adc [A + 72], /*T7*/r12
    adc [A + 80], /*T8*/r13
    adc [A + 88], /*T9*/r15
    adc [A + 96], /*T10*/rcx
    adc [A + 104], /*T11*/rbx
    adc /*T12*/rbp, r14
    movq r14, 0
    adcq r14, 0
    add /*T12*/rbp, [ap + 120]
    adcq r14, 0
    mov [A + 112], /*T12*/rbp
    // }}} </((R3))>
    // <((R4))> {{{
    // multiplication: t1 <- mp1 * A
    mov r8, [A + 24]
    mov rax, mp1_0
    mul r8
    mov /*T5*/r10, rax
    mov /*T6*/r11, rdx
    movq /*T7*/r12, 0
    mov rax, mp1_1
    mul r8
    add /*T6*/r11, rax
    adc /*T7*/r12, rdx
    xor /*T8*/r13, /*T8*/r13
    mov rax, mp1_2
    mul r8
    add /*T7*/r12, rax
    adc /*T8*/r13, rdx
    xor /*T9*/r15, /*T9*/r15
    mov rax, mp1_3
    mul r8
    add /*T8*/r13, rax
    adc /*T9*/r15, rdx
    xor /*T10*/rcx, /*T10*/rcx
    mov rax, mp1_4
    mul r8
    add /*T9*/r15, rax
    adc /*T10*/rcx, rdx
    xor /*T11*/rbx, /*T11*/rbx
    mov rax, mp1_5
    mul r8
    add /*T10*/rcx, rax
    adc /*T11*/rbx, rdx
    xor /*T12*/rbp, /*T12*/rbp
    mov rax, mp1_6
    mul r8
    add /*T11*/rbx, rax
    adc /*T12*/rbp, rdx
    // addition
    adc [A + 64], /*T5*/r10
    adc [A + 72], /*T6*/r11
    adc [A + 80], /*T7*/r12
    adc [A + 88], /*T8*/r13
    adc [A + 96], /*T9*/r15
    adc [A + 104], /*T10*/rcx
    adc [A + 112], /*T11*/rbx
    adc /*T12*/rbp, r14
    movq r14, 0
    adcq r14, 0
    add /*T12*/rbp, [ap + 128]
    adcq r14, 0
    mov [A + 120], /*T12*/rbp
    // }}} </((R4))>
    // <((R5))> {{{
    // multiplication: t1 <- mp1 * A
    mov r8, [A + 32]
    mov rax, mp1_0
    mul r8
    mov /*T5*/r10, rax
    mov /*T6*/r11, rdx
    movq /*T7*/r12, 0
    mov rax, mp1_1
    mul r8
    add /*T6*/r11, rax
    adc /*T7*/r12, rdx
    xor /*T8*/r13, /*T8*/r13
    mov rax, mp1_2
    mul r8
    add /*T7*/r12, rax
    adc /*T8*/r13, rdx
    xor /*T9*/r15, /*T9*/r15
    mov rax, mp1_3
    mul r8
    add /*T8*/r13, rax
    adc /*T9*/r15, rdx
    xor /*T10*/rcx, /*T10*/rcx
    mov rax, mp1_4
    mul r8
    add /*T9*/r15, rax
    adc /*T10*/rcx, rdx
    xor /*T11*/rbx, /*T11*/rbx
    mov rax, mp1_5
    mul r8
    add /*T10*/rcx, rax
    adc /*T11*/rbx, rdx
    xor /*T12*/rbp, /*T12*/rbp
    mov rax, mp1_6
    mul r8
    add /*T11*/rbx, rax
    adc /*T12*/rbp, rdx
    // addition
    adc [A + 72], /*T5*/r10
    adc [A + 80], /*T6*/r11
    adc [A + 88], /*T7*/r12
    adc [A + 96], /*T8*/r13
    adc [A + 104], /*T9*/r15
    adc [A + 112], /*T10*/rcx
    adc [A + 120], /*T11*/rbx
    adc /*T12*/rbp, r14
    movq r14, 0
    adcq r14, 0
    add /*T12*/rbp, [ap + 136]
    adcq r14, 0
    mov [A + 128], /*T12*/rbp
    // }}} </((R5))>
    // <((R6))> {{{
    // multiplication: t1 <- mp1 * A
    mov r8, [A + 40]
    mov rax, mp1_0
    mul r8
    mov /*T5*/r10, rax
    mov /*T6*/r11, rdx
    movq /*T7*/r12, 0
    mov rax, mp1_1
    mul r8
    add /*T6*/r11, rax
    adc /*T7*/r12, rdx
    xor /*T8*/r13, /*T8*/r13
    mov rax, mp1_2
    mul r8
    add /*T7*/r12, rax
    adc /*T8*/r13, rdx
    xor /*T9*/r15, /*T9*/r15
    mov rax, mp1_3
    mul r8
    add /*T8*/r13, rax
    adc /*T9*/r15, rdx
    xor /*T10*/rcx, /*T10*/rcx
    mov rax, mp1_4
    mul r8
    add /*T9*/r15, rax
    adc /*T10*/rcx, rdx
    xor /*T11*/rbx, /*T11*/rbx
    mov rax, mp1_5
    mul r8
    add /*T10*/rcx, rax
    adc /*T11*/rbx, rdx
    xor /*T12*/rbp, /*T12*/rbp
    mov rax, mp1_6
    mul r8
    add /*T11*/rbx, rax
    adc /*T12*/rbp, rdx
    // addition
    adc [A + 80], /*T5*/r10
    adc [A + 88], /*T6*/r11
    adc [A + 96], /*T7*/r12
    adc [A + 104], /*T8*/r13
    adc [A + 112], /*T9*/r15
    adc [A + 120], /*T10*/rcx
    adc [A + 128], /*T11*/rbx
    adc /*T12*/rbp, r14
    movq r14, 0
    adcq r14, 0
    add /*T12*/rbp, [ap + 144]
    adcq r14, 0
    mov [A + 136], /*T12*/rbp
    // }}} </((R6))>
    // <((R7))> {{{
    // multiplication: t1 <- mp1 * A
    mov r8, [A + 48]
    mov rax, mp1_0
    mul r8
    mov /*T5*/r10, rax
    mov /*T6*/r11, rdx
    movq /*T7*/r12, 0
    mov rax, mp1_1
    mul r8
    add /*T6*/r11, rax
    adc /*T7*/r12, rdx
    xor /*T8*/r13, /*T8*/r13
    mov rax, mp1_2
    mul r8
    add /*T7*/r12, rax
    adc /*T8*/r13, rdx
    xor /*T9*/r15, /*T9*/r15
    mov rax, mp1_3
    mul r8
    add /*T8*/r13, rax
    adc /*T9*/r15, rdx
    xor /*T10*/rcx, /*T10*/rcx
    mov rax, mp1_4
    mul r8
    add /*T9*/r15, rax
    adc /*T10*/rcx, rdx
    xor /*T11*/rbx, /*T11*/rbx
    mov rax, mp1_5
    mul r8
    add /*T10*/rcx, rax
    adc /*T11*/rbx, rdx
    xor /*T12*/rbp, /*T12*/rbp
    mov rax, mp1_6
    mul r8
    add /*T11*/rbx, rax
    adc /*T12*/rbp, rdx
    // addition
    adc [A + 88], /*T5*/r10
    adc [A + 96], /*T6*/r11
    adc [A + 104], /*T7*/r12
    adc [A + 112], /*T8*/r13
    adc [A + 120], /*T9*/r15
    adc [A + 128], /*T10*/rcx
    adc [A + 136], /*T11*/rbx
    adc /*T12*/rbp, r14
    movq r14, 0
    adcq r14, 0
    add /*T12*/rbp, [ap + 152]
    adcq r14, 0
    mov [A + 144], /*T12*/rbp
    // }}} </((R7))>
    // <((R8))> {{{
    // multiplication: t1 <- mp1 * A
    mov r8, [A + 56]
    mov rax, mp1_0
    mul r8
    mov /*T5*/r10, rax
    mov /*T6*/r11, rdx
    movq /*T7*/r12, 0
    mov rax, mp1_1
    mul r8
    add /*T6*/r11, rax
    adc /*T7*/r12, rdx
    xor /*T8*/r13, /*T8*/r13
    mov rax, mp1_2
    mul r8
    add /*T7*/r12, rax
    adc /*T8*/r13, rdx
    xor /*T9*/r15, /*T9*/r15
    mov rax, mp1_3
    mul r8
    add /*T8*/r13, rax
    adc /*T9*/r15, rdx
    xor /*T10*/rcx, /*T10*/rcx
    mov rax, mp1_4
    mul r8
    add /*T9*/r15, rax
    adc /*T10*/rcx, rdx
    xor /*T11*/rbx, /*T11*/rbx
    mov rax, mp1_5
    mul r8
    add /*T10*/rcx, rax
    adc /*T11*/rbx, rdx
    xor /*T12*/rbp, /*T12*/rbp
    mov rax, mp1_6
    mul r8
    add /*T11*/rbx, rax
    adc /*T12*/rbp, rdx
    // addition
    adc [A + 96], /*T5*/r10
    adc [A + 104], /*T6*/r11
    adc [A + 112], /*T7*/r12
    adc [A + 120], /*T8*/r13
    adc [A + 128], /*T9*/r15
    adc [A + 136], /*T10*/rcx
    adc [A + 144], /*T11*/rbx
    adc /*T12*/rbp, r14
    movq r14, 0
    adcq r14, 0
    add /*T12*/rbp, [ap + 160]
    adcq r14, 0
    mov [A + 152], /*T12*/rbp
    // }}} </((R8))>
    // <((R9))> {{{
    // multiplication: t1 <- mp1 * A
    mov r8, [A + 64]
    mov rax, mp1_0
    mul r8
    mov /*T5*/r10, rax
    mov /*T6*/r11, rdx
    movq /*T7*/r12, 0
    mov rax, mp1_1
    mul r8
    add /*T6*/r11, rax
    adc /*T7*/r12, rdx
    xor /*T8*/r13, /*T8*/r13
    mov rax, mp1_2
    mul r8
    add /*T7*/r12, rax
    adc /*T8*/r13, rdx
    xor /*T9*/r15, /*T9*/r15
    mov rax, mp1_3
    mul r8
    add /*T8*/r13, rax
    adc /*T9*/r15, rdx
    xor /*T10*/rcx, /*T10*/rcx
    mov rax, mp1_4
    mul r8
    add /*T9*/r15, rax
    adc /*T10*/rcx, rdx
    xor /*T11*/rbx, /*T11*/rbx
    mov rax, mp1_5
    mul r8
    add /*T10*/rcx, rax
    adc /*T11*/rbx, rdx
    xor /*T12*/rbp, /*T12*/rbp
    mov rax, mp1_6
    mul r8
    add /*T11*/rbx, rax
    adc /*T12*/rbp, rdx
    // addition
    adc [A + 104], /*T5*/r10
    adc [A + 112], /*T6*/r11
    adc [A + 120], /*T7*/r12
    adc [A + 128], /*T8*/r13
    adc [A + 136], /*T9*/r15
    adc [A + 144], /*T10*/rcx
    adc [A + 152], /*T11*/rbx
    adc /*T12*/rbp, r14
    movq r14, 0
    adcq r14, 0
    add /*T12*/rbp, [ap + 168]
    adcq r14, 0
    mov [A + 160], /*T12*/rbp
    // }}} </((R9))>
    // <((R10))> {{{
    // multiplication: t1 <- mp1 * A
    mov r8, [A + 72]
    mov rax, mp1_0
    mul r8
    mov /*T5*/r10, rax
    mov /*T6*/r11, rdx
    movq /*T7*/r12, 0
    mov rax, mp1_1
    mul r8
    add /*T6*/r11, rax
    adc /*T7*/r12, rdx
    xor /*T8*/r13, /*T8*/r13
    mov rax, mp1_2
    mul r8
    add /*T7*/r12, rax
    adc /*T8*/r13, rdx
    xor /*T9*/r15, /*T9*/r15
    mov rax, mp1_3
    mul r8
    add /*T8*/r13, rax
    adc /*T9*/r15, rdx
    xor /*T10*/rcx, /*T10*/rcx
    mov rax, mp1_4
    mul r8
    add /*T9*/r15, rax
    adc /*T10*/rcx, rdx
    xor /*T11*/rbx, /*T11*/rbx
    mov rax, mp1_5
    mul r8
    add /*T10*/rcx, rax
    adc /*T11*/rbx, rdx
    xor /*T12*/rbp, /*T12*/rbp
    mov rax, mp1_6
    mul r8
    add /*T11*/rbx, rax
    adc /*T12*/rbp, rdx
    // addition
    adc [A + 112], /*T5*/r10
    adc [A + 120], /*T6*/r11
    adc [A + 128], /*T7*/r12
    adc [A + 136], /*T8*/r13
    adc [A + 144], /*T9*/r15
    adc [A + 152], /*T10*/rcx
    adc [A + 160], /*T11*/rbx
    adc /*T12*/rbp, r14
    movq r14, 0
    adcq r14, 0
    add /*T12*/rbp, [ap + 176]
    adcq r14, 0
    mov [A + 168], /*T12*/rbp
    // }}} </((R10))>
    //#undef R

    //  mul_modulus_1 (t1, A[0]);
    //  mpn_add_n (c, A+1, t1+1, 12);
    // <((4))> {{{
    // multiplication: t1 <- mp1 * A
    mov r8, [A + 80]
    mov rax, mp1_0
    mul r8
    mov /*T5*/r10, rax
    mov /*T6*/r11, rdx
    movq /*T7*/r12, 0
    mov rax, mp1_1
    mul r8
    add /*T6*/r11, rax
    adc /*T7*/r12, rdx
    xor /*T8*/r13, /*T8*/r13
    mov rax, mp1_2
    mul r8
    add /*T7*/r12, rax
    adc /*T8*/r13, rdx
    xor /*T9*/r15, /*T9*/r15
    mov rax, mp1_3
    mul r8
    add /*T8*/r13, rax
    adc /*T9*/r15, rdx
    xor /*T10*/rcx, /*T10*/rcx
    mov rax, mp1_4
    mul r8
    add /*T9*/r15, rax
    adc /*T10*/rcx, rdx
    xor /*T11*/rbx, /*T11*/rbx
    mov rax, mp1_5
    mul r8
    add /*T10*/rcx, rax
    adc /*T11*/rbx, rdx
    xor /*T12*/rbp, /*T12*/rbp
    mov rax, mp1_6
    mul r8
    add /*T11*/rbx, rax
    adc /*T12*/rbp, rdx
    // addition
    mov r8, [A + 88]
    mov [cp], r8
    mov r9, [A + 96]
    mov [cp + 8], r9
    mov r8, [A + 104]
    mov [cp + 16], r8
    mov r9, [A + 112]
    mov [cp + 24], r9
    mov r8, [A + 120]
    adc r8, /*T5*/r10
    mov [cp + 32], r8
    mov r9, [A + 128]
    adc r9, /*T6*/r11
    mov [cp + 40], r9
    mov r8, [A + 136]
    adc r8, /*T7*/r12
    mov [cp + 48], r8
    mov r9, [A + 144]
    adc r9, /*T8*/r13
    mov [cp + 56], r9
    mov r8, [A + 152]
    adc r8, /*T9*/r15
    mov [cp + 64], r8
    mov r9, [A + 160]
    adc r9, /*T10*/rcx
    mov [cp + 72], r9
    mov r8, [A + 168]
    adc r8, /*T11*/rbx
    mov [cp + 80], r8
    mov r9, r14
    movq r14, 0
    adc r9, [ap + 184]
    add r9, /*T12*/rbp
    mov [cp + 88], r9
    // }}} </((4))>
    // --- output stuff
    #ifdef DEBUG
    //mov r12, 10
    //mov rcx, 24
    //stuff:
    //    dec rcx
    //    movq r11, [A + rcx*8]
    //    mov r13, rcx
    //    sub r13, r12
    //    movq [cp + r13*8], r11
    //    jnz stuff
    jmp epilogue
    #endif
    // --- /output stuff

    //  if (mpn_cmp (c, p751, 12) >= 0) {
    //    mpn_sub_n (c, c, p751, 12);
    //  }

    // stolen from the helpful folks at ms ;)
    // Final, constant-time correction
    mov    rax, [cp]
    movq   rcx, p751_0  
    // rax = rax - rcx = c0 - p0
    sub    rax, rcx 
    // c0 = c0 - p0
    mov    [cp], rax
    mov    rax, [cp+8]
    // rax = rax - rcx = c1 - p0
    sbb    rax, rcx 
    // c1 = c1 - p0
    mov    [cp+8], rax
    mov    rax, [cp+16]
    // rax = rax - rcx = c2 - p0
    sbb    rax, rcx
    // c2 = c2 - p0
    mov    [cp+16], rax
    mov    r12, [cp+24]
    // r12 = r12 - rcx = c3 - p0
    sbb    r12, rcx
    mov    r13, [cp+32]
    // r13 = r13 - rcx = c4 - p0
    sbb    r13, rcx
    mov    r14, [cp+40]
    movq   rcx, p751_5  
    // r14 = r14 - rcx = c5 - p5
    sbb    r14, rcx
    mov    r15, [cp+48]
    movq   rcx, p751_6  
    // r15 = r15 - rcx = c6 - p6
    sbb    r15, rcx
    mov    rax, [cp+56]
    movq   rcx, p751_7  
    // rax = rax - rcx = c7 - p7
    sbb    rax, rcx
    mov    rdx, [cp+64]
    movq   rcx, p751_8  
    // rdx = rdx - rcx = c8 - p8
    sbb    rdx, rcx
    movq   rcx, p751_9  
    // inserted
    mov    r8, [cp+72]
    // r8 = r8 - rcx = c9 - p9
    sbb    r8, rcx
    movq   rcx, p751_10  
    // inserted
    mov    r9, [cp+80]
    // r9 = r9 - rcx = c10 - p10
    sbb    r9, rcx
    movq   rcx, p751_11  
    // inserted
    mov    r10, [cp+88]
    // r10 = r10 - rcx = c11 - p11
    sbb    r10, rcx
    // rcx = 0
    movq   rcx, 0
    // ...uh ...rcx = 0/-1?
    sbb    rcx, 0

    movq   r11, p751_0  
    and    rcx, r11
    mov    r11, [cp]
    add    r11, rcx  
    mov    [cp], r11  
    mov    r11, [cp+8]
    adc    r11, rcx  
    mov    [cp+8], r11  
    mov    r11, [cp+16]
    adc    r11, rcx  
    mov    [cp+16], r11  
    adc    r12, rcx  
    mov    [cp+24], r12   
    adc    r13, rcx  
    mov    [cp+32], r13 
    movq   r11, 0
    adc    r11, 0 
    movq   r12, p751_5   
    and    r12, rcx
    shr    r11, 1
    adc    r14, r12
    mov    [cp+40], r14 
    adc    r11, 0 
    movq   r12, p751_6   
    and    r12, rcx
    shr    r11, 1
    adc    r15, r12
    mov    [cp+48], r15 
    adc    r11, 0 
    movq   r12, p751_7   
    and    r12, rcx
    shr    r11, 1
    adc    rax, r12
    mov    [cp+56], rax  
    adc    r11, 0 
    movq   r12, p751_8   
    and    r12, rcx
    shr    r11, 1
    adc    rdx, r12
    mov    [cp+64], rdx  
    adc    r11, 0 
    movq   r12, p751_9   
    and    r12, rcx
    shr    r11, 1
    adc    r8, r12
    mov    [cp+72], r8  
    adc    r11, 0 
    movq   r12, p751_10   
    and    r12, rcx
    shr    r11, 1
    adc    r9, r12
    mov    [cp+80], r9  
    adc    r11, 0 
    movq   r12, p751_11   
    and    r12, rcx
    shr    r11, 1
    adc    r10, r12
    mov    [cp+88], r10 


epilogue:
    // pop local storage
    add rsp, 48*8
    //add rsp, 24*8

    // pop all you used
    pop rcx
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8

    pop rbp
    // restore stack pointer
    mov rsp, rbp
    // restore base pointer
    pop rbp
    ret
