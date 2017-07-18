#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

#include <gmp.h>
#include <assert.h>

void rdcnewp(uint64_t* ma, uint64_t* mc);

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
    mpz_mul_2exp(p, p, 391);
    mpz_t t;
    mpz_init(t);
    mpz_set_ui(t, 19);
    mpz_pow_ui(t, t, 88);
    mpz_mul(p, p, t);
    mpz_sub_ui(p, p, 1);

    mpz_t a, b, n; mpz_init(a); mpz_init(b); mpz_init(n);
    mpz_t nbackup; mpz_init(nbackup);

    mpz_t Ri; mpz_init(Ri); mpz_set_str(Ri, "18838820452132104174286538372260520475000926806270064298369355246037677236235533928808674592960719581554439724704068343634041409016615755009668349046383613887978269125200099317405233648742093108425586979613822723003439063965384704" , 10);
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

        mp_limb_t out_better_prime[outsize];
        rdcnewp(n->_mp_d, out_better_prime);
        if(mpz_cmp(nbackup, n) != 0) {
            printf("Input destroyed!\n");
        }
        if(mpn_cmp(out_better_prime, p->_mp_d, 12) > 0) {
            printf("Output is not completely reduced!\n");
            return 2;
        }

        for(int i=outsize-1; i >= 0; i--) {
            if(out_better_prime[i] != out->_mp_d[i]) {
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
