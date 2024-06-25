; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=instcombine -S | FileCheck %s
; These should be InstSimplify checks, but most of the code
; is currently only in InstCombine.  TODO: move supporting code

declare void @use(i8)
declare void @use_vec(<2 x i8>)

; Definitely out of range
define i1 @test_nonzero(ptr nocapture readonly %arg) {
; CHECK-LABEL: @test_nonzero(
; CHECK-NEXT:    ret i1 true
;
  %val = load i32, ptr %arg, !range !0
  %rval = icmp ne i32 %val, 0
  ret i1 %rval
}
define i1 @test_nonzero2(ptr nocapture readonly %arg) {
; CHECK-LABEL: @test_nonzero2(
; CHECK-NEXT:    ret i1 false
;
  %val = load i32, ptr %arg, !range !0
  %rval = icmp eq i32 %val, 0
  ret i1 %rval
}

; Potentially in range
define i1 @test_nonzero3(ptr nocapture readonly %arg) {
; CHECK-LABEL: @test_nonzero3(
; CHECK-NEXT:    [[VAL:%.*]] = load i32, ptr [[ARG:%.*]], align 4, !range [[RNG0:![0-9]+]]
; CHECK-NEXT:    [[RVAL:%.*]] = icmp ne i32 [[VAL]], 0
; CHECK-NEXT:    ret i1 [[RVAL]]
;
; Check that this does not trigger - it wouldn't be legal
  %val = load i32, ptr %arg, !range !1
  %rval = icmp ne i32 %val, 0
  ret i1 %rval
}

; Definitely in range
define i1 @test_nonzero4(ptr nocapture readonly %arg) {
; CHECK-LABEL: @test_nonzero4(
; CHECK-NEXT:    ret i1 false
;
  %val = load i8, ptr %arg, !range !2
  %rval = icmp ne i8 %val, 0
  ret i1 %rval
}

define i1 @test_nonzero5(ptr nocapture readonly %arg) {
; CHECK-LABEL: @test_nonzero5(
; CHECK-NEXT:    ret i1 false
;
  %val = load i8, ptr %arg, !range !2
  %rval = icmp ugt i8 %val, 0
  ret i1 %rval
}

; Cheaper checks (most values in range meet requirements)
define i1 @test_nonzero6(ptr %argw) {
; CHECK-LABEL: @test_nonzero6(
; CHECK-NEXT:    [[VAL:%.*]] = load i8, ptr [[ARGW:%.*]], align 1, !range [[RNG1:![0-9]+]]
; CHECK-NEXT:    [[RVAL:%.*]] = icmp ne i8 [[VAL]], 0
; CHECK-NEXT:    ret i1 [[RVAL]]
;
  %val = load i8, ptr %argw, !range !3
  %rval = icmp sgt i8 %val, 0
  ret i1 %rval
}

; Constant not in range, should return true.
define i1 @test_not_in_range(ptr nocapture readonly %arg) {
; CHECK-LABEL: @test_not_in_range(
; CHECK-NEXT:    ret i1 true
;
  %val = load i32, ptr %arg, !range !0
  %rval = icmp ne i32 %val, 6
  ret i1 %rval
}

; Constant in range, can not fold.
define i1 @test_in_range(ptr nocapture readonly %arg) {
; CHECK-LABEL: @test_in_range(
; CHECK-NEXT:    [[VAL:%.*]] = load i32, ptr [[ARG:%.*]], align 4, !range [[RNG2:![0-9]+]]
; CHECK-NEXT:    [[RVAL:%.*]] = icmp ne i32 [[VAL]], 3
; CHECK-NEXT:    ret i1 [[RVAL]]
;
  %val = load i32, ptr %arg, !range !0
  %rval = icmp ne i32 %val, 3
  ret i1 %rval
}

; Values in range greater than constant.
define i1 @test_range_sgt_constant(ptr nocapture readonly %arg) {
; CHECK-LABEL: @test_range_sgt_constant(
; CHECK-NEXT:    ret i1 true
;
  %val = load i32, ptr %arg, !range !0
  %rval = icmp sgt i32 %val, 0
  ret i1 %rval
}

; Values in range less than constant.
define i1 @test_range_slt_constant(ptr nocapture readonly %arg) {
; CHECK-LABEL: @test_range_slt_constant(
; CHECK-NEXT:    ret i1 false
;
  %val = load i32, ptr %arg, !range !0
  %rval = icmp sgt i32 %val, 6
  ret i1 %rval
}

; Values in union of multiple sub ranges not equal to constant.
define i1 @test_multi_range1(ptr nocapture readonly %arg) {
; CHECK-LABEL: @test_multi_range1(
; CHECK-NEXT:    ret i1 true
;
  %val = load i32, ptr %arg, !range !4
  %rval = icmp ne i32 %val, 0
  ret i1 %rval
}

; Values in multiple sub ranges not equal to constant, but in
; union of sub ranges could possibly equal to constant. This
; in theory could also be folded and might be implemented in
; the future if shown profitable in practice.
define i1 @test_multi_range2(ptr nocapture readonly %arg) {
; CHECK-LABEL: @test_multi_range2(
; CHECK-NEXT:    [[VAL:%.*]] = load i32, ptr [[ARG:%.*]], align 4, !range [[RNG3:![0-9]+]]
; CHECK-NEXT:    [[RVAL:%.*]] = icmp ne i32 [[VAL]], 7
; CHECK-NEXT:    ret i1 [[RVAL]]
;
  %val = load i32, ptr %arg, !range !4
  %rval = icmp ne i32 %val, 7
  ret i1 %rval
}

; Values' ranges overlap each other, so it can not be simplified.
define i1 @test_two_ranges(ptr nocapture readonly %arg1, ptr nocapture readonly %arg2) {
; CHECK-LABEL: @test_two_ranges(
; CHECK-NEXT:    [[VAL1:%.*]] = load i32, ptr [[ARG1:%.*]], align 4, !range [[RNG4:![0-9]+]]
; CHECK-NEXT:    [[VAL2:%.*]] = load i32, ptr [[ARG2:%.*]], align 4, !range [[RNG5:![0-9]+]]
; CHECK-NEXT:    [[RVAL:%.*]] = icmp ult i32 [[VAL2]], [[VAL1]]
; CHECK-NEXT:    ret i1 [[RVAL]]
;
  %val1 = load i32, ptr %arg1, !range !5
  %val2 = load i32, ptr %arg2, !range !6
  %rval = icmp ult i32 %val2, %val1
  ret i1 %rval
}

; Values' ranges do not overlap each other, so it can simplified to false.
define i1 @test_two_ranges2(ptr nocapture readonly %arg1, ptr nocapture readonly %arg2) {
; CHECK-LABEL: @test_two_ranges2(
; CHECK-NEXT:    ret i1 false
;
  %val1 = load i32, ptr %arg1, !range !0
  %val2 = load i32, ptr %arg2, !range !6
  %rval = icmp ult i32 %val2, %val1
  ret i1 %rval
}

; Values' ranges do not overlap each other, so it can simplified to true.
define i1 @test_two_ranges3(ptr nocapture readonly %arg1, ptr nocapture readonly %arg2) {
; CHECK-LABEL: @test_two_ranges3(
; CHECK-NEXT:    ret i1 true
;
  %val1 = load i32, ptr %arg1, !range !0
  %val2 = load i32, ptr %arg2, !range !6
  %rval = icmp ugt i32 %val2, %val1
  ret i1 %rval
}

define i1 @ugt_zext(i1 %b, i8 %x) {
; CHECK-LABEL: @ugt_zext(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[X:%.*]], 0
; CHECK-NEXT:    [[R:%.*]] = and i1 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %z = zext i1 %b to i8
  %r = icmp ugt i8 %z, %x
  ret i1 %r
}

define <2 x i1> @ult_zext(<2 x i1> %b, <2 x i8> %p) {
; CHECK-LABEL: @ult_zext(
; CHECK-NEXT:    [[X:%.*]] = mul <2 x i8> [[P:%.*]], [[P]]
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq <2 x i8> [[X]], zeroinitializer
; CHECK-NEXT:    [[R:%.*]] = and <2 x i1> [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %x = mul <2 x i8> %p, %p ; thwart complexity-based canonicalization
  %z = zext <2 x i1> %b to <2 x i8>
  %r = icmp ult <2 x i8> %x, %z
  ret <2 x i1> %r
}

; negative test - need ult/ugt

define i1 @uge_zext(i1 %b, i8 %x) {
; CHECK-LABEL: @uge_zext(
; CHECK-NEXT:    [[Z:%.*]] = zext i1 [[B:%.*]] to i8
; CHECK-NEXT:    [[R:%.*]] = icmp uge i8 [[Z]], [[X:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %z = zext i1 %b to i8
  %r = icmp uge i8 %z, %x
  ret i1 %r
}

; negative test - need ult/ugt

define i1 @ule_zext(i1 %b, i8 %p) {
; CHECK-LABEL: @ule_zext(
; CHECK-NEXT:    [[X:%.*]] = mul i8 [[P:%.*]], [[P]]
; CHECK-NEXT:    [[Z:%.*]] = zext i1 [[B:%.*]] to i8
; CHECK-NEXT:    [[R:%.*]] = icmp ule i8 [[X]], [[Z]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %x = mul i8 %p, %p ; thwart complexity-based canonicalization
  %z = zext i1 %b to i8
  %r = icmp ule i8 %x, %z
  ret i1 %r
}

; negative test - extra use

define i1 @ugt_zext_use(i1 %b, i8 %x) {
; CHECK-LABEL: @ugt_zext_use(
; CHECK-NEXT:    [[Z:%.*]] = zext i1 [[B:%.*]] to i8
; CHECK-NEXT:    call void @use(i8 [[Z]])
; CHECK-NEXT:    [[R:%.*]] = icmp ugt i8 [[Z]], [[X:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %z = zext i1 %b to i8
  call void @use(i8 %z)
  %r = icmp ugt i8 %z, %x
  ret i1 %r
}

; negative test - must be zext of i1

define i1 @ult_zext_not_i1(i2 %b, i8 %x) {
; CHECK-LABEL: @ult_zext_not_i1(
; CHECK-NEXT:    [[Z:%.*]] = zext i2 [[B:%.*]] to i8
; CHECK-NEXT:    [[R:%.*]] = icmp ugt i8 [[Z]], [[X:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %z = zext i2 %b to i8
  %r = icmp ult i8 %x, %z
  ret i1 %r
}

; sub is eliminated

define i1 @sub_ult_zext(i1 %b, i8 %x, i8 %y) {
; CHECK-LABEL: @sub_ult_zext(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = and i1 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %z = zext i1 %b to i8
  %s = sub i8 %x, %y
  %r = icmp ult i8 %s, %z
  ret i1 %r
}

define i1 @zext_ult_zext(i1 %b, i8 %p) {
; CHECK-LABEL: @zext_ult_zext(
; CHECK-NEXT:    [[X:%.*]] = mul i8 [[P:%.*]], [[P]]
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[X]], 0
; CHECK-NEXT:    [[R:%.*]] = and i1 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %x = mul i8 %p, %p ; thwart complexity-based canonicalization
  %z = zext i1 %b to i16
  %zx = zext i8 %x to i16
  %r = icmp ult i16 %zx, %z
  ret i1 %r
}

; match and fold even if both sides are zexts (from different source types)

define i1 @zext_ugt_zext(i1 %b, i4 %x) {
; CHECK-LABEL: @zext_ugt_zext(
; CHECK-NEXT:    [[ZX:%.*]] = zext i4 [[X:%.*]] to i8
; CHECK-NEXT:    call void @use(i8 [[ZX]])
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i4 [[X]], 0
; CHECK-NEXT:    [[R:%.*]] = and i1 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %z = zext i1 %b to i8
  %zx = zext i4 %x to i8
  call void @use(i8 %zx)
  %r = icmp ugt i8 %z, %zx
  ret i1 %r
}

; negative test - must be zext of i1

define i1 @sub_ult_zext_not_i1(i2 %b, i8 %x, i8 %y) {
; CHECK-LABEL: @sub_ult_zext_not_i1(
; CHECK-NEXT:    [[Z:%.*]] = zext i2 [[B:%.*]] to i8
; CHECK-NEXT:    [[S:%.*]] = sub i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = icmp ult i8 [[S]], [[Z]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %z = zext i2 %b to i8
  %s = sub i8 %x, %y
  %r = icmp ult i8 %s, %z
  ret i1 %r
}

; negative test - extra use (but we could try harder to fold this)

define i1 @sub_ult_zext_use1(i1 %b, i8 %x, i8 %y) {
; CHECK-LABEL: @sub_ult_zext_use1(
; CHECK-NEXT:    [[Z:%.*]] = zext i1 [[B:%.*]] to i8
; CHECK-NEXT:    call void @use(i8 [[Z]])
; CHECK-NEXT:    [[S:%.*]] = sub i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = icmp ult i8 [[S]], [[Z]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %z = zext i1 %b to i8
  call void @use(i8 %z)
  %s = sub i8 %x, %y
  %r = icmp ult i8 %s, %z
  ret i1 %r
}

define <2 x i1> @zext_ugt_sub_use2(<2 x i1> %b, <2 x i8> %x, <2 x i8> %y) {
; CHECK-LABEL: @zext_ugt_sub_use2(
; CHECK-NEXT:    [[S:%.*]] = sub <2 x i8> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    call void @use_vec(<2 x i8> [[S]])
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq <2 x i8> [[X]], [[Y]]
; CHECK-NEXT:    [[R:%.*]] = and <2 x i1> [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %z = zext <2 x i1> %b to <2 x i8>
  %s = sub <2 x i8> %x, %y
  call void @use_vec(<2 x i8> %s)
  %r = icmp ugt <2 x i8> %z, %s
  ret <2 x i1> %r
}

define i1 @sub_ult_zext_use3(i1 %b, i8 %x, i8 %y) {
; CHECK-LABEL: @sub_ult_zext_use3(
; CHECK-NEXT:    [[Z:%.*]] = zext i1 [[B:%.*]] to i8
; CHECK-NEXT:    call void @use(i8 [[Z]])
; CHECK-NEXT:    [[S:%.*]] = sub i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    call void @use(i8 [[S]])
; CHECK-NEXT:    [[R:%.*]] = icmp ult i8 [[S]], [[Z]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %z = zext i1 %b to i8
  call void @use(i8 %z)
  %s = sub i8 %x, %y
  call void @use(i8 %s)
  %r = icmp ult i8 %s, %z
  ret i1 %r
}

define i1 @sub_ule_zext(i1 %b, i8 %x, i8 %y) {
; CHECK-LABEL: @sub_ule_zext(
; CHECK-NEXT:    [[Z:%.*]] = zext i1 [[B:%.*]] to i8
; CHECK-NEXT:    [[S:%.*]] = sub i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = icmp ule i8 [[S]], [[Z]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %z = zext i1 %b to i8
  %s = sub i8 %x, %y
  %r = icmp ule i8 %s, %z
  ret i1 %r
}

define <2 x i1> @sub_ult_and(<2 x i8> %b, <2 x i8> %x, <2 x i8> %y) {
; CHECK-LABEL: @sub_ult_and(
; CHECK-NEXT:    [[A:%.*]] = and <2 x i8> [[B:%.*]], <i8 1, i8 1>
; CHECK-NEXT:    [[S:%.*]] = sub <2 x i8> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = icmp ult <2 x i8> [[S]], [[A]]
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %a = and <2 x i8> %b, <i8 1, i8 1>
  %s = sub <2 x i8> %x, %y
  %r = icmp ult <2 x i8> %s, %a
  ret <2 x i1> %r
}

define i1 @and_ugt_sub(i8 %b, i8 %x, i8 %y) {
; CHECK-LABEL: @and_ugt_sub(
; CHECK-NEXT:    [[A:%.*]] = and i8 [[B:%.*]], 1
; CHECK-NEXT:    [[S:%.*]] = sub i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = icmp ugt i8 [[A]], [[S]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %a = and i8 %b, 1
  %s = sub i8 %x, %y
  %r = icmp ugt i8 %a, %s
  ret i1 %r
}

; Repeat the zext set of tests with a sext instead.

define i1 @uge_sext(i1 %b, i8 %x) {
; CHECK-LABEL: @uge_sext(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[X:%.*]], 0
; CHECK-NEXT:    [[R:%.*]] = or i1 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %s = sext i1 %b to i8
  %r = icmp uge i8 %s, %x
  ret i1 %r
}

define <2 x i1> @ule_sext(<2 x i1> %b, <2 x i8> %p) {
; CHECK-LABEL: @ule_sext(
; CHECK-NEXT:    [[X:%.*]] = mul <2 x i8> [[P:%.*]], [[P]]
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq <2 x i8> [[X]], zeroinitializer
; CHECK-NEXT:    [[R:%.*]] = or <2 x i1> [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %x = mul <2 x i8> %p, %p ; thwart complexity-based canonicalization
  %s = sext <2 x i1> %b to <2 x i8>
  %r = icmp ule <2 x i8> %x, %s
  ret <2 x i1> %r
}

; negative test - need ule/uge

define i1 @ugt_sext(i1 %b, i8 %x) {
; CHECK-LABEL: @ugt_sext(
; CHECK-NEXT:    [[S:%.*]] = sext i1 [[B:%.*]] to i8
; CHECK-NEXT:    [[R:%.*]] = icmp ugt i8 [[S]], [[X:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %s = sext i1 %b to i8
  %r = icmp ugt i8 %s, %x
  ret i1 %r
}

; negative test - need ule/uge

define i1 @ult_sext(i1 %b, i8 %p) {
; CHECK-LABEL: @ult_sext(
; CHECK-NEXT:    [[X:%.*]] = mul i8 [[P:%.*]], [[P]]
; CHECK-NEXT:    [[S:%.*]] = sext i1 [[B:%.*]] to i8
; CHECK-NEXT:    [[R:%.*]] = icmp ult i8 [[X]], [[S]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %x = mul i8 %p, %p ; thwart complexity-based canonicalization
  %s = sext i1 %b to i8
  %r = icmp ult i8 %x, %s
  ret i1 %r
}

; negative test - extra use

define i1 @uge_sext_use(i1 %b, i8 %x) {
; CHECK-LABEL: @uge_sext_use(
; CHECK-NEXT:    [[S:%.*]] = sext i1 [[B:%.*]] to i8
; CHECK-NEXT:    call void @use(i8 [[S]])
; CHECK-NEXT:    [[R:%.*]] = icmp uge i8 [[S]], [[X:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %s = sext i1 %b to i8
  call void @use(i8 %s)
  %r = icmp uge i8 %s, %x
  ret i1 %r
}

; negative test - must be sext of i1

define i1 @ule_sext_not_i1(i2 %b, i8 %x) {
; CHECK-LABEL: @ule_sext_not_i1(
; CHECK-NEXT:    [[S:%.*]] = sext i2 [[B:%.*]] to i8
; CHECK-NEXT:    [[R:%.*]] = icmp uge i8 [[S]], [[X:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %s = sext i2 %b to i8
  %r = icmp ule i8 %x, %s
  ret i1 %r
}

; sub is eliminated

define i1 @sub_ule_sext(i1 %b, i8 %x, i8 %y) {
; CHECK-LABEL: @sub_ule_sext(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = or i1 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %s = sext i1 %b to i8
  %d = sub i8 %x, %y
  %r = icmp ule i8 %d, %s
  ret i1 %r
}

define i1 @sext_ule_sext(i1 %b, i8 %p) {
; CHECK-LABEL: @sext_ule_sext(
; CHECK-NEXT:    [[X:%.*]] = mul i8 [[P:%.*]], [[P]]
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[X]], 0
; CHECK-NEXT:    [[R:%.*]] = or i1 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %x = mul i8 %p, %p ; thwart complexity-based canonicalization
  %s = sext i1 %b to i16
  %sx = sext i8 %x to i16
  %r = icmp ule i16 %sx, %s
  ret i1 %r
}

; match and fold even if both sides are sexts (from different source types)

define i1 @sext_uge_sext(i1 %b, i4 %x) {
; CHECK-LABEL: @sext_uge_sext(
; CHECK-NEXT:    [[SX:%.*]] = sext i4 [[X:%.*]] to i8
; CHECK-NEXT:    call void @use(i8 [[SX]])
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i4 [[X]], 0
; CHECK-NEXT:    [[R:%.*]] = or i1 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %s = sext i1 %b to i8
  %sx = sext i4 %x to i8
  call void @use(i8 %sx)
  %r = icmp uge i8 %s, %sx
  ret i1 %r
}

; negative test - must be sext of i1

define i1 @sub_ule_sext_not_i1(i2 %b, i8 %x, i8 %y) {
; CHECK-LABEL: @sub_ule_sext_not_i1(
; CHECK-NEXT:    [[S:%.*]] = sext i2 [[B:%.*]] to i8
; CHECK-NEXT:    [[D:%.*]] = sub i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = icmp ule i8 [[D]], [[S]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %s = sext i2 %b to i8
  %d = sub i8 %x, %y
  %r = icmp ule i8 %d, %s
  ret i1 %r
}

; negative test - extra use (but we could try harder to fold this)

define i1 @sub_ule_sext_use1(i1 %b, i8 %x, i8 %y) {
; CHECK-LABEL: @sub_ule_sext_use1(
; CHECK-NEXT:    [[S:%.*]] = sext i1 [[B:%.*]] to i8
; CHECK-NEXT:    call void @use(i8 [[S]])
; CHECK-NEXT:    [[D:%.*]] = sub i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = icmp ule i8 [[D]], [[S]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %s = sext i1 %b to i8
  call void @use(i8 %s)
  %d = sub i8 %x, %y
  %r = icmp ule i8 %d, %s
  ret i1 %r
}

define <2 x i1> @sext_uge_sub_use2(<2 x i1> %b, <2 x i8> %x, <2 x i8> %y) {
; CHECK-LABEL: @sext_uge_sub_use2(
; CHECK-NEXT:    [[D:%.*]] = sub <2 x i8> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    call void @use_vec(<2 x i8> [[D]])
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq <2 x i8> [[X]], [[Y]]
; CHECK-NEXT:    [[R:%.*]] = or <2 x i1> [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %s = sext <2 x i1> %b to <2 x i8>
  %d = sub <2 x i8> %x, %y
  call void @use_vec(<2 x i8> %d)
  %r = icmp uge <2 x i8> %s, %d
  ret <2 x i1> %r
}

define i1 @sub_ule_sext_use3(i1 %b, i8 %x, i8 %y) {
; CHECK-LABEL: @sub_ule_sext_use3(
; CHECK-NEXT:    [[S:%.*]] = sext i1 [[B:%.*]] to i8
; CHECK-NEXT:    call void @use(i8 [[S]])
; CHECK-NEXT:    [[D:%.*]] = sub i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    call void @use(i8 [[D]])
; CHECK-NEXT:    [[R:%.*]] = icmp ule i8 [[D]], [[S]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %s = sext i1 %b to i8
  call void @use(i8 %s)
  %d = sub i8 %x, %y
  call void @use(i8 %d)
  %r = icmp ule i8 %d, %s
  ret i1 %r
}

define i1 @sub_ult_sext(i1 %b, i8 %x, i8 %y) {
; CHECK-LABEL: @sub_ult_sext(
; CHECK-NEXT:    [[S:%.*]] = sext i1 [[B:%.*]] to i8
; CHECK-NEXT:    [[D:%.*]] = sub i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = icmp ult i8 [[D]], [[S]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %s = sext i1 %b to i8
  %d = sub i8 %x, %y
  %r = icmp ult i8 %d, %s
  ret i1 %r
}

define <2 x i1> @sub_ule_ashr(<2 x i8> %b, <2 x i8> %x, <2 x i8> %y) {
; CHECK-LABEL: @sub_ule_ashr(
; CHECK-NEXT:    [[A:%.*]] = ashr <2 x i8> [[B:%.*]], <i8 7, i8 7>
; CHECK-NEXT:    [[S:%.*]] = sub <2 x i8> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = icmp ule <2 x i8> [[S]], [[A]]
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %a = ashr <2 x i8> %b, <i8 7, i8 7>
  %s = sub <2 x i8> %x, %y
  %r = icmp ule <2 x i8> %s, %a
  ret <2 x i1> %r
}

define i1 @ashr_uge_sub(i8 %b, i8 %x, i8 %y) {
; CHECK-LABEL: @ashr_uge_sub(
; CHECK-NEXT:    [[A:%.*]] = ashr i8 [[B:%.*]], 7
; CHECK-NEXT:    [[S:%.*]] = sub i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = icmp uge i8 [[A]], [[S]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %a = ashr i8 %b, 7
  %s = sub i8 %x, %y
  %r = icmp uge i8 %a, %s
  ret i1 %r
}

; (zext i1 a) + (sext i1 b)) s< -1 --> false

define i1 @zext_sext_add_icmp_slt_minus1(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_slt_minus1(
; CHECK-NEXT:    ret i1 false
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  %r = icmp slt i8 %add, -1
  ret i1 %r
}

; (zext i1 a) + (sext i1 b)) s> 1 --> false

define i1 @zext_sext_add_icmp_sgt_1(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_sgt_1(
; CHECK-NEXT:    ret i1 false
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  %r = icmp sgt i8 %add, 1
  ret i1 %r
}

; (zext i1 a) + (sext i1 b)) s> -2 --> true

define i1 @zext_sext_add_icmp_sgt_minus2(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_sgt_minus2(
; CHECK-NEXT:    ret i1 true
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  %r = icmp sgt i8 %add, -2
  ret i1 %r
}

; (zext i1 a) + (sext i1 b)) s< 2 --> true

define i1 @zext_sext_add_icmp_slt_2(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_slt_2(
; CHECK-NEXT:    ret i1 true
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  %r = icmp slt i8 %add, 2
  ret i1 %r
}

; test case with i128

define i1 @zext_sext_add_icmp_i128(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_i128(
; CHECK-NEXT:    ret i1 false
;
  %zext.a = zext i1 %a to i128
  %sext.b = sext i1 %b to i128
  %add = add i128 %zext.a, %sext.b
  %r = icmp sgt i128 %add, 9223372036854775808
  ret i1 %r
}

; (zext i1 a) + (sext i1 b)) == -1 --> ~a & b

define i1 @zext_sext_add_icmp_eq_minus1(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_eq_minus1(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i1 [[A:%.*]], true
; CHECK-NEXT:    [[R:%.*]] = and i1 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  %r = icmp eq i8 %add, -1
  ret i1 %r
}


; (zext i1 a) + (sext i1 b)) != -1 --> a | ~b

define i1 @zext_sext_add_icmp_ne_minus1(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_ne_minus1(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i1 [[B:%.*]], true
; CHECK-NEXT:    [[R:%.*]] = or i1 [[TMP1]], [[A:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  %r = icmp ne i8 %add, -1
  ret i1 %r
}

; (zext i1 a) + (sext i1 b)) s> -1 --> a | ~b

define i1 @zext_sext_add_icmp_sgt_minus1(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_sgt_minus1(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i1 [[B:%.*]], true
; CHECK-NEXT:    [[R:%.*]] = or i1 [[TMP1]], [[A:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  %r = icmp sgt i8 %add, -1
  ret i1 %r
}

; (zext i1 a) + (sext i1 b)) u< -1 --> a | ~b

define i1 @zext_sext_add_icmp_ult_minus1(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_ult_minus1(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i1 [[B:%.*]], true
; CHECK-NEXT:    [[R:%.*]] = or i1 [[TMP1]], [[A:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  %r = icmp ult i8 %add, -1
  ret i1 %r
}

; (zext i1 a) + (sext i1 b)) s> 0 --> a & ~b

define i1 @zext_sext_add_icmp_sgt_0(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_sgt_0(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i1 [[B:%.*]], true
; CHECK-NEXT:    [[R:%.*]] = and i1 [[TMP1]], [[A:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  %r = icmp sgt i8 %add, 0
  ret i1 %r
}

; (zext i1 a) + (sext i1 b)) s< 0 --> ~a & b

define i1 @zext_sext_add_icmp_slt_0(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_slt_0(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i1 [[A:%.*]], true
; CHECK-NEXT:    [[R:%.*]] = and i1 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  %r = icmp slt i8 %add, 0
  ret i1 %r
}

; (zext i1 a) + (sext i1 b)) == 1 --> a & ~b

define i1 @zext_sext_add_icmp_eq_1(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_eq_1(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i1 [[B:%.*]], true
; CHECK-NEXT:    [[R:%.*]] = and i1 [[TMP1]], [[A:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  %r = icmp eq i8 %add, 1
  ret i1 %r
}

; (zext i1 a) + (sext i1 b)) != 1 --> ~a | b

define i1 @zext_sext_add_icmp_ne_1(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_ne_1(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i1 [[A:%.*]], true
; CHECK-NEXT:    [[R:%.*]] = or i1 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  %r = icmp ne i8 %add, 1
  ret i1 %r
}

; (zext i1 a) + (sext i1 b)) s< 1 --> ~a | b

define i1 @zext_sext_add_icmp_slt_1(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_slt_1(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i1 [[A:%.*]], true
; CHECK-NEXT:    [[R:%.*]] = or i1 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  %r = icmp slt i8 %add, 1
  ret i1 %r
}

; (zext i1 a) + (sext i1 b)) u> 1 --> ~a & b

define i1 @zext_sext_add_icmp_ugt_1(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_ugt_1(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i1 [[A:%.*]], true
; CHECK-NEXT:    [[R:%.*]] = and i1 [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  %r = icmp ugt i8 %add, 1
  ret i1 %r
}

define <2 x i1> @vector_zext_sext_add_icmp_slt_1(<2 x i1> %a, <2 x i1> %b) {
; CHECK-LABEL: @vector_zext_sext_add_icmp_slt_1(
; CHECK-NEXT:    [[TMP1:%.*]] = xor <2 x i1> [[A:%.*]], <i1 true, i1 true>
; CHECK-NEXT:    [[R:%.*]] = or <2 x i1> [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %zext.a = zext <2 x i1> %a to <2 x i8>
  %sext.b = sext <2 x i1> %b to <2 x i8>
  %add = add <2 x i8> %zext.a, %sext.b
  %r = icmp slt <2 x i8> %add, <i8 1, i8 1>
  ret <2 x i1> %r
}

define <2 x i1> @vector_zext_sext_add_icmp_slt_1_poison(<2 x i1> %a, <2 x i1> %b) {
; CHECK-LABEL: @vector_zext_sext_add_icmp_slt_1_poison(
; CHECK-NEXT:    [[ZEXT_A:%.*]] = zext <2 x i1> [[A:%.*]] to <2 x i8>
; CHECK-NEXT:    [[SEXT_B:%.*]] = sext <2 x i1> [[B:%.*]] to <2 x i8>
; CHECK-NEXT:    [[ADD:%.*]] = add nsw <2 x i8> [[ZEXT_A]], [[SEXT_B]]
; CHECK-NEXT:    [[R:%.*]] = icmp slt <2 x i8> [[ADD]], <i8 1, i8 poison>
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %zext.a = zext <2 x i1> %a to <2 x i8>
  %sext.b = sext <2 x i1> %b to <2 x i8>
  %add = add <2 x i8> %zext.a, %sext.b
  %r = icmp slt <2 x i8> %add, <i8 1, i8 poison>
  ret <2 x i1> %r
}

define i1 @zext_sext_add_icmp_slt_minus_1_no_oneuse(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_slt_minus_1_no_oneuse(
; CHECK-NEXT:    [[ZEXT_A:%.*]] = zext i1 [[A:%.*]] to i8
; CHECK-NEXT:    [[SEXT_B:%.*]] = sext i1 [[B:%.*]] to i8
; CHECK-NEXT:    [[ADD:%.*]] = add nsw i8 [[ZEXT_A]], [[SEXT_B]]
; CHECK-NEXT:    call void @use(i8 [[ADD]])
; CHECK-NEXT:    ret i1 false
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  call void @use(i8 %add)
  %r = icmp slt i8 %add, -1
  ret i1 %r
}

define i1 @zext_sext_add_icmp_sgt_1_no_oneuse(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_sgt_1_no_oneuse(
; CHECK-NEXT:    [[ZEXT_A:%.*]] = zext i1 [[A:%.*]] to i8
; CHECK-NEXT:    [[SEXT_B:%.*]] = sext i1 [[B:%.*]] to i8
; CHECK-NEXT:    [[ADD:%.*]] = add nsw i8 [[ZEXT_A]], [[SEXT_B]]
; CHECK-NEXT:    call void @use(i8 [[ADD]])
; CHECK-NEXT:    ret i1 false
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  call void @use(i8 %add)
  %r = icmp sgt i8 %add, 1
  ret i1 %r
}

define i1 @zext_sext_add_icmp_slt_2_no_oneuse(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_slt_2_no_oneuse(
; CHECK-NEXT:    [[ZEXT_A:%.*]] = zext i1 [[A:%.*]] to i8
; CHECK-NEXT:    [[SEXT_B:%.*]] = sext i1 [[B:%.*]] to i8
; CHECK-NEXT:    [[ADD:%.*]] = add nsw i8 [[ZEXT_A]], [[SEXT_B]]
; CHECK-NEXT:    call void @use(i8 [[ADD]])
; CHECK-NEXT:    ret i1 true
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  call void @use(i8 %add)
  %r = icmp slt i8 %add, 2
  ret i1 %r
}

define i1 @zext_sext_add_icmp_sgt_mins_2_no_oneuse(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_sgt_mins_2_no_oneuse(
; CHECK-NEXT:    [[ZEXT_A:%.*]] = zext i1 [[A:%.*]] to i8
; CHECK-NEXT:    [[SEXT_B:%.*]] = sext i1 [[B:%.*]] to i8
; CHECK-NEXT:    [[ADD:%.*]] = add nsw i8 [[ZEXT_A]], [[SEXT_B]]
; CHECK-NEXT:    call void @use(i8 [[ADD]])
; CHECK-NEXT:    ret i1 true
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  call void @use(i8 %add)
  %r = icmp sgt i8 %add, -2
  ret i1 %r
}

; Negative test, more than one use for icmp LHS

define i1 @zext_sext_add_icmp_slt_1_no_oneuse(i1 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_slt_1_no_oneuse(
; CHECK-NEXT:    [[ZEXT_A:%.*]] = zext i1 [[A:%.*]] to i8
; CHECK-NEXT:    [[SEXT_B:%.*]] = sext i1 [[B:%.*]] to i8
; CHECK-NEXT:    [[ADD:%.*]] = add nsw i8 [[ZEXT_A]], [[SEXT_B]]
; CHECK-NEXT:    call void @use(i8 [[ADD]])
; CHECK-NEXT:    [[R:%.*]] = icmp slt i8 [[ADD]], 1
; CHECK-NEXT:    ret i1 [[R]]
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  call void @use(i8 %add)
  %r = icmp slt i8 %add, 1
  ret i1 %r
}

; Negative test, icmp RHS is not a constant

define i1 @zext_sext_add_icmp_slt_1_rhs_not_const(i1 %a, i1 %b, i8 %c) {
; CHECK-LABEL: @zext_sext_add_icmp_slt_1_rhs_not_const(
; CHECK-NEXT:    [[ZEXT_A:%.*]] = zext i1 [[A:%.*]] to i8
; CHECK-NEXT:    [[SEXT_B:%.*]] = sext i1 [[B:%.*]] to i8
; CHECK-NEXT:    [[ADD:%.*]] = add nsw i8 [[ZEXT_A]], [[SEXT_B]]
; CHECK-NEXT:    [[R:%.*]] = icmp slt i8 [[ADD]], [[C:%.*]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %zext.a = zext i1 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  %r = icmp slt i8 %add, %c
  ret i1 %r
}

; Negative test, ext source is not i1

define i1 @zext_sext_add_icmp_slt_1_type_not_i1(i2 %a, i1 %b) {
; CHECK-LABEL: @zext_sext_add_icmp_slt_1_type_not_i1(
; CHECK-NEXT:    [[ZEXT_A:%.*]] = zext i2 [[A:%.*]] to i8
; CHECK-NEXT:    [[SEXT_B:%.*]] = sext i1 [[B:%.*]] to i8
; CHECK-NEXT:    [[ADD:%.*]] = add nsw i8 [[ZEXT_A]], [[SEXT_B]]
; CHECK-NEXT:    [[R:%.*]] = icmp slt i8 [[ADD]], 1
; CHECK-NEXT:    ret i1 [[R]]
;
  %zext.a = zext i2 %a to i8
  %sext.b = sext i1 %b to i8
  %add = add i8 %zext.a, %sext.b
  %r = icmp slt i8 %add, 1
  ret i1 %r
}

define i1 @icmp_eq_bool_0(ptr %ptr) {
; CHECK-LABEL: @icmp_eq_bool_0(
; CHECK-NEXT:    [[VAL:%.*]] = load i64, ptr [[PTR:%.*]], align 8, !range [[RNG6:![0-9]+]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[VAL]], 0
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %val = load i64, ptr %ptr, align 8, !range !{i64 0, i64 2}
  %cmp = icmp eq i64 %val, 0
  ret i1 %cmp
}

define i1 @icmp_eq_bool_1(ptr %ptr) {
; CHECK-LABEL: @icmp_eq_bool_1(
; CHECK-NEXT:    [[VAL:%.*]] = load i64, ptr [[PTR:%.*]], align 8, !range [[RNG6]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i64 [[VAL]], 0
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %val = load i64, ptr %ptr, align 8, !range !{i64 0, i64 2}
  %cmp = icmp eq i64 %val, 1
  ret i1 %cmp
}

define i1 @icmp_ne_bool_0(ptr %ptr) {
; CHECK-LABEL: @icmp_ne_bool_0(
; CHECK-NEXT:    [[VAL:%.*]] = load i64, ptr [[PTR:%.*]], align 8, !range [[RNG6]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i64 [[VAL]], 0
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %val = load i64, ptr %ptr, align 8, !range !{i64 0, i64 2}
  %cmp = icmp ne i64 %val, 0
  ret i1 %cmp
}

define i1 @icmp_ne_bool_1(ptr %ptr) {
; CHECK-LABEL: @icmp_ne_bool_1(
; CHECK-NEXT:    [[VAL:%.*]] = load i64, ptr [[PTR:%.*]], align 8, !range [[RNG6]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[VAL]], 0
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %val = load i64, ptr %ptr, align 8, !range !{i64 0, i64 2}
  %cmp = icmp ne i64 %val, 1
  ret i1 %cmp
}

!0 = !{i32 1, i32 6}
!1 = !{i32 0, i32 6}
!2 = !{i8 0, i8 1}
!3 = !{i8 0, i8 6}
!4 = !{i32 1, i32 6, i32 8, i32 10}
!5 = !{i32 5, i32 10}
!6 = !{i32 8, i32 16}