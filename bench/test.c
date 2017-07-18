#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

#include <gmp.h>
#include <assert.h>

void interleaved_rdc_mont1(uint64_t *ma, uint64_t *mc);
void interleaved_rdc_mont2(uint64_t *ma, uint64_t *mc);
void interleaved_asm_rdc_mont(uint64_t* ma, uint64_t* mc);
void shifted_rdc_mont(uint64_t* ma, uint64_t* mc);
void doublelimb_asm_rdc_mont(uint64_t* ma, uint64_t* mc);

#define outsize 12

int test () {
    // initialize rng
    gmp_randstate_t state;
    gmp_randinit_default(state);
    gmp_randseed_ui(state, 4312039434);
  
    // compute prime p
    mpz_t p;
    mpz_init(p);
    mpz_set_ui(p, 1);
    mpz_mul_2exp(p, p, 372);
    mpz_t t;
    mpz_init(t);
    mpz_set_ui(t, 3);
    mpz_pow_ui(t, t, 239);
    mpz_mul(p, p, t);
    mpz_sub_ui(p, p, 1);

    mpz_t a, b, n; mpz_init(a); mpz_init(b); mpz_init(n);
    mpz_t nbackup; mpz_init(nbackup);

    mpz_t Ri; mpz_init(Ri); mpz_set_str(Ri, "10697b6387eb53ccdbc062eb0c61f118a0c0e417a25d438209e6ce499615f828587c510583cf29ebe4d49805c5c62f75f424f8df437cfa421554fe2e49ca85bab790796cf84d4d74319a6c9bca37551ae9f5f5f6aff3b7f731b89b2da43f" , 16);
    mpz_t out; mpz_init(out);
    mpz_t ndR; mpz_init(ndR);

    for(int iter=0; iter < 1000000; iter++) {
        // Testinput is product of two random numbers
        mpz_urandomm(a, state, p);
        mpz_urandomm(b, state, p);
        mpz_mul(n, a, b);
        mpz_mul(nbackup, a, b);

        mpz_mul(ndR, n, Ri);
        mpz_tdiv_r(out, ndR, p);

        mp_limb_t out_interleaved1[outsize];
        interleaved_rdc_mont1(n->_mp_d, out_interleaved1);
        if(mpz_cmp(nbackup, n) != 0) {
            printf("Input destroyed!\n");
        }
        if(mpn_cmp(out_interleaved1, p->_mp_d, 12) > 0) {
            printf("Output is not completely reduced!\n");
            return 2;
        }

        mp_limb_t out_interleaved2[outsize];
        interleaved_rdc_mont2(n->_mp_d, out_interleaved2);
        if(mpz_cmp(nbackup, n) != 0) {
            printf("Input destroyed!\n");
        }
        if(mpn_cmp(out_interleaved2, p->_mp_d, 12) > 0) {
            printf("Output is not completely reduced!\n");
            return 2;
        }

        mp_limb_t out_interleaved_asm[outsize];
        interleaved_asm_rdc_mont(n->_mp_d, out_interleaved_asm);
        if(mpz_cmp(nbackup, n) != 0) {
            printf("Input destroyed!\n");
        }
        if(mpn_cmp(out_interleaved_asm, p->_mp_d, 12) > 0) {
            printf("Output is not completely reduced!\n");
            return 2;
        }

        mp_limb_t out_shifted[outsize];
        shifted_rdc_mont(n->_mp_d, out_shifted);
        if(mpz_cmp(nbackup, n) != 0) {
            printf("Input destroyed!\n");
        }
        if(mpn_cmp(out_shifted, p->_mp_d, 12) > 0) {
            printf("Output is not completely reduced!\n");
            return 2;
        }

        mp_limb_t out_doublelimb_asm[outsize];
        doublelimb_asm_rdc_mont(n->_mp_d, out_doublelimb_asm);
        if(mpz_cmp(nbackup, n) != 0) {
            printf("Input destroyed!\n");
        }
        if(mpn_cmp(out_doublelimb_asm, p->_mp_d, 12) > 0) {
            printf("Output is not completely reduced!\n");
            return 2;
        }

        for(int i=outsize-1; i >= 0; i--) {
            if(out_interleaved1[i] != out_interleaved2[i] ||
               out_interleaved1[i] != out->_mp_d[i] ||
               out_interleaved1[i] != out_interleaved_asm[i] ||
               out_interleaved1[i] != out_shifted[i] ||
               out_interleaved1[i] != out_doublelimb_asm[i]) {
                printf("Outputs don't match!\n");
                return 1;
            }
        }
    }

    return 0;
}

int main() {
    test();
}
