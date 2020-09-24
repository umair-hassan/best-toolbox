/*
 * rida_hassan.c
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "rida_hassan".
 *
 * Model version              : 1.8
 * Simulink Coder version : 8.13 (R2017b) 24-Jul-2017
 * C source code generated on : Thu Sep 24 17:53:11 2020
 *
 * Target selection: grt.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "rida_hassan.h"
#include "rida_hassan_private.h"

/* Real-time model */
RT_MODEL_rida_hassan_T rida_hassan_M_;
RT_MODEL_rida_hassan_T *const rida_hassan_M = &rida_hassan_M_;

/* Model step function */
void rida_hassan_step(void)
{
  /* Matfile logging */
  rt_UpdateTXYLogVars(rida_hassan_M->rtwLogInfo,
                      (&rida_hassan_M->Timing.taskTime0));

  /* signal main to stop simulation */
  {                                    /* Sample time: [0.02s, 0.0s] */
    if ((rtmGetTFinal(rida_hassan_M)!=-1) &&
        !((rtmGetTFinal(rida_hassan_M)-rida_hassan_M->Timing.taskTime0) >
          rida_hassan_M->Timing.taskTime0 * (DBL_EPSILON))) {
      rtmSetErrorStatus(rida_hassan_M, "Simulation finished");
    }
  }

  /* Update absolute time for base rate */
  /* The "clockTick0" counts the number of times the code of this task has
   * been executed. The absolute time is the multiplication of "clockTick0"
   * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
   * overflow during the application lifespan selected.
   * Timer of this task consists of two 32 bit unsigned integers.
   * The two integers represent the low bits Timing.clockTick0 and the high bits
   * Timing.clockTickH0. When the low bit overflows to 0, the high bits increment.
   */
  if (!(++rida_hassan_M->Timing.clockTick0)) {
    ++rida_hassan_M->Timing.clockTickH0;
  }

  rida_hassan_M->Timing.taskTime0 = rida_hassan_M->Timing.clockTick0 *
    rida_hassan_M->Timing.stepSize0 + rida_hassan_M->Timing.clockTickH0 *
    rida_hassan_M->Timing.stepSize0 * 4294967296.0;
}

/* Model initialize function */
void rida_hassan_initialize(void)
{
  /* Registration code */

  /* initialize non-finites */
  rt_InitInfAndNaN(sizeof(real_T));

  /* initialize real-time model */
  (void) memset((void *)rida_hassan_M, 0,
                sizeof(RT_MODEL_rida_hassan_T));
  rtmSetTFinal(rida_hassan_M, 1.0);
  rida_hassan_M->Timing.stepSize0 = 0.02;

  /* Setup for data logging */
  {
    static RTWLogInfo rt_DataLoggingInfo;
    rt_DataLoggingInfo.loggingInterval = NULL;
    rida_hassan_M->rtwLogInfo = &rt_DataLoggingInfo;
  }

  /* Setup for data logging */
  {
    rtliSetLogXSignalInfo(rida_hassan_M->rtwLogInfo, (NULL));
    rtliSetLogXSignalPtrs(rida_hassan_M->rtwLogInfo, (NULL));
    rtliSetLogT(rida_hassan_M->rtwLogInfo, "tout");
    rtliSetLogX(rida_hassan_M->rtwLogInfo, "");
    rtliSetLogXFinal(rida_hassan_M->rtwLogInfo, "");
    rtliSetLogVarNameModifier(rida_hassan_M->rtwLogInfo, "rt_");
    rtliSetLogFormat(rida_hassan_M->rtwLogInfo, 4);
    rtliSetLogMaxRows(rida_hassan_M->rtwLogInfo, 0);
    rtliSetLogDecimation(rida_hassan_M->rtwLogInfo, 1);
    rtliSetLogY(rida_hassan_M->rtwLogInfo, "");
    rtliSetLogYSignalInfo(rida_hassan_M->rtwLogInfo, (NULL));
    rtliSetLogYSignalPtrs(rida_hassan_M->rtwLogInfo, (NULL));
  }

  /* Matfile logging */
  rt_StartDataLoggingWithStartTime(rida_hassan_M->rtwLogInfo, 0.0, rtmGetTFinal
    (rida_hassan_M), rida_hassan_M->Timing.stepSize0, (&rtmGetErrorStatus
    (rida_hassan_M)));
}

/* Model terminate function */
void rida_hassan_terminate(void)
{
  /* (no terminate code required) */
}
