#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "utils.h"
#include "kernel.h"

int main() {
  float *th, *pii, *q;
  float *qc, *qi, *qr, *qs;
  float *den, *p, *delz;
  float *rain,*rainncv;
  float *sr;
  float *snow, *snowncv;

  float delt = 10.f;
  int ims = 0, ime = 59, jms = 0, jme = 45, kms = 0, kme = 2;
  int ips = 0, ipe = 59, jps = 0, jpe = 45, kps = 0, kpe = 2;
  int d3 = (ime-ims+1) * (jme-jms+1) * (kme-kms+1) ;
  int d2 = (ime-ims+1) * (jme-jms+1) ;

  int dips = 0 ; int dipe = (ipe-ips+1) ;
  int djps = 0 ; int djpe = (jpe-jps+1) ;
  int dkps = 0 ; int dkpe = (kpe-kps+1) ;

  srand(123); // init. data randomly in TODEV macros
  TODEV3(th) ;
  TODEV3(pii) ;
  TODEV3(q) ;
  TODEV3(qc) ;
  TODEV3(qi) ;
  TODEV3(qr) ;
  TODEV3(qs) ;
  TODEV3(den) ;
  TODEV3(p) ;
  TODEV3(delz) ;
  TODEV2(rain) ;
  TODEV2(rainncv) ;
  TODEV2(sr) ;
  TODEV2(snow) ;
  TODEV2(snowncv) ;

  int remx = (ipe-ips+1) % XXX != 0 ? 1 : 0 ;
  int remy = (jpe-jps+1) % YYY != 0 ? 1 : 0 ;

  dim3 dimBlock( XXX , YYY ) ;
  dim3 dimGrid ( (ipe-ips+1) / XXX + remx , (jpe-jps+1) / YYY + remy ) ;

  wsm <<< dimGrid, dimBlock >>> (
      th_d, pii_d, q_d, qc_d, qi_d, qr_d, qs_d, den_d, p_d, delz_d,
      rain_d, rainncv_d,
      sr_d,
      snow_d, snowncv_d,
      delt,
      dips+1 , (ipe-ips+1) , // ids, ide
      djps+1 , (jpe-jps+1) , // jds, jde 
      dkps+1 , (kpe-kps+1),  // kds, kde
      dips+1 , dipe ,        // ims, ime
      djps+1 , djpe ,        // jms, jme
      dkps+1 , dkpe,         // kms, kme
      dips+1 , dipe ,        // ips, ipe
      djps+1 , djpe ,        // jps, jpe
      dkps+1 , dkpe) ;       // kps, kpe 

  cudaDeviceSynchronize() ;

  FROMDEV2(rain) ;
  FROMDEV2(snow) ;

  // print rain and snow data
  float rain_sum = 0, snow_sum = 0;
  for (int i = 0; i < d2; i++) {
    rain_sum += rain[i];
    snow_sum += snow[i];
  }
  printf("Checksum: rain = %f snow = %f\n", rain_sum, snow_sum);

  FREE(th) ;
  FREE(pii) ;
  FREE(q) ;
  FREE(qc) ;
  FREE(qi) ;
  FREE(qr) ;
  FREE(qs) ;
  FREE(den) ;
  FREE(p) ;
  FREE(delz) ;
  FREE(rain) ;
  FREE(rainncv) ;
  FREE(sr) ;
  FREE(snow) ;
  FREE(snowncv) ;
  return(0) ;
}

