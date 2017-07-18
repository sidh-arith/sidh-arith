//*******************************************************************************************
// SIDH: an efficient supersingular isogeny-based cryptography library for Diffie-Hellman key 
//       exchange providing 128 bits of quantum security and 192 bits of classical security.
//
//    Copyright (c) Microsoft Corporation. All rights reserved.
//
//
// Abstract: field arithmetic in x64 assembly for Linux 
//
//*******************************************************************************************  

.intel_syntax noprefix 

//.data
//msg:  .string "val:    %016lx\n"
//msg2: .string "2nd:    %016lx\n"
//msg3: .string "3nd:    %016lx\n"
//msg4: .string "v_temp: %016lx\n"
//
//#define SHOW(reg) \
//    push rdi; \
//    push rsi; \
//    push rax; \
//    push rcx; \
//    push rdx; \
//    push r8; \
//    push r9; \
//    push r10; \
//    push r11; \
//    mov rax, 0; \
//    mov rsi, reg; \
//    movabsq rdi, offset msg; \
//    call printf@PLT; \
//    pop r11; \
//    pop r10; \
//    pop r9; \
//    pop r8; \
//    pop rdx; \
//    pop rcx; \
//    pop rax; \
//    pop rsi; \
//    pop rdi;
//
//#define SHOW2(reg) \
//    push rdi; \
//    push rsi; \
//    push rax; \
//    push rcx; \
//    push rdx; \
//    push r8; \
//    push r9; \
//    push r10; \
//    push r11; \
//    mov rax, 0; \
//    mov rsi, reg; \
//    movabsq rdi, offset msg2; \
//    call printf@PLT; \
//    pop r11; \
//    pop r10; \
//    pop r9; \
//    pop r8; \
//    pop rdx; \
//    pop rcx; \
//    pop rax; \
//    pop rsi; \
//    pop rdi;
//
//#define SHOW3(reg) \
//    push rdi; \
//    push rsi; \
//    push rax; \
//    push rcx; \
//    push rdx; \
//    push r8; \
//    push r9; \
//    push r10; \
//    push r11; \
//    mov rax, 0; \
//    mov rsi, reg; \
//    movabsq rdi, offset msg3; \
//    call printf@PLT; \
//    pop r11; \
//    pop r10; \
//    pop r9; \
//    pop r8; \
//    pop rdx; \
//    pop rcx; \
//    pop rax; \
//    pop rsi; \
//    pop rdi;
//
//#define SHOWTEMP() \
//    push rdi; \
//    push rsi; \
//    push rax; \
//    push rcx; \
//    push rdx; \
//    push r8; \
//    push r9; \
//    push r10; \
//    push r11; \
//    mov rax, 0; \
//    mov rsi, [rsp+72]; \
//    movabsq rdi, offset msg4; \
//    call printf@PLT; \
//    pop r11; \
//    pop r10; \
//    pop r9; \
//    pop r8; \
//    pop rdx; \
//    pop rcx; \
//    pop rax; \
//    pop rsi; \
//    pop rdi;

// Hide output for now
#define SHOW(reg)
#define SHOW2(reg)
#define SHOW3(reg)
#define SHOWTEMP()

// Registers that are used for parameter passing:
#define reg_p1  rdi
#define reg_p2  rsi
#define reg_p3  rdx

// p751 + 1
//#define p751p1_5   0xEEB0000000000000
//#define p751p1_6   0xE3EC968549F878A8
//#define p751p1_7   0xDA959B1A13F7CC76
//#define p751p1_8   0x084E9867D6EBE876
//#define p751p1_9   0x8562B5045CB25748
//#define p751p1_10  0x0E12909F97BADC66
//#define p751p1_11  0x00006FE5D541F71C

#define p751p1_5    0xc968549f878a8eeb
#define p751p1_6    0x59b1a13f7cc76e3e
#define p751p1_7    0xe9867d6ebe876da9
#define p751p1_8    0x2b5045cb25748084
#define p751p1_9    0x2909f97badc66856
#define p751p1_10   0x06fe5d541f71c0e1

#define p751_0     0xFFFFFFFFFFFFFFFF
#define p751_5     0xEEAFFFFFFFFFFFFF
#define p751_6     0xE3EC968549F878A8
#define p751_7     0xDA959B1A13F7CC76
#define p751_8     0x084E9867D6EBE876
#define p751_9     0x8562B5045CB25748
#define p751_10    0x0E12909F97BADC66
#define p751_11    0x00006FE5D541F71C

    // rbx, rcx, rbp, rsp, r8, r9, r10, r11, r12, r13, r14, r15

.text
//***********************************************************************
//  Montgomery reduction
//  Based on comba method
//  Operation: c [reg_p2] = a [reg_p1]
//  NOTE: a=c is not allowed
//*********************************************************************** 
#ifdef INTEGRATE
.global rdc_mont
rdc_mont:
#else
.global shifted_rdc_mont
shifted_rdc_mont:
#endif
    push rbp // save base pointer
    mov rbp, rsp // stack top is new base

  push   r12
  push   r13 
  push   r14 
  push   r15 
  push   rbp
  push   rbx
  //push   rcx

  //sub rsp, 24*8
  //#define A rsp

  //mov rcx, 24
  //copyloop:
  //  dec rcx
  //  movq [A + rcx*8], [reg_p1 + rcx*8]
  //  jnz zero
  sub rsp, 8
  #define v_temp rsp

  mov    r11, [reg_p1] // a_0 * pp1_5  = (!) = c_0 * pp1_5
  movq   rax, p751p1_5 
  mul    r11
  xor    r8, r8
  mov    rbp, [reg_p1+40]
  mov    rbx, [reg_p1+48]
  shrdq  rbp, rbx, 52
  add    rax, rbp // + a_5
  adc    r8, rdx

  mov    rbp, [reg_p1+40]
  shl    rbp, 12
  mov    [v_temp], rax
  shldq  rax, rbp, 52
  mov    [reg_p2+40], rax    // -> z5
  SHOW([reg_p2+40])

  xor    r9, r9
  movq   rax, p751p1_6 // a_0 * pp1_6
  mul    r11
  xor    r10, r10
  add    r8, rax
  adc    r9, rdx

  mov    r12, [reg_p1+8] // + a_1 * pp1_5
  movq   rax, p751p1_5 
  mul    r12
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0

  //add    r8, [reg_p1+48] // + a_6
  mov    rbp, [reg_p1+48]
  mov    rbx, [reg_p1+56]
  shrdq  rbp, rbx, 52
  add    r8, rbp // + a_6
  adc    r9, 0
  adc    r10, 0

  mov    rbp, [v_temp]
  mov    [v_temp], r8
  shldq  r8, rbp, 52
  mov    [reg_p2+48], r8    // -> z6
  SHOW([reg_p2+48])
  
  xor    r8, r8
  movq   rax, p751p1_7 
  mul    r11
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, p751p1_6 
  mul    r12
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  mov    r13, [reg_p1+16]
  movq   rax, p751p1_5 
  mul    r13
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  //add    r9, [reg_p1+56]
  mov    rbp, [reg_p1+56]
  mov    rbx, [reg_p1+64]
  shrdq  rbp, rbx, 52
  add    r9, rbp // + a_7
  adc    r10, 0
  adc    r8, 0

  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r9
  shldq  r9, rbp, 52

  mov    [reg_p2+56], r9    // z7
  SHOW([reg_p2+56])
  
  xor    r9, r9
  movq   rax, p751p1_8 
  mul    r11
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, p751p1_7 
  mul    r12
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, p751p1_6 
  mul    r13
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  mov    r14, [reg_p1+24]
  movq   rax, p751p1_5 
  mul    r14
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  //add    r10, [reg_p1+64]
  mov    rbp, [reg_p1+64]
  mov    rbx, [reg_p1+72]
  shrdq  rbp, rbx, 52
  add    r10, rbp // + a_8
  adc    r8, 0
  adc    r9, 0

  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r10
  shldq  r10, rbp, 52

  mov    [reg_p2+64], r10   // z8
  SHOW([reg_p2+64])
  
  xor    r10, r10
  movq   rax, p751p1_9 
  mul    r11
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, p751p1_8 
  mul    r12
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, p751p1_7 
  mul    r13
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, p751p1_6 
  mul    r14
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  mov    r15, [reg_p1+32]
  movq   rax, p751p1_5 
  mul    r15
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0

  //add    r8, [reg_p1+72]
  mov    rbp, [reg_p1+72]
  mov    rbx, [reg_p1+80]
  shrdq  rbp, rbx, 52
  add    r8, rbp // + a_9
  adc    r9, 0
  adc    r10, 0

  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r8
  shldq  r8, rbp, 52
  mov    [reg_p2+72], r8    // z9
  SHOW([reg_p2+72])
  
  xor    r8, r8
  movq   rax, p751p1_10 
  mul    r11                // pp[10]*a[0]
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, p751p1_9 
  mul    r12                // pp[9]*a[1]
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, p751p1_8 
  mul    r13                // pp[8]*a[2]
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, p751p1_7 
  mul    r14                // pp[7]*a[3]
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, p751p1_6 
  mul    r15                // pp[6]*a[4] =(!)= pp[6]*z[4]
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  mov    rcx, [reg_p2+40]
  movq   rax, p751p1_5 
  mul    rcx                // pp[5]*z[5]
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  //add    r9, [reg_p1+80]
  mov    rbp, [reg_p1+80]
  mov    rbx, [reg_p1+88]
  shrdq  rbp, rbx, 52
  add    r9, rbp // + a_10
  adc    r10, 0
  adc    r8, 0

  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r9
  shldq  r9, rbp, 52
  mov    [reg_p2+80], r9    // z10
  SHOW([reg_p2+80])
  
  xor    r9, r9
  
  movq   rax, p751p1_10 
  mul    r12
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, p751p1_9 
  mul    r13
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, p751p1_8 
  mul    r14
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, p751p1_7 
  mul    r15
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, p751p1_6 
  mul    rcx                // pp[6]*z[5]?
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  mov    r11, [reg_p2+48]
  movq   rax, p751p1_5 
  mul    r11                // pp[5]*z[6]
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0

  //add    r10, [reg_p1+88]
  mov    rbp, [reg_p1+88]
  mov    rbx, [reg_p1+96]
  shrdq  rbp, rbx, 52
  add    r10, rbp // + a_11
  adc    r8, 0
  adc    r9, 0
  
  SHOWTEMP()
  SHOW2(r10)
  SHOW2(r8)
  SHOW3(r9)
  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r10
  shldq  r10, rbp, 52
  mov    [reg_p2+88], r10    // z11
  SHOW([reg_p2+88])
  
  xor    r10, r10
  
  movq   rax, p751p1_10 
  mul    r13
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, p751p1_9 
  mul    r14
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, p751p1_8 
  mul    r15
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, p751p1_7 
  mul    rcx
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, p751p1_6 
  mul    r11
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  mov    r12, [reg_p2+56]
  movq   rax, p751p1_5 
  mul    r12                // p[5]*z[7]
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0

  //add    r8, [reg_p1+96]
  mov    rbp, [reg_p1+96]
  mov    rbx, [reg_p1+104]
  shrdq  rbp, rbx, 52
  add    r8, rbp // + a_12
  adc    r9, 0
  adc    r10, 0

  SHOWTEMP()
  SHOW2(r8)
  SHOW2(r9)
  SHOW3(r10)
  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r8
  shldq  r8, rbp, 52
  mov    [reg_p2], r8        // z0
  SHOW([reg_p2])
  
  xor    r8, r8

  movq   rax, p751p1_10 
  mul    r14
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  movq   rax, p751p1_9
  mul    r15
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  movq   rax, p751p1_8
  mul    rcx
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  movq   rax, p751p1_7
  mul    r11
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  movq   rax, p751p1_6
  mul    r12
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  mov    r13, [reg_p2+64]
  movq   rax, p751p1_5
  mul    r13
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  //add    r9, [reg_p1+104]
  mov    rbp, [reg_p1+104]
  mov    rbx, [reg_p1+112]
  shrdq  rbp, rbx, 52
  add    r9, rbp // + a_13
  adc    r10, 0
  adc    r8, 0

  SHOWTEMP()
  SHOW2(r9)
  SHOW3(r10)
  SHOW2(r8)
  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r9
  shldq  r9, rbp, 52
  mov    [reg_p2+8], r9      // z1
  SHOW([reg_p2+8])
  
  xor    r9, r9
  
  movq   rax, p751p1_10 
  mul    r15
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, p751p1_9 
  mul    rcx
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, p751p1_8 
  mul    r11
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, p751p1_7 
  mul    r12
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, p751p1_6 
  mul    r13
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  mov    r14, [reg_p2+72]
  movq   rax, p751p1_5 
  mul    r14
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0

  //add    r10, [reg_p1+112]
  mov    rbp, [reg_p1+112]
  mov    rbx, [reg_p1+120]
  shrdq  rbp, rbx, 52
  add    r10, rbp // + a_14
  adc    r8, 0
  adc    r9, 0

  SHOWTEMP()
  SHOW3(r10)
  SHOW2(r8)
  SHOW2(r9)
  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r10
  shldq  r10, rbp, 52
  mov    [reg_p2+16], r10    // z2
  SHOW([reg_p2+16])
  
  xor    r10, r10
  
  movq   rax, p751p1_10 
  mul    rcx
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, p751p1_9 
  mul    r11
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, p751p1_8 
  mul    r12
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, p751p1_7 
  mul    r13
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, p751p1_6 
  mul    r14
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  mov    r15, [reg_p2+80]
  movq   rax, p751p1_5 
  mul    r15
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0

  //add    r8, [reg_p1+120]
  mov    rbp, [reg_p1+120]
  mov    rbx, [reg_p1+128]
  shrdq  rbp, rbx, 52
  add    r8, rbp // + a_15
  adc    r9, 0
  adc    r10, 0

  SHOWTEMP()
  SHOW2(r8)
  SHOW2(r9)
  SHOW3(r10)
  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r8
  shldq  r8, rbp, 52
  mov    [reg_p2+24], r8     // z3
  SHOW([reg_p2+24])
  
  xor    r8, r8
  
  movq   rax, p751p1_10 
  mul    r11
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, p751p1_9 
  mul    r12
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, p751p1_8 
  mul    r13
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, p751p1_7 
  mul    r14
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, p751p1_6 
  mul    r15
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  mov    rcx, [reg_p2+88]
  movq   rax, p751p1_5 
  mul    rcx
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  //add    r9, [reg_p1+128]
  mov    rbp, [reg_p1+128]
  mov    rbx, [reg_p1+136]
  shrdq  rbp, rbx, 52
  add    r9, rbp // + a_16
  adc    r10, 0
  adc    r8, 0

  SHOWTEMP()
  SHOW2(r9)
  SHOW3(r10)
  SHOW2(r8)
  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r9
  shldq  r9, rbp, 52
  mov    [reg_p2+32], r9     // z4
  SHOW([reg_p2+32])
  
  xor    r9, r9
  
  movq   rax, p751p1_10 
  mul    r12
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, p751p1_9 
  mul    r13
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, p751p1_8 
  mul    r14
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, p751p1_7 
  mul    r15
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, p751p1_6 
  mul    rcx
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0

  //add    r10, [reg_p1+136]
  mov    rbp, [reg_p1+136]
  mov    rbx, [reg_p1+144]
  shrdq  rbp, rbx, 52
  add    r10, rbp // + a_17
  adc    r8, 0
  adc    r9, 0

  SHOWTEMP()
  SHOW3(r10)
  SHOW2(r8)
  SHOW2(r9)
  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r10
  shldq  r10, rbp, 52
  mov    [reg_p2+40], r10    // z5
  SHOW([reg_p2+40])
  
  xor    r10, r10
  
  movq   rax, p751p1_10 
  mul    r13
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, p751p1_9 
  mul    r14
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, p751p1_8 
  mul    r15
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, p751p1_7 
  mul    rcx
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0

  //add    r8, [reg_p1+144]
  mov    rbp, [reg_p1+144]
  mov    rbx, [reg_p1+152]
  shrdq  rbp, rbx, 52
  add    r8, rbp // + a_18
  adc    r9, 0
  adc    r10, 0

  SHOWTEMP()
  SHOW2(r8)
  SHOW2(r9)
  SHOW3(r10)
  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r8
  shldq  r8, rbp, 52
  mov    [reg_p2+48], r8     // z6
  SHOW([reg_p2+48])
  
  xor    r8, r8
  
  movq   rax, p751p1_10 
  mul    r14
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, p751p1_9 
  mul    r15
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, p751p1_8 
  mul    rcx
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  //add    r9, [reg_p1+152]
  mov    rbp, [reg_p1+152]
  mov    rbx, [reg_p1+160]
  shrdq  rbp, rbx, 52
  add    r9, rbp // + a_19
  adc    r10, 0
  adc    r8, 0

  SHOWTEMP()
  SHOW2(r9)
  SHOW3(r10)
  SHOW2(r8)
  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r9
  shldq  r9, rbp, 52
  mov    [reg_p2+56], r9     // z7
  SHOW([reg_p2+56])
  
  xor    r9, r9
  
  movq   rax, p751p1_10 
  mul    r15
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, p751p1_9 
  mul    rcx
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0

  //add    r10, [reg_p1+160]
  mov    rbp, [reg_p1+160]
  mov    rbx, [reg_p1+168]
  shrdq  rbp, rbx, 52
  add    r10, rbp // + a_20
  adc    r8, 0
  adc    r9, 0

  SHOWTEMP()
  SHOW2(r9)
  SHOW3(r10)
  SHOW2(r8)
  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r10
  shldq  r10, rbp, 52
  mov    [reg_p2+64], r10    // z8
  SHOW([reg_p2+64])
  
  xor    r10, r10

  movq   rax, p751p1_10 
  mul    rcx
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0

  //add    r8, [reg_p1+168]
  mov    rbp, [reg_p1+168]
  mov    rbx, [reg_p1+176]
  shrdq  rbp, rbx, 52
  add    r8, rbp // + a_21
  adc    r9, 0
  adc    r10, 0

  SHOWTEMP()
  SHOW3(r10)
  SHOW2(r8)
  SHOW2(r9)
  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r8
  shldq  r8, rbp, 52 // z9
  SHOW(r8)
  
  //add    r9, [reg_p1+176]
  mov    rbp, [reg_p1+176]
  mov    rbx, [reg_p1+184]
  shrdq  rbp, rbx, 52
  add    r9, rbp // + a_22
  adc    r10, 0

  SHOWTEMP()
  SHOW2(r9)
  SHOW3(r10)
  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r9
  shldq  r9, rbp, 52 // z10
  SHOW(r9)

  //add    r10, [reg_p1+184]
  mov    rbp, [reg_p1+184]
  mov    rbx, [reg_p1+192]
  shrdq  rbp, rbx, 52
  add    r10, rbp // + a_23

  SHOWTEMP()
  SHOW3(r10)
  mov    rbp, [v_temp]      // shift output back
  mov    [v_temp], r10
  shldq  r10, rbp, 52 // z11
  SHOW(r10)
  
// Final, constant-time correction
  mov    rax, [reg_p2]
  movq   rcx, p751_0  
  sub    rax, rcx 
  mov    [reg_p2], rax
  mov    rax, [reg_p2+8]
  sbb    rax, rcx 
  mov    [reg_p2+8], rax
  mov    rax, [reg_p2+16]
  sbb    rax, rcx
  mov    [reg_p2+16], rax
  mov    r12, [reg_p2+24]
  sbb    r12, rcx
  mov    r13, [reg_p2+32]
  sbb    r13, rcx
  mov    r14, [reg_p2+40]
  movq   rcx, p751_5  
  sbb    r14, rcx
  mov    r15, [reg_p2+48]
  movq   rcx, p751_6  
  sbb    r15, rcx
  mov    rax, [reg_p2+56]
  movq   rcx, p751_7  
  sbb    rax, rcx
  mov    rdx, [reg_p2+64]
  movq   rcx, p751_8  
  sbb    rdx, rcx
  movq   rcx, p751_9  
  sbb    r8, rcx
  movq   rcx, p751_10  
  sbb    r9, rcx
  movq   rcx, p751_11  
  sbb    r10, rcx
  movq   rcx, 0
  sbb    rcx, 0
  
  movq   r11, p751_0  
  and    rcx, r11
  mov    r11, [reg_p2]
  add    r11, rcx  
  mov    [reg_p2], r11  
  mov    r11, [reg_p2+8]
  adc    r11, rcx  
  mov    [reg_p2+8], r11  
  mov    r11, [reg_p2+16]
  adc    r11, rcx  
  mov    [reg_p2+16], r11  
  adc    r12, rcx  
  mov    [reg_p2+24], r12   
  adc    r13, rcx  
  mov    [reg_p2+32], r13 
  movq   r11, 0
  adc    r11, 0 
  movq   r12, p751_5   
  and    r12, rcx
  shr    r11, 1
  adc    r14, r12
  mov    [reg_p2+40], r14 
  adc    r11, 0 
  movq   r12, p751_6   
  and    r12, rcx
  shr    r11, 1
  adc    r15, r12
  mov    [reg_p2+48], r15 
  adc    r11, 0 
  movq   r12, p751_7   
  and    r12, rcx
  shr    r11, 1
  adc    rax, r12
  mov    [reg_p2+56], rax  
  adc    r11, 0 
  movq   r12, p751_8   
  and    r12, rcx
  shr    r11, 1
  adc    rdx, r12
  mov    [reg_p2+64], rdx  
  adc    r11, 0 
  movq   r12, p751_9   
  and    r12, rcx
  shr    r11, 1
  adc    r8, r12
  mov    [reg_p2+72], r8  
  adc    r11, 0 
  movq   r12, p751_10   
  and    r12, rcx
  shr    r11, 1
  adc    r9, r12
  mov    [reg_p2+80], r9  
  adc    r11, 0 
  movq   r12, p751_11   
  and    r12, rcx
  shr    r11, 1
  adc    r10, r12
  mov    [reg_p2+88], r10 
  
epilogue:
  add rsp, 8

  pop    rbx
  pop    rbp
  pop    r15
  pop    r14
  pop    r13
  pop    r12

    mov rsp, rbp // restore stack pointer
    pop rbp // restore base pointer
  ret
