#include <stdio.h>
#include <stdint.h>
#include <math.h>

static inline uint64_t get_cycles()
{
  uint64_t t;
  __asm volatile ("rdtsc" : "=A"(t));
  return t;
}

extern void FUNNAME (uint64_t *, uint64_t *);

int main () {
  uint64_t start, end;
  uint64_t ma[24], mc[24];
  int i, loop, i0, i1, R0, R1;
  double r[100], t, mean, var, std;

  loop = 10*100;

  i1 = 100;
  t = 0;
  for (i0=0; i0 < i1; i0++) {
    start = get_cycles();
    for (i=0; i < loop/10; i++) {
      FUNNAME(ma, mc);
      FUNNAME(mc, ma);
      FUNNAME(ma, mc);
      FUNNAME(mc, ma);
      FUNNAME(ma, mc);
      FUNNAME(mc, ma);
      FUNNAME(ma, mc);
      FUNNAME(mc, ma);
      FUNNAME(ma, mc);
      FUNNAME(mc, ma);
    }
    end = get_cycles ();
    r[i0] = (double)(end-start)/loop;
    t += r[i0];
  }
  
  //for (i0=0; i0<i1; i0++) printf ("%d: %f\n", i0, r[i0]);

  mean = t/i1;
  var=0;
  for (i0=0; i0<i1; i0++) var += (mean-r[i0])*(mean-r[i0]);
  var /= i1;
  std = sqrt(var);

  printf ("MS-asm: %f cycles with std=%f\n", mean, std);

  R0 = i1;

  do {
  
    /* Remove everything which is more than 2 std away */
    for (i0=0; i0<i1; i0++) {
      if (r[i0] != -1 && r[i0] > (mean+2.5*std)) r[i0] = -1;
    }

    mean = 0; R1 = 0;
    for (i0=0; i0<i1; i0++) {
      if (r[i0] == -1) continue;
      mean += r[i0];
      R1++;
    }
    mean /= R1;

    var=0;
    for (i0=0; i0<i1; i0++) {
      if (r[i0] == -1) continue;
      var += (mean-r[i0])*(mean-r[i0]);
    }
    var /= R1;
    std = sqrt(var);

    printf ("From %d to %d\n", R0, R1);
    if (R0-R1 == 0) break;
    R0=R1;
    printf ("MS-asm: %f cycles with std=%f\n", mean, std);
  } while (0);


  return 0;
}

