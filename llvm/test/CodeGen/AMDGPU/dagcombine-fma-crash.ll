; NOTE: Assertions have been autogenerated by utils/update_mir_test_checks.py
; RUN: llc -march=amdgcn -mcpu=gfx1030 -start-before=amdgpu-isel -stop-after=amdgpu-isel < %s | FileCheck %s

define void @main(float %arg) {
  ; CHECK-LABEL: name: main
  ; CHECK: bb.0.bb:
  ; CHECK-NEXT:   successors: %bb.1(0x50000000), %bb.2(0x30000000)
  ; CHECK-NEXT:   liveins: $vgpr0
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:vgpr_32 = COPY $vgpr0
  ; CHECK-NEXT:   [[S_MOV_B32_:%[0-9]+]]:sgpr_32 = S_MOV_B32 0
  ; CHECK-NEXT:   [[S_MOV_B32_1:%[0-9]+]]:sreg_32 = S_MOV_B32 -1
  ; CHECK-NEXT:   [[DEF:%[0-9]+]]:sgpr_32 = IMPLICIT_DEF
  ; CHECK-NEXT:   [[S_AND_B32_:%[0-9]+]]:sreg_32 = S_AND_B32 $exec_lo, [[S_MOV_B32_1]], implicit-def dead $scc
  ; CHECK-NEXT:   $vcc_lo = COPY [[S_AND_B32_]]
  ; CHECK-NEXT:   S_CBRANCH_VCCNZ %bb.2, implicit $vcc
  ; CHECK-NEXT:   S_BRANCH %bb.1
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT: bb.1.bb2:
  ; CHECK-NEXT:   successors: %bb.2(0x80000000)
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT:   [[V_MOV_B32_e32_:%[0-9]+]]:vgpr_32 = V_MOV_B32_e32 1065353216, implicit $exec
  ; CHECK-NEXT:   [[V_FMAC_F32_e64_:%[0-9]+]]:vgpr_32 = contract reassoc nofpexcept V_FMAC_F32_e64 0, [[S_MOV_B32_]], 0, [[S_MOV_B32_]], 0, [[V_MOV_B32_e32_]], 0, 0, implicit $mode, implicit $exec
  ; CHECK-NEXT:   [[V_FMAC_F32_e64_1:%[0-9]+]]:vgpr_32 = contract reassoc nofpexcept V_FMAC_F32_e64 0, [[COPY]], 0, [[COPY]], 0, [[V_FMAC_F32_e64_]], 0, 0, implicit $mode, implicit $exec
  ; CHECK-NEXT:   [[V_ADD_F32_e64_:%[0-9]+]]:vgpr_32 = contract reassoc nofpexcept V_ADD_F32_e64 0, [[V_FMAC_F32_e64_1]], 0, [[V_MOV_B32_e32_]], 0, 0, implicit $mode, implicit $exec
  ; CHECK-NEXT:   [[S_MOV_B32_2:%[0-9]+]]:sreg_32 = S_MOV_B32 0
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT: bb.2.bb11:
  ; CHECK-NEXT:   successors: %bb.3(0x40000000), %bb.4(0x40000000)
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT:   [[PHI:%[0-9]+]]:vgpr_32 = PHI [[DEF]], %bb.0, [[V_FMAC_F32_e64_1]], %bb.1
  ; CHECK-NEXT:   [[PHI1:%[0-9]+]]:vgpr_32 = PHI [[DEF]], %bb.0, [[V_ADD_F32_e64_]], %bb.1
  ; CHECK-NEXT:   [[PHI2:%[0-9]+]]:sreg_32_xm0_xexec = PHI [[S_MOV_B32_1]], %bb.0, [[S_MOV_B32_2]], %bb.1
  ; CHECK-NEXT:   [[V_CNDMASK_B32_e64_:%[0-9]+]]:vgpr_32 = V_CNDMASK_B32_e64 0, 0, 0, 1, [[PHI2]], implicit $exec
  ; CHECK-NEXT:   [[S_MOV_B32_3:%[0-9]+]]:sreg_32 = S_MOV_B32 1
  ; CHECK-NEXT:   [[COPY1:%[0-9]+]]:sreg_32 = COPY [[V_CNDMASK_B32_e64_]]
  ; CHECK-NEXT:   S_CMP_LG_U32 killed [[COPY1]], killed [[S_MOV_B32_3]], implicit-def $scc
  ; CHECK-NEXT:   [[COPY2:%[0-9]+]]:sreg_32 = COPY $scc
  ; CHECK-NEXT:   [[S_AND_B32_1:%[0-9]+]]:sreg_32 = S_AND_B32 $exec_lo, killed [[COPY2]], implicit-def dead $scc
  ; CHECK-NEXT:   $vcc_lo = COPY [[S_AND_B32_1]]
  ; CHECK-NEXT:   S_CBRANCH_VCCNZ %bb.4, implicit $vcc
  ; CHECK-NEXT:   S_BRANCH %bb.3
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT: bb.3.bb15:
  ; CHECK-NEXT:   successors: %bb.4(0x80000000)
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT: bb.4.bb17:
  ; CHECK-NEXT:   SI_RETURN
bb:
  %i = fadd reassoc contract float 0.000000e+00, 0.000000e+00
  %i1 = icmp ne i32 0, 0
  br i1 %i1, label %bb2, label %bb11

bb2:
  %i3 = fmul reassoc contract float %i, %i
  %i4 = fmul reassoc contract float %arg, %arg
  %i5 = fadd reassoc contract float %i3, 1.000000e+00
  %i6 = fadd reassoc contract float %i5, %i4
  %i7 = fmul reassoc contract float %arg, %arg
  %i8 = fmul reassoc contract float %i, %i
  %i9 = fadd reassoc contract float %i7, %i8
  %i10 = fadd reassoc contract float %i9, 1.000000e+00
  br label %bb11

bb11:
  %i12 = phi float [ %i6, %bb2 ], [ undef, %bb ]
  %i13 = phi float [ %i10, %bb2 ], [ undef, %bb ]
  %i14 = phi i1 [ false, %bb2 ], [ true, %bb ]
  br i1 %i14, label %bb15, label %bb17

bb15:
  %i16 = fmul reassoc contract float %i, 0.000000e+00
  br label %bb17

bb17:
  %i18 = phi float [ %i13, %bb11 ], [ 0.000000e+00, %bb15 ]
  %i19 = phi float [ %i12, %bb11 ], [ 0.000000e+00, %bb15 ]
  ret void
}