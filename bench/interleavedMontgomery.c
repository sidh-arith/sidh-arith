#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <gmp.h>
#include "p751.h"

#if INTEGRATE
#define VERSION1 1
#endif

// Global constants
#define NWORDS_FIELD 12

#if VERSION1
#define mul_modulus_1(c,a) \
  c[0] = 0; c[1] = 0; c[2] = 0; c[3] = 0; c[4] = 0; \
  c[12] = mpn_mul_1 (c+5, mp1, 7, a)
#elif VERSION2
#define mul_modulus_1(c,a) \
  c[0] = 0; c[1] = 0; c[2] = 0; c[3] = 0; c[4] = 0; \
  c[11] = mpn_mul_1 (c+5, mp1, 6, a); \
  c[12] = mpn_lshift (c+5, c+5, 7, 52)
#endif

/* Version 1 needs 12*7 = 84 muls
 * Version 2 needs 12*6 = 72 muls
 */
#if INTEGRATE
void rdc_mont(uint64_t *a, uint64_t *c) {
#else
#if VERSION1
void interleaved_rdc_mont1(uint64_t *a, uint64_t *c) {
#endif
#if VERSION2
void interleaved_rdc_mont2(uint64_t *a, uint64_t *c) {
#endif
#endif

  mp_limb_t t1[24] = {0}, A[24]={0};

#if VERSION1
  /* Precomputed value: 3^239*2^372 / 2^(256+64) */
  mp_limb_t mp1[7] = { 0xeeb0000000000000, 0xe3ec968549f878a8, 0xda959b1a13f7cc76, 0x084e9867d6ebe876, \
                       0x8562b5045cb25748, 0x0e12909f97badc66, 0x6fe5d541f71c };
#elif VERSION2
  /* Precomputed value: 3^239*2^372 / 2^(256+64+52) */
  mp_limb_t mp1[6] = { 0xc968549f878a8eeb, 0x59b1a13f7cc76e3e, 0xe9867d6ebe876da9, \
                       0x2b5045cb25748084, 0x2909f97badc66856, 0x6fe5d541f71c0e1 };
#endif

  /* We do on purpose longer additions than needed. */
  mul_modulus_1 (t1, a[0]);                /* t2 = a[0] * (p+1) */
  mpn_add_n (A, a+1, t1+1, 23);            /* (t1+t2)/2^64       */
  // TODO: shouldn't this be 24?
  // TODO or better...shouldnt we take care of the carry?
  // can there be carry? one of them is a product, right?

#define R(i)                               \
  mul_modulus_1 (t1, A[0]);                \
  mpn_add_n (A, A+1, t1+1, (24-1-i))

  R(1);
  R(2);
  R(3);
  R(4); R(5);
  R(6); R(7); R(8); R(9); R(10);

#undef R

  mul_modulus_1 (t1, A[0]);
  mpn_add_n (c, A+1, t1+1, 12);

#ifdef DEBUG
  for(int i=23; i >= 0; i--) {
      c[i] = A[i];
  }
  return;
#endif
  if (mpn_cmp (c, &p751[0], 12) >= 0) {
    mpn_sub_n (c, c, p751, 12);
  }
}


