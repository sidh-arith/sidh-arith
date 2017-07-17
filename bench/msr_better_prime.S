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

// Registers that are used for parameter passing:
#define reg_p1  rdi
#define reg_p2  rsi
#define reg_p3  rdx

#define newp_0     0xFFFFFFFFFFFFFFFF
#define newp_6     0x3e31bcfdf223307f
#define newp_7     0xdc45cb1358110f86
#define newp_8     0xb61b2613a4ec956d
#define newp_9     0x545ff2ae1094c89e
#define newp_10    0xef8e9de28b31ae8b
#define newp_11    0x1c33308ae5911ef8

#define newpp1_0   0x0
#define newpp1_5   0x0
#define newpp1_6   0x3e31bcfdf2233080
#define newpp1_7   0xdc45cb1358110f86
#define newpp1_8   0xb61b2613a4ec956d
#define newpp1_9   0x545ff2ae1094c89e
#define newpp1_10  0xef8e9de28b31ae8b
#define newpp1_11  0x1c33308ae5911ef8


.text
//***********************************************************************
//  Montgomery reduction
//  Based on comba method
//  Operation: c [reg_p2] = a [reg_p1]
//  NOTE: a=c is not allowed
//*********************************************************************** 
.global rdcnewp
rdcnewp:
  push   r12
  push   r13 
  push   r14 
  push   r15 

//   i = 6
//   tuv += c_0 * p_6     // (1)
//   tuv += a_6
//   c_6 = v
  mov    r11, [reg_p1] // a_0
  movq   rax, newpp1_6 
  mul    r11
  xor    r8, r8
  add    rax, [reg_p1+48] // + a_6
  mov    [reg_p2+48], rax    // -> z6
  adc    r8, rdx
  
//   i = 7
//   tuv += c_0 * p_7     // (1)
//   tuv += c_1 * p_6     // (2)
//   tuv += a_7
//   c_7 = v
  xor    r9, r9
  movq   rax, newpp1_7 // a_0 * pp1_7
  mul    r11
  xor    r10, r10
  add    r8, rax
  adc    r9, rdx

  mov    r12, [reg_p1+8] // + a_1 * pp1_6
  movq   rax, newpp1_6 
  mul    r12
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  add    r8, [reg_p1+56] // + a_7
  mov    [reg_p2+56], r8    // -> z7
  adc    r9, 0
  adc    r10, 0

//   i = 8
//   tuv += c_0 * p_8     // (1)
//   tuv += c_1 * p_7     // (2)
//   tuv += c_2 * p_6     // (3)
//   tuv += a_8
//   c_8 = v
  xor    r8, r8
  movq   rax, newpp1_8
  mul    r11 // a_0 * p_8
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, newpp1_7
  mul    r12 // a_1 * p_7
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  mov    r13, [reg_p1+16] // a_2
  movq   rax, newpp1_6
  mul    r13 // a_2 * p_6
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  add    r9, [reg_p1+64] // + a_8
  mov    [reg_p2+64], r9    // z8
  adc    r10, 0
  adc    r8, 0
  
//   i = 9
//   tuv += c_0 * p_9     // (1)
//   tuv += c_1 * p_8     // (2)
//   tuv += c_2 * p_7     // (3)
//   tuv += c_3 * p_6     // (4)
//   tuv += a_9
//   c_9 = v
  xor    r9, r9
  movq   rax, newpp1_9
  mul    r11 // a_0 * p_9
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, newpp1_8
  mul    r12 // a_1 * p_8
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, newpp1_7
  mul    r13 // a_2 * p_7
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  mov    r14, [reg_p1+24] // a_3
  movq   rax, newpp1_6
  mul    r14 // a_3 * p_6
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0

  add    r10, [reg_p1+72] // + a_9
  mov    [reg_p2+72], r10   // z9
  adc    r8, 0
  adc    r9, 0
  
//   i = 10
//   tuv += c_0 * p_10     // (1)
//   tuv += c_1 * p_9     // (2)
//   tuv += c_2 * p_8     // (3)
//   tuv += c_3 * p_7     // (4)
//   tuv += c_4 * p_6     // (5)
//   tuv += a_10
//   c_10 = v
  xor    r10, r10
  movq   rax, newpp1_10
  mul    r11 // a_0 * p_10
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, newpp1_9
  mul    r12 // a_1 * p_9
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, newpp1_8
  mul    r13 // a_2 * p_8
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, newpp1_7
  mul    r14 // a_3 * p_7
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  mov    r15, [reg_p1+32] // a_4
  movq   rax, newpp1_6
  mul    r15 // a_4 * p_6
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  add    r8, [reg_p1+80] // + a_10
  mov    [reg_p2+80], r8    // z10
  adc    r9, 0
  adc    r10, 0

//   i = 11
//   tuv += c_0 * p_11     // (1)
//   tuv += c_1 * p_10     // (2)
//   tuv += c_2 * p_9     // (3)
//   tuv += c_3 * p_8     // (4)
//   tuv += c_4 * p_7     // (5)
//   tuv += c_5 * p_6     // (6)
//   tuv += a_11
//   c_11 = v
  xor    r8, r8
  movq   rax, newpp1_11
  mul    r11 // a_0 * p_11
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, newpp1_10
  mul    r12 // a_1 * p_10
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, newpp1_9
  mul    r13 // a_2 * p_9
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, newpp1_8
  mul    r14 // a_3 * p_8
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, newpp1_7
  mul    r15 // a_4 * p_7
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  mov    rcx, [reg_p1+40] // a_5
  movq   rax, newpp1_6
  mul    rcx // a_5 * p_6
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  add    r9, [reg_p1+88] // + a_11
  mov    [reg_p2+88], r9    // z11
  adc    r10, 0
  adc    r8, 0
  
     mov r9, r8
     mov r8, r10
     mov r10, r9
  
  //xor    r9, r9
  //movq   rax, newpp1_11 
  //mul    r11
  //add    r10, rax
  //adc    r8, rdx
  //adc    r9, 0
  //
  //movq   rax, newpp1_10 
  //mul    r12
  //add    r10, rax
  //adc    r8, rdx
  //adc    r9, 0
  //
  //movq   rax, newpp1_9 
  //mul    r13
  //add    r10, rax
  //adc    r8, rdx
  //adc    r9, 0
  //
  //movq   rax, newpp1_8 
  //mul    r14
  //add    r10, rax
  //adc    r8, rdx
  //adc    r9, 0
  //
  //movq   rax, newpp1_7 
  //mul    r15
  //add    r10, rax
  //adc    r8, rdx
  //adc    r9, 0
  //
  //movq   rax, newpp1_6 
  //mul    rcx
  //add    r10, rax
  //adc    r8, rdx
  //adc    r9, 0
  //
  //mov    r11, [reg_p2+48]
  //movq   rax, newpp1_5 
  //mul    r11
  //add    r10, rax
  //adc    r8, rdx
  //adc    r9, 0
  //add    r10, [reg_p1+88]
  //mov    [reg_p2+88], r10    // z11
  //adc    r8, 0
  //adc    r9, 0
  
//   ===== SECOND PART =====

//   i = 12
//   tuv += c_1 * p_11     // (1)
//   tuv += c_2 * p_10     // (2)
//   tuv += c_3 * p_9     // (3)
//   tuv += c_4 * p_8     // (4)
//   tuv += c_5 * p_7     // (5)
//   tuv += c_6 * p_6     // (6)
//   tuv += a_12
//   c_0 = v
  xor    r10, r10
  movq   rax, newpp1_11 
  mul    r12 // a_1 * p_11
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, newpp1_10
  mul    r13 // a_2 * p_10
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, newpp1_9 
  mul    r14 // a_3 * p_9
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, newpp1_8 
  mul    r15 // a_4 * p_8
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, newpp1_7 
  mul    rcx // a_5 * 7
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  mov    r11, [reg_p2+48]
  movq   rax, newpp1_6
  mul    r11 // c_6 * p_6
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0

  add    r8, [reg_p1+96] // + a_12
  mov    [reg_p2], r8        // z0
  adc    r9, 0
  adc    r10, 0
  
//   i = 13
//   tuv += c_2 * p_11     // (1)
//   tuv += c_3 * p_10     // (2)
//   tuv += c_4 * p_9     // (3)
//   tuv += c_5 * p_8     // (4)
//   tuv += c_6 * p_7     // (5)
//   tuv += c_7 * p_6     // (6)
//   tuv += a_13
//   c_1 = v
  xor    r8, r8
  movq   rax, newpp1_11 
  mul    r13 // a_2 * p_11
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  movq   rax, newpp1_10 
  mul    r14 // a_3 * p10
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  movq   rax, newpp1_9
  mul    r15 // a_4 * p_9
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  movq   rax, newpp1_8
  mul    rcx // a_5 * p_8
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  movq   rax, newpp1_7
  mul    r11 // c_6 * p_7
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  mov    r12, [reg_p2+56]
  movq   rax, newpp1_6
  mul    r12 // c_7 * p_6
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  add    r9, [reg_p1+104] // a_13
  mov    [reg_p2+8], r9      // z1
  adc    r10, 0
  adc    r8, 0
  
//   i = 14
//   tuv += c_3 * p_11     // (1)
//   tuv += c_4 * p_10     // (2)
//   tuv += c_5 * p_9     // (3)
//   tuv += c_6 * p_8     // (4)
//   tuv += c_7 * p_7     // (5)
//   tuv += c_8 * p_6     // (6)
//   tuv += a_14
//   c_2 = v
  xor    r9, r9
  movq   rax, newpp1_11 
  mul    r14 // a_3 * p_11
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, newpp1_10 
  mul    r15 // a_4 * p10
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, newpp1_9 
  mul    rcx // a_5 * p9
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, newpp1_8 
  mul    r11 // c_6 * p_8
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, newpp1_7 
  mul    r12 // c_7 * p_7
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  mov    r13, [reg_p2+64]
  movq   rax, newpp1_6
  mul    r13 // c_8 * p_6
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0

  add    r10, [reg_p1+112] // + a_14
  mov    [reg_p2+16], r10    // z2
  adc    r8, 0
  adc    r9, 0
  
//   i = 15
//   tuv += c_4 * p_11     // (1)
//   tuv += c_5 * p_10     // (2)
//   tuv += c_6 * p_9     // (3)
//   tuv += c_7 * p_8     // (4)
//   tuv += c_8 * p_7     // (5)
//   tuv += c_9 * p_6     // (6)
//   tuv += a_15
//   c_3 = v
  xor    r10, r10
  movq   rax, newpp1_11 
  mul    r15 // a_4 * p_11
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, newpp1_10 
  mul    rcx // a_5 * p_10
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, newpp1_9 
  mul    r11 // c_6 * p_9
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, newpp1_8 
  mul    r12 // c_7 * p_8
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, newpp1_7 
  mul    r13 // c_8 * p_7
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  mov    r14, [reg_p2+72]
  movq   rax, newpp1_6
  mul    r14 // c_9 * p_6
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0

  add    r8, [reg_p1+120] // + a_15
  mov    [reg_p2+24], r8     // z3
  adc    r9, 0
  adc    r10, 0
  
//   i = 16
//   tuv += c_5 * p_11     // (1)
//   tuv += c_6 * p_10     // (2)
//   tuv += c_7 * p_9     // (3)
//   tuv += c_8 * p_8     // (4)
//   tuv += c_9 * p_7     // (5)
//   tuv += c_10 * p_6     // (6)
//   tuv += a_16
//   c_4 = v
  xor    r8, r8
  movq   rax, newpp1_11 
  mul    rcx // a_5 * p_11
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, newpp1_10 
  mul    r11 // c_6 * p_10
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, newpp1_9 
  mul    r12 // c_7 * p_9
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, newpp1_8 
  mul    r13 // c_8 * p_8
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, newpp1_7 
  mul    r14 // c_9 * p_7
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  mov    r15, [reg_p2+80]
  movq   rax, newpp1_6
  mul    r15 // c_10 * p_6
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  add    r9, [reg_p1+128] // + a_16
  mov    [reg_p2+32], r9     // z4
  adc    r10, 0
  adc    r8, 0
  
//   i = 17
//   tuv += c_6 * p_11     // (1)
//   tuv += c_7 * p_10     // (2)
//   tuv += c_8 * p_9     // (3)
//   tuv += c_9 * p_8     // (4)
//   tuv += c_10 * p_7     // (5)
//   tuv += c_11 * p_6     // (6)
//   tuv += a_17
//   c_5 = v
  xor    r9, r9
  movq   rax, newpp1_11 
  mul    r11 // c_6 * p_11
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, newpp1_10 
  mul    r12 // c_7 * p_10
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, newpp1_9 
  mul    r13 // c_8 * p_9
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, newpp1_8 
  mul    r14 // c_9 * p_8
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, newpp1_7 
  mul    r15 // c_10 * p_7
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0

  mov    rcx, [reg_p2+88]
  movq   rax, newpp1_6
  mul    rcx // c_11 * p_6
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  add    r10, [reg_p1+136] // + a_17
  mov    [reg_p2+40], r10    // z5
  adc    r8, 0
  adc    r9, 0
  
//   i = 18
//   tuv += c_7 * p_11     // (1)
//   tuv += c_8 * p_10     // (2)
//   tuv += c_9 * p_9     // (3)
//   tuv += c_10 * p_8     // (4)
//   tuv += c_11 * p_7     // (5)
//   tuv += a_18
//   c_6 = v
  xor    r10, r10
  movq   rax, newpp1_11 
  mul    r12 // c_7 * p_11
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, newpp1_10 
  mul    r13 // c_8 * p_10
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, newpp1_9 
  mul    r14 // c_9 * p_9
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, newpp1_8 
  mul    r15 // c_10 * p_8
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  
  movq   rax, newpp1_7 
  mul    rcx // c_11 * p_7
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0

  add    r8, [reg_p1+144] // + a_18
  mov    [reg_p2+48], r8     // z6
  adc    r9, 0
  adc    r10, 0
  
//   i = 19
//   tuv += c_8 * p_11     // (1)
//   tuv += c_9 * p_10     // (2)
//   tuv += c_10 * p_9     // (3)
//   tuv += c_11 * p_8     // (4)
//   tuv += a_19
//   c_7 = v
  xor    r8, r8
  movq   rax, newpp1_11 
  mul    r13 // c_8 * p_11
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, newpp1_10 
  mul    r14 // c_9 * p_10
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, newpp1_9 
  mul    r15 // c_10 * p_9
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0
  
  movq   rax, newpp1_8 
  mul    rcx // c_11 * p_8
  add    r9, rax
  adc    r10, rdx
  adc    r8, 0

  add    r9, [reg_p1+152] // + a_19
  mov    [reg_p2+56], r9     // z7
  adc    r10, 0
  adc    r8, 0
  
//   i = 20
//   tuv += c_9 * p_11     // (1)
//   tuv += c_10 * p_10     // (2)
//   tuv += c_11 * p_9     // (3)
//   tuv += a_20
//   c_8 = v
  xor    r9, r9
  movq   rax, newpp1_11 
  mul    r14 // c_9 * p_11
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, newpp1_10 
  mul    r15 // c_10 * p_10
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0
  
  movq   rax, newpp1_9 
  mul    rcx // c_11 * p_9
  add    r10, rax
  adc    r8, rdx
  adc    r9, 0

  add    r10, [reg_p1+160] // + a_20
  mov    [reg_p2+64], r10    // z8
  adc    r8, 0
  adc    r9, 0
  
  xor    r10, r10
  movq   rax, newpp1_11 
  mul    r15
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0

  movq   rax, newpp1_10 
  mul    rcx
  add    r8, rax
  adc    r9, rdx
  adc    r10, 0
  add    r8, [reg_p1+168]    // z9
  adc    r9, 0
  adc    r10, 0
  
  movq   rax, newpp1_11 
  mul    rcx
  add    r9, rax
  adc    r10, rdx
  add    r9, [reg_p1+176]    // z10
  adc    r10, 0  
  add    r10, [reg_p1+184]   // z11

// Final, constant-time correction
  mov    rax, [reg_p2]
  movq   rcx, newp_0  
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
  sbb    r14, rcx
  mov    r15, [reg_p2+48]
  movq   rcx, newp_6  
  sbb    r15, rcx
  mov    rax, [reg_p2+56]
  movq   rcx, newp_7  
  sbb    rax, rcx
  mov    rdx, [reg_p2+64]
  movq   rcx, newp_8  
  sbb    rdx, rcx
  movq   rcx, newp_9  
  sbb    r8, rcx
  movq   rcx, newp_10  
  sbb    r9, rcx
  movq   rcx, newp_11  
  sbb    r10, rcx
  movq   rcx, 0
  sbb    rcx, 0
  
  movq   r11, newp_0  
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
  adc    r14, rcx
  mov    [reg_p2+40], r14 
  movq   r11, 0
  adc    r11, 0 
  movq   r12, newp_6   
  and    r12, rcx
  shr    r11, 1
  adc    r15, r12
  mov    [reg_p2+48], r15 
  adc    r11, 0 
  movq   r12, newp_7   
  and    r12, rcx
  shr    r11, 1
  adc    rax, r12
  mov    [reg_p2+56], rax  
  adc    r11, 0 
  movq   r12, newp_8   
  and    r12, rcx
  shr    r11, 1
  adc    rdx, r12
  mov    [reg_p2+64], rdx  
  adc    r11, 0 
  movq   r12, newp_9   
  and    r12, rcx
  shr    r11, 1
  adc    r8, r12
  mov    [reg_p2+72], r8  
  adc    r11, 0 
  movq   r12, newp_10   
  and    r12, rcx
  shr    r11, 1
  adc    r9, r12
  mov    [reg_p2+80], r9  
  adc    r11, 0 
  movq   r12, newp_11   
  and    r12, rcx
  shr    r11, 1
  adc    r10, r12
  mov    [reg_p2+88], r10 
  
  pop    r15
  pop    r14
  pop    r13
  pop    r12
  ret
