// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %clang_cc1 -triple riscv64 -target-feature +zbb -emit-llvm %s -o - \
// RUN:     | FileCheck %s  -check-prefix=RV64ZBB

// RV64ZBB-LABEL: @orc_b_32(
// RV64ZBB-NEXT:  entry:
// RV64ZBB-NEXT:    [[A_ADDR:%.*]] = alloca i32, align 4
// RV64ZBB-NEXT:    store i32 [[A:%.*]], ptr [[A_ADDR]], align 4
// RV64ZBB-NEXT:    [[TMP0:%.*]] = load i32, ptr [[A_ADDR]], align 4
// RV64ZBB-NEXT:    [[TMP1:%.*]] = call i32 @llvm.riscv.orc.b.i32(i32 [[TMP0]])
// RV64ZBB-NEXT:    ret i32 [[TMP1]]
//
unsigned int orc_b_32(unsigned int a) {
  return __builtin_riscv_orc_b_32(a);
}

// RV64ZBB-LABEL: @orc_b_64(
// RV64ZBB-NEXT:  entry:
// RV64ZBB-NEXT:    [[A_ADDR:%.*]] = alloca i64, align 8
// RV64ZBB-NEXT:    store i64 [[A:%.*]], ptr [[A_ADDR]], align 8
// RV64ZBB-NEXT:    [[TMP0:%.*]] = load i64, ptr [[A_ADDR]], align 8
// RV64ZBB-NEXT:    [[TMP1:%.*]] = call i64 @llvm.riscv.orc.b.i64(i64 [[TMP0]])
// RV64ZBB-NEXT:    ret i64 [[TMP1]]
//
unsigned long orc_b_64(unsigned long a) {
  return __builtin_riscv_orc_b_64(a);
}

// RV64ZBB-LABEL: @clz_32(
// RV64ZBB-NEXT:  entry:
// RV64ZBB-NEXT:    [[A_ADDR:%.*]] = alloca i32, align 4
// RV64ZBB-NEXT:    store i32 [[A:%.*]], ptr [[A_ADDR]], align 4
// RV64ZBB-NEXT:    [[TMP0:%.*]] = load i32, ptr [[A_ADDR]], align 4
// RV64ZBB-NEXT:    [[TMP1:%.*]] = call i32 @llvm.ctlz.i32(i32 [[TMP0]], i1 false)
// RV64ZBB-NEXT:    ret i32 [[TMP1]]
//
unsigned int clz_32(unsigned int a) {
  return __builtin_riscv_clz_32(a);
}

// RV64ZBB-LABEL: @clz_64(
// RV64ZBB-NEXT:  entry:
// RV64ZBB-NEXT:    [[A_ADDR:%.*]] = alloca i64, align 8
// RV64ZBB-NEXT:    store i64 [[A:%.*]], ptr [[A_ADDR]], align 8
// RV64ZBB-NEXT:    [[TMP0:%.*]] = load i64, ptr [[A_ADDR]], align 8
// RV64ZBB-NEXT:    [[TMP1:%.*]] = call i64 @llvm.ctlz.i64(i64 [[TMP0]], i1 false)
// RV64ZBB-NEXT:    [[CAST:%.*]] = trunc i64 [[TMP1]] to i32
// RV64ZBB-NEXT:    ret i32 [[CAST]]
//
unsigned int clz_64(unsigned long a) {
  return __builtin_riscv_clz_64(a);
}

// RV64ZBB-LABEL: @ctz_32(
// RV64ZBB-NEXT:  entry:
// RV64ZBB-NEXT:    [[A_ADDR:%.*]] = alloca i32, align 4
// RV64ZBB-NEXT:    store i32 [[A:%.*]], ptr [[A_ADDR]], align 4
// RV64ZBB-NEXT:    [[TMP0:%.*]] = load i32, ptr [[A_ADDR]], align 4
// RV64ZBB-NEXT:    [[TMP1:%.*]] = call i32 @llvm.cttz.i32(i32 [[TMP0]], i1 false)
// RV64ZBB-NEXT:    ret i32 [[TMP1]]
//
unsigned int ctz_32(unsigned int a) {
  return __builtin_riscv_ctz_32(a);
}

// RV64ZBB-LABEL: @ctz_64(
// RV64ZBB-NEXT:  entry:
// RV64ZBB-NEXT:    [[A_ADDR:%.*]] = alloca i64, align 8
// RV64ZBB-NEXT:    store i64 [[A:%.*]], ptr [[A_ADDR]], align 8
// RV64ZBB-NEXT:    [[TMP0:%.*]] = load i64, ptr [[A_ADDR]], align 8
// RV64ZBB-NEXT:    [[TMP1:%.*]] = call i64 @llvm.cttz.i64(i64 [[TMP0]], i1 false)
// RV64ZBB-NEXT:    [[CAST:%.*]] = trunc i64 [[TMP1]] to i32
// RV64ZBB-NEXT:    ret i32 [[CAST]]
//
unsigned int ctz_64(unsigned long a) {
  return __builtin_riscv_ctz_64(a);
}