// vim: set ft=asm foldmethod=marker:
.intel_syntax noprefix 

#define reg_p1 rdi
#define reg_p2 rsi
#define reg_p3 rdx
#define reg_p4 rcx

.text

#ifdef INTEGRATE
.global rdc_mont
rdc_mont:
#else
.global doublelimb_asm_rdc_mont
doublelimb_asm_rdc_mont:
#endif

prologue:
    push rbp // save base pointer
    mov rbp, rsp // stack top is new base
    push rbp // save base pointer

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

    //// mp_limb_t t1[24] = {0}
    //sub rsp, 24*8
    //// mp_limb_t A[24];
    //sub rsp, 24*8
    //#define t1 rsp+24*8
    //#define A rsp

    //mov rcx, 24
    //zero:
    //    //movq [rsp+rcx*8], 0xffffffffffffffff
    //    dec rcx
    //    //movq [A + rcx*8], 0
    //    movq [t1 + rcx*8], 0
    //    jnz zero

#define reg_p1 rdi
#define reg_p2 rsi
#define reg_p3 rdx
#define reg_p4 rcx

#define p rdi
#define z rsi

#define temp1 r8
#define t0 r9 
#define t1 r10
#define u0 r11
#define u1 r12
#define v0 r13
#define v1 r14
#define z2_0 r15
#define z2_1 rbx
#define z3_0 rcx
#define z3_1 rbp

#define n2_1 0xeeb0000000000000
#define n3_0 0xe3ec968549f878a8
#define n3_1 0xda959b1a13f7cc76
#define n4_0 0x084e9867d6ebe876
#define n4_1 0x8562b5045cb25748
#define n5_0 0x0e12909f97badc66
#define n5_1 0x00006fe5d541f71c

#define p751_0     0xFFFFFFFFFFFFFFFF
#define p751_5     0xEEAFFFFFFFFFFFFF
#define p751_6     0xE3EC968549F878A8
#define p751_7     0xDA959B1A13F7CC76
#define p751_8     0x084E9867D6EBE876
#define p751_9     0x8562B5045CB25748
#define p751_10    0x0E12909F97BADC66
#define p751_11    0x00006FE5D541F71C

actualcode:

// +-------+
// | i = 2 |
// +-------+

xor t0, t0
xor t1, t1
xor u0, u0
xor u1, u1
xor v0, v0
xor v1, v1

// (u, v) = p[0] * n[2]     // special mul
// (u, v) = (u, v) + p[2]
// z[2] = v;

// LINE 1
// (u, v) = p[0] * n[2]     // special mul

mov temp1, [p]

mov rax, n2_1
mul temp1
add v1, rax
adc u0, rdx
adc u1, 0

mov temp1, [p+8]

mov rax, n2_1
mul temp1
add u0, rax
adc u1, rdx

// LINE 2
// (u, v) = (u, v) + p[2]

add v0, [p+8*2*2]
adc v1, [p+8*2*2+8]
adc u0, 0
adc u1, 0

// LINE 3
// z[2] = v;

//mov [z+8*2*2], v0
//mov [z+8*2*2+8], v1
mov z2_0, v0
mov z2_1, v1

// +-------+
// | i = 3 |
// +-------+

xor v0, v0
xor v1, v1

// (u, v) = p[3] + u + p[0] * n[3]
// (t, u, v) = (u, v) + p[1] * n[2] // special mul
// z[3] = v;

// LINE 1
// (u, v) = p[3] + u + p[0] * n[3]

// multiply p[0] * n[3]
mov temp1, [p]
mov rax, n3_0
mul temp1
add u0, rax
adc u1, rdx
adc t0, 0

mov rax, n3_1
mul temp1
add u1, rax
adc t0, rdx
adc t1, 0

mov temp1, [p+8]
mov rax, n3_0
mul temp1
add u1, rax
adc t0, rdx
adc t1, 0

mov rax, n3_1
mul temp1
add t0, rax
adc t1, rdx

// and add p[3]
add u0, [p+8*2*3]
adc u1, [p+8*2*3+8]
adc t0, 0
adc t1, 0

// LINE 2
// (t, u, v) = (u, v) + p[1] * n[2] // special mul

mov temp1, [p+8*2*1]

mov rax, n2_1
mul temp1
add u1, rax
adc t0, rdx
adc t1, 0
adc v0, 0

mov temp1, [p+8*2*1+8]

mov rax, n2_1
mul temp1
add t0, rax
adc t1, rdx
adc v0, 0

// LINE 3
// z[3] = v;

mov z3_0, u0
mov z3_1, u1

// +-------+
// | i = 4 |
// +-------+

xor u0, u0
xor u1, u1

// (u, v) = (t, u) + (p[0] * n[4] + p[4]) // No output t due to n[4] (constant) 
// (t, u, v) = (u, v) + p[1] * n[3]
// (t, u, v) += z[2] * n[2] // special mul
// z[4] = v;

// LINE 1
// (u, v) = (t, u) + (p[0] * n[4] + p[4]) // No output t due to n[4] (constant) 

// multiply p[0] * n[4]
mov temp1, [p]
mov rax, n4_0
mul temp1
add t0, rax
adc t1, rdx
adc v0, 0

mov rax, n4_1
mul temp1
add t1, rax
adc v0, rdx
adc v1, 0

mov temp1, [p+8]
mov rax, n4_0
mul temp1
add t1, rax
adc v0, rdx
adc v1, 0

mov rax, n4_1
mul temp1
add v0, rax
adc v1, rdx

// and add p[4]
add t0, [p+8*2*4]
adc t1, [p+8*2*4+8]
adc v0, 0
adc v1, 0

// LINE 2
// (t, u, v) = (u, v) + p[1] * n[3]

mov temp1, [p+8*2*1]
mov rax, n3_0
mul temp1
add t0, rax
adc t1, rdx
adc v0, 0
adc v1, 0
adc u0, 0

mov rax, n3_1
mul temp1
add t1, rax
adc v0, rdx
adc v1, 0
adc u0, 0

mov temp1, [p+8*2*1+8]
mov rax, n3_0
mul temp1
add t1, rax
adc v0, rdx
adc v1, 0
adc u0, 0

mov rax, n3_1
mul temp1
add v0, rax
adc v1, rdx
adc u0, 0

// LINE 3
// (t, u, v) += z[2] * n[2] // special mul

//mov temp1, [z+8*2*2]
mov rax, n2_1
mul z2_0
add t1, rax
adc v0, rdx
adc v1, 0
adc u0, 0

//mov temp1, [z+8*2*2+8]
mov rax, n2_1
mul z2_1
add v0, rax
adc v1, rdx
adc u0, 0

// LINE 4
// z[4] = v;

mov [z+8*2*4], t0
mov [z+8*2*4+8], t1

// +-------+
// | i = 5 |
// +-------+

xor t0, t0
xor t1, t1

// (u, v) = (u, v) + (p[0] * n[5] + p[5]) // <-- 128+delta + (239 + 128)
// (t, u, v) = (u, v) + p[1] * n[4]
// (t, u, v) += z[2] * n[3] 
// (t, u, v) += z[3] * n[2] // special mul
// z[5] = v;

// LINE 1
// (u, v) = (u, v) + (p[0] * n[5] + p[5]) // <-- 128+delta + (239 + 128)

// multiply p[0] * n[5]
mov temp1, [p]
mov rax, n5_0
mul temp1
add v0, rax
adc v1, rdx
adc u0, 0

mov rax, n5_1
mul temp1
add v1, rax
adc u0, rdx
adc u1, 0

mov temp1, [p+8]
mov rax, n5_0
mul temp1
add v1, rax
adc u0, rdx
adc u1, 0

mov rax, n5_1
mul temp1
add u0, rax
adc u1, rdx

// and add p[5]
add v0, [p+8*2*5]
adc v1, [p+8*2*5+8]
adc u0, 0
adc u1, 0

// LINE 2
// (t, u, v) = (u, v) + p[1] * n[4]

mov temp1, [p+8*2*1]
mov rax, n4_0
mul temp1
add v0, rax
adc v1, rdx
adc u0, 0
adc u1, 0
adc t0, 0

mov rax, n4_1
mul temp1
add v1, rax
adc u0, rdx
adc u1, 0
adc t0, 0

mov temp1, [p+8*2*1+8]
mov rax, n4_0
mul temp1
add v1, rax
adc u0, rdx
adc u1, 0
adc t0, 0

mov rax, n4_1
mul temp1
add u0, rax
adc u1, rdx
adc t0, 0

// LINE 3
// (t, u, v) += z[2] * n[3] 

//mov temp1, [z+8*2*2]
mov rax, n3_0
mul z2_0
add v0, rax
adc v1, rdx
adc u0, 0
adc u1, 0
adc t0, 0

mov rax, n3_1
mul z2_0
add v1, rax
adc u0, rdx
adc u1, 0
adc t0, 0

//mov temp1, [z+8*2*2+8]
mov rax, n3_0
mul z2_1
add v1, rax
adc u0, rdx
adc u1, 0
adc t0, 0

mov rax, n3_1
mul z2_1
add u0, rax
adc u1, rdx
adc t0, 0

// LINE 4
// (t, u, v) += z[3] * n[2] // special mul

mov rax, n2_1
mul z3_0
add v1, rax
adc u0, rdx
adc u1, 0
adc t0, 0

mov rax, n2_1
mul z3_1
add u0, rax
adc u1, rdx
adc t0, 0

// LINE 5
// z[5] = v;

mov [z+8*2*5], v0
mov [z+8*2*5+8], v1

// +-------+
// | i = 6 |
// +-------+

xor v0, v0
xor v1, v1

// LINE 1 -- modified so that t, u stay in place
//(t, u) = (t, u) + (p[1] * n[5] + p[6])  // <-- 128+delta + (239 + 128)

// multiply p[1] * n[5]
mov temp1, [p+8*2*1]
mov rax, n5_0
mul temp1
add u0, rax
adc u1, rdx
adc t0, 0

mov rax, n5_1
mul temp1
add u1, rax
adc t0, rdx
adc t1, 0

mov temp1, [p+8*2*1+8]
mov rax, n5_0
mul temp1
add u1, rax
adc t0, rdx
adc t1, 0

mov rax, n5_1
mul temp1
add t0, rax
adc t1, rdx

// and add p[6]
add u0, [p+8*2*6]
adc u1, [p+8*2*6+8]
adc t0, 0
adc t1, 0

// LINE 2
// again modified tuv->vtu
//(v, t, u) = (t, u) + z[2] * n[4]

// multiply z[2] * n[4]
//mov temp1, [z+8*2*2]
mov rax, n4_0
mul z2_0
add u0, rax
adc u1, rdx
adc t0, 0
adc t1, 0
adc v0, 0

mov rax, n4_1
mul z2_0
add u1, rax
adc t0, rdx
adc t1, 0
adc v0, 0

//mov temp1, [z+8*2*2+8]
mov rax, n4_0
mul z2_1
add u1, rax
adc t0, rdx
adc t1, 0
adc v0, 0

mov rax, n4_1
mul z2_1
add t0, rax
adc t1, rdx
adc v0, 0

// LINE 3
//(t, u, v) += z[3] * n[3]

// multiply z[3] * n[3]
mov rax, n3_0
mul z3_0
add u0, rax
adc u1, rdx
adc t0, 0
adc t1, 0
adc v0, 0

mov rax, n3_1
mul z3_0
add u1, rax
adc t0, rdx
adc t1, 0
adc v0, 0

mov rax, n3_0
mul z3_1
add u1, rax
adc t0, rdx
adc t1, 0
adc v0, 0

mov rax, n3_1
mul z3_1
add t0, rax
adc t1, rdx
adc v0, 0

// LINE 4
//(t, u, v) += z[4] * n[2] // special mul

// just multiply z[4] * n[2]
mov temp1, [z+8*2*4]

mov rax, n2_1
mul temp1
add u1, rax
adc t0, rdx
adc t1, 0
adc v0, 0

mov temp1, [z+8*2*4+8]

mov rax, n2_1
mul temp1
add t0, rax
adc t1, rdx
adc v0, 0

// LINE 5
//z[0] = v;
mov [z], u0
mov [z+8], u1

// +-------+
// | i = 7 |
// +-------+

xor u0, u0
xor u1, u1

// (u, v) = (t, u) + (z[2] * n[5] + p[7])  // <-- 128+delta + (239 + 128)
// (t, u, v) = (u, v) + z[3] * n[4]
// (t, u, v) += z[4] * n[3]
// (t, u, v) += z[5] * n[2] // special mul
// z[1] = v;

// LINE 1
// (u, v) = (t, u) + (z[2] * n[5] + p[7])  // <-- 128+delta + (239 + 128)

// multiply z[2] * n[5]
//mov temp1, [z+8*2*2]
mov rax, n5_0
mul z2_0
add t0, rax
adc t1, rdx
adc v0, 0

mov rax, n5_1
mul z2_0
add t1, rax
adc v0, rdx
adc v1, 0

//mov temp1, [z+8*2*2+8]
mov rax, n5_0
mul z2_1
add t1, rax
adc v0, rdx
adc v1, 0

mov rax, n5_1
mul z2_1
add v0, rax
adc v1, rdx

// and add p[7]
add t0, [p+8*2*7]
adc t1, [p+8*2*7+8]
adc v0, 0
adc v1, 0

// LINE 2
// (t, u, v) = (u, v) + z[3] * n[4]

mov rax, n4_0
mul z3_0
add t0, rax
adc t1, rdx
adc v0, 0
adc v1, 0
adc u0, 0

mov rax, n4_1
mul z3_0
add t1, rax
adc v0, rdx
adc v1, 0
adc u0, 0

mov rax, n4_0
mul z3_1
add t1, rax
adc v0, rdx
adc v1, 0
adc u0, 0

mov rax, n4_1
mul z3_1
add v0, rax
adc v1, rdx
adc u0, 0

// LINE 3
// (t, u, v) += z[4] * n[3]

mov temp1, [z+8*2*4]
mov rax, n3_0
mul temp1
add t0, rax
adc t1, rdx
adc v0, 0
adc v1, 0
adc u0, 0

mov rax, n3_1
mul temp1
add t1, rax
adc v0, rdx
adc v1, 0
adc u0, 0

mov temp1, [z+8*2*4+8]
mov rax, n3_0
mul temp1
add t1, rax
adc v0, rdx
adc v1, 0
adc u0, 0

mov rax, n3_1
mul temp1
add v0, rax
adc v1, rdx
adc u0, 0

// LINE 4
// (t, u, v) += z[5] * n[2] // special mul

mov temp1, [z+8*2*5]

mov rax, n2_1
mul temp1
add t1, rax
adc v0, rdx
adc v1, 0
adc u0, 0

mov temp1, [z+8*2*5+8]

mov rax, n2_1
mul temp1
add v0, rax
adc v1, rdx
adc u0, 0

// LINE 5
// z[1] = v;

mov [z+8*2*1], t0
mov [z+8*2*1+8], t1

// +-------+
// | i = 8 |
// +-------+

xor t0, t0
xor t1, t1

// (u, v) = (t, u) + (z[3] * n[5]+p[8])  // <-- 128+delta + (239 + 128)
// (t, u, v) = (u, v) + z[4] * n[4]
// (t, u, v) += z[5] * n[3]
// z[2] = v;

// LINE 1
// (u, v) = (t, u) + (z[3] * n[5]+p[8])  // <-- 128+delta + (239 + 128)

// multiply z[3] * n[5]
mov rax, n5_0
mul z3_0
add v0, rax
adc v1, rdx
adc u0, 0

mov rax, n5_1
mul z3_0
add v1, rax
adc u0, rdx
adc u1, 0

mov rax, n5_0
mul z3_1
add v1, rax
adc u0, rdx
adc u1, 0

mov rax, n5_1
mul z3_1
add u0, rax
adc u1, rdx

// and add p[8]
add v0, [p+8*2*8]
adc v1, [p+8*2*8+8]
adc u0, 0
adc u1, 0

// LINE 2
// (t, u, v) = (u, v) + z[4] * n[4]

mov temp1, [z+8*2*4]
mov rax, n4_0
mul temp1
add v0, rax
adc v1, rdx
adc u0, 0
adc u1, 0
adc t0, 0

mov rax, n4_1
mul temp1
add v1, rax
adc u0, rdx
adc u1, 0
adc t0, 0

mov temp1, [z+8*2*4+8]
mov rax, n4_0
mul temp1
add v1, rax
adc u0, rdx
adc u1, 0
adc t0, 0

mov rax, n4_1
mul temp1
add u0, rax
adc u1, rdx
adc t0, 0

// LINE 3
// (t, u, v) += z[5] * n[3]

mov temp1, [z+8*2*5]
mov rax, n3_0
mul temp1
add v0, rax
adc v1, rdx
adc u0, 0
adc u1, 0
adc t0, 0

mov rax, n3_1
mul temp1
add v1, rax
adc u0, rdx
adc u1, 0
adc t0, 0

mov temp1, [z+8*2*5+8]
mov rax, n3_0
mul temp1
add v1, rax
adc u0, rdx
adc u1, 0
adc t0, 0

mov rax, n3_1
mul temp1
add u0, rax
adc u1, rdx
adc t0, 0

// LINE 4
// z[2] = v;

mov [z+8*2*2], v0
mov [z+8*2*2+8], v1

// +-------+
// | i = 9 |
// +-------+

xor v0, v0
xor v1, v1

// (u, v) = (t, u) + (z[4] * n[5]+p[9])  // <-- 128+delta + (239 + 128)
// (t, u, v) = (u, v) + z[5] * n[4]
// z[3] = v;

// LINE 1
// (u, v) = (t, u) + (z[4] * n[5]+p[9])  // <-- 128+delta + (239 + 128)

// multiply z[4] * n[5]
mov temp1, [z+8*2*4]
mov rax, n5_0
mul temp1
add u0, rax
adc u1, rdx
adc t0, 0

mov rax, n5_1
mul temp1
add u1, rax
adc t0, rdx
adc t1, 0

mov temp1, [z+8*2*4+8]
mov rax, n5_0
mul temp1
add u1, rax
adc t0, rdx
adc t1, 0

mov rax, n5_1
mul temp1
add t0, rax
adc t1, rdx

// and add p[9]
add u0, [p+8*2*9]
adc u1, [p+8*2*9+8]
adc t0, 0
adc t1, 0

// LINE 2
// (t, u, v) = (u, v) + z[5] * n[4]

mov temp1, [z+8*2*5]
mov rax, n4_0
mul temp1
add u0, rax
adc u1, rdx
adc t0, 0
adc t1, 0
adc v0, 0

mov rax, n4_1
mul temp1
add u1, rax
adc t0, rdx
adc t1, 0
adc v0, 0

mov temp1, [z+8*2*5+8]
mov rax, n4_0
mul temp1
add u1, rax
adc t0, rdx
adc t1, 0
adc v0, 0

mov rax, n4_1
mul temp1
add t0, rax
adc t1, rdx
adc v0, 0

// LINE 3
// z[3] = v;

mov [z+8*2*3], u0
mov [z+8*2*3+8], u1

// +--------+
// | i = 10 |
// +--------+

xor u0, u0
xor u1, u1

// (u, v) = (t, u) + (z[5] * n[5]+p[10])  // <-- 128+delta + (239 + 128)
// z[4] = v;
// z[5] = u + p[11]

// LINE 1
// (u, v) = (t, u) + (z[5] * n[5]+p[10])  // <-- 128+delta + (239 + 128)

// multiply z[4] * n[5]
mov temp1, [z+8*2*5]
mov rax, n5_0
mul temp1
add t0, rax
adc t1, rdx
adc v0, 0

mov rax, n5_1
mul temp1
add t1, rax
adc v0, rdx
adc v1, 0

mov temp1, [z+8*2*5+8]
mov rax, n5_0
mul temp1
add t1, rax
adc v0, rdx
adc v1, 0

mov rax, n5_1
mul temp1
add v0, rax
adc v1, rdx

// and add p[10]
add t0, [p+8*2*10]
adc t1, [p+8*2*10+8]
adc v0, 0
adc v1, 0

// LINE 2
// z[4] = v;

mov [z+8*2*4], t0
mov [z+8*2*4+8], t1

// LINE 3
// z[5] = u + p[11]

add v0, [p+8*2*11]
adc v1, [p+8*2*11+8]
mov [z+8*2*5], v0
mov [z+8*2*5+8], v1


    #define cp rsi

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
    //// pop local storage
    //add rsp, 48*8
    ////add rsp, 24*8

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
