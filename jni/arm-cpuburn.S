/*
 * Copyright © 2012 Siarhei Siamashka <siarhei.siamashka@gmail.com>,
 *             2013 Pekka Ekman <pekka.ekman@aalto.fi>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice (including the next
 * paragraph) shall be included in all copies or substantial portions of the
 * Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

/*
 * This program tries to stress ARM Cortex-A9 processor to generate as
 * much heat as possible. Needs NEON, so does not work on Tegra 2.
 * WARNING: improperly cooled or otherwise flawed hardware may potentially
 * overheat and fail. Use at your own risk.
 *
 * This code is originally from https://github.com/ssvb/cpuburn-arm and has
 * been modified to be embedded in an Android application.
 *
 * See http://ssvb.github.com/2012/04/10/cpuburn-arm-cortex-a9.html
 * for more details.
 */
    .syntax unified
    .text
    .arch armv7-a
    .fpu neon
    .arm

    .global cpuburn

/* optimal value for LOOP_UNROLL_FACTOR seems to be BTB size dependent */
#define LOOP_UNROLL_FACTOR   110
/* 64 seems to be a good choice */
#define STEP                 64

.func cpuburn
cpuburn:

        ldr         lr, =(STEP * 4 + 15)
        subs        lr, sp, lr
        bic         lr, lr, #15
        mov         ip, #STEP
        mov         r0, #0
        mov         r1, #0
        mov         r2, #0
        mov         r3, #0
        ldr         r4, =0xFFFFFFFF
        b           0f
    .ltorg
0:
    .rept LOOP_UNROLL_FACTOR
        vld2.8      {q0}, [lr, :128], ip
        it          ne
        smlalne     r0, r1, lr, r4
        bne         1f
1:
        vld2.8      {q1}, [lr, :128], ip
        it          ne
        smlalne     r2, r3, lr, r4
        bne         1f
1:
        vld2.8      {q2}, [lr, :128], ip
        vld2.8      {q3}, [lr, :128], ip
        it          ne
        subsne      lr, lr, #(STEP * 4)
    .endr
        bne         0b
.endfunc
