// RUN: mlir-opt %s -split-input-file -verify-diagnostics | FileCheck %s

// -----

// CHECK-LABEL: @tuple_success
func @tuple_success() {
  %0 = "test.tuple_32_bit"() : () -> (tuple<i32>)
  return
}

// -----

// CHECK-LABEL: @tuple_mixed_success
func @tuple_mixed_success() {
  %0 = "test.tuple_32_bit"() : () -> (tuple<i32, f32>)
  return
}

// -----

func @tuple_empty_success() {
  %0 = "test.tuple_32_bit"() : () -> (tuple<>)
  return
}

// -----

func @tuple_wrong_type_scalar() {
  // expected-error@+1 {{must be tuple with any combination of 32-bit integer or 32-bit float values}}
  %0 = "test.tuple_32_bit"() : () -> (tuple<i64>)
  return
}

// -----

func @tuple_wrong_type_tensor() {
  // expected-error@+1 {{must be tuple with any combination of 32-bit integer or 32-bit float values}}
  %0 = "test.tuple_32_bit"() : () -> (tuple<tensor<i32>>)
  return
}

// -----

// CHECK-LABEL: @nested_tuple_empty_success
func @nested_tuple_empty_success() {
  %0 = "test.nested_tuple_32_bit"() : () -> (tuple<>)
  return
}

// -----

// CHECK-LABEL: @nested_tuple_one_level_success
func @nested_tuple_one_level_success() {
  %0 = "test.nested_tuple_32_bit"() : () -> (tuple<i32>)
  return
}

// -----

// CHECK-LABEL: @nested_tuple_multi_level_success
func @nested_tuple_multi_level_success() {
  %0 = "test.nested_tuple_32_bit"() : () -> (tuple<i32, tuple<i32, tuple<i32>>>)
  return
}

// -----

// CHECK-LABEL: @nested_tuple_multi_level_mixed_success
func @nested_tuple_multi_level_mixed_success() {
  %0 = "test.nested_tuple_32_bit"() : () -> (tuple<i32, tuple<f32, tuple<i32>>>)
  return
}

// -----

func @nested_tuple_multi_level_wrong_type() {
  // expected-error@+1 {{must be nested tuple with any combination of 32-bit integer or 32-bit float values}}
  %0 = "test.nested_tuple_32_bit"() : () -> (tuple<i32, tuple<i32, tuple<i64>>>)
  return
}

// -----

// CHECK-LABEL: func @rank_less_than_2_I8_F32_memref_success
func @rank_less_than_2_I8_F32_memref_success() {
  "test.rank_less_than_2_I8_F32_memref"() : () -> (memref<i8>)
  "test.rank_less_than_2_I8_F32_memref"() : () -> (memref<3xi8>)
  "test.rank_less_than_2_I8_F32_memref"() : () -> (memref<f32>)
  "test.rank_less_than_2_I8_F32_memref"() : () -> (memref<1xf32>)
  return
}

// -----

func @rank_less_than_2_I8_F32_memref_bad_type() {
  // expected-error@+1 {{must be 0D/1D memref of 8-bit integer or 32-bit float values}}
  "test.rank_less_than_2_I8_F32_memref"() : () -> (memref<i16>)
  return
}

// -----

func @rank_less_than_2_I8_F32_memref_bad_rank() {
  // expected-error@+1 {{must be 0D/1D memref of 8-bit integer or 32-bit float values}}
  "test.rank_less_than_2_I8_F32_memref"() : () -> (memref<1x2xi8>)
  return
}

// -----

func @nd_tensor_of_success(%arg0: tensor<f32>, %arg1: tensor<10xf32>, %arg2: tensor<20x30xi16>, %arg3: tensor<40x50x60xi16>, %arg4: tensor<70x80x90x100xi16>) {
  "test.nd_tensor_of"(%arg0, %arg1, %arg2, %arg3, %arg4) : (tensor<f32>, tensor<10xf32>, tensor<20x30xi16>, tensor<40x50x60xi16>, tensor<70x80x90x100xi16>) -> ()
  return
}

// -----

func @nd_tensor_of_success_wrong_type_0d(%arg0: tensor<f32>, %arg1: tensor<10xf32>, %arg2: tensor<20x30xi16>, %arg3: tensor<40x50x60xi16>, %arg4: tensor<70x80x90x100xi32>) {
  // expected-error @+1 {{'test.nd_tensor_of' op operand #0 must be 0D tensor of 32-bit float values}}
  "test.nd_tensor_of"(%arg1, %arg1, %arg2, %arg3, %arg4) : (tensor<10xf32>, tensor<10xf32>, tensor<20x30xi16>, tensor<40x50x60xi16>, tensor<70x80x90x100xi32>) -> ()
  return
}

// -----

func @nd_tensor_of_success_wrong_type_4d(%arg0: tensor<f32>, %arg1: tensor<10xf32>, %arg2: tensor<20x30xi16>, %arg3: tensor<40x50x60xi16>, %arg4: tensor<70x80x90x100xi32>) {
  // expected-error @+1 {{'test.nd_tensor_of' op operand #4 must be 4D tensor of 16-bit integer values}}
  "test.nd_tensor_of"(%arg0, %arg1, %arg2, %arg3, %arg3) : (tensor<f32>, tensor<10xf32>, tensor<20x30xi16>, tensor<40x50x60xi16>, tensor<40x50x60xi16>) -> ()
  return
}

// -----

func @multi_tensor_rank_of_success(%arg0: tensor<i8>, %arg1: tensor<i32>, %arg2: tensor<f32>, %arg3: tensor<1xi8>, %arg4: tensor<1xi32>, %arg5: tensor<1xf32>) {
  "test.multi_tensor_rank_of"(%arg0) : (tensor<i8>) -> ()
  "test.multi_tensor_rank_of"(%arg1) : (tensor<i32>) -> ()
  "test.multi_tensor_rank_of"(%arg2) : (tensor<f32>) -> ()
  "test.multi_tensor_rank_of"(%arg3) : (tensor<1xi8>) -> ()
  "test.multi_tensor_rank_of"(%arg4) : (tensor<1xi32>) -> ()
  "test.multi_tensor_rank_of"(%arg5) : (tensor<1xf32>) -> ()
  return
}

// -----

func @multi_tensor_rank_of_wrong_unranked_type(%arg0: tensor<2x2xi8>) {
  // expected-error @+1 {{'test.multi_tensor_rank_of' op operand #0 must be 0D/1D tensor of 8-bit integer or 32-bit integer or 32-bit float values}}
  "test.multi_tensor_rank_of"(%arg0) : (tensor<2x2xi8>) -> ()
  return
}

// -----

func @multi_tensor_rank_of_wrong_element_type(%arg0: tensor<2xi16>) {
  // expected-error @+1 {{'test.multi_tensor_rank_of' op operand #0 must be 0D/1D tensor of 8-bit integer or 32-bit integer or 32-bit float values}}
  "test.multi_tensor_rank_of"(%arg0) : (tensor<2xi16>) -> ()
  return
}

// -----

// CHECK-LABEL: @fixed_element_types
func @fixed_element_types(%arg0: tensor<* x i32>, %arg1: tensor<* x f32>) {
  %0 = "test.arg_and_res_have_fixed_element_types"(%arg0, %arg1) {attr = ""} : (tensor<* x i32>, tensor<* x f32>) -> tensor<* x i16>
  return
}

// -----

func @fixed_element_types(%arg0: tensor<* x i32>, %arg1: tensor<* x f32>) {
  // expected-error@+1 {{'res' is 16-bit integer}}
  %0 = "test.arg_and_res_have_fixed_element_types"(%arg0, %arg1) {attr = ""}: (tensor<* x i32>, tensor<* x f32>) -> tensor<* x i32>
  return
}

// -----

func @fixed_element_types(%arg0: tensor<* x i32>, %arg1: tensor<* x f32>) {
  // expected-error@+1 {{fixed type combination}}
  %0 = "test.arg_and_res_have_fixed_element_types"(%arg1, %arg0) {attr = ""}: (tensor<* x f32>, tensor<* x i32>) -> tensor<* x i16>
  return
}

// -----

func @same_element_types(%arg0: tensor<* x i32>, %arg1: tensor<* x f32>) {
  // expected-error@+1 {{verify that all of {x, y} have same element type}}
  "test.operands_have_same_element_type"(%arg1, %arg0): (tensor<* x f32>, tensor<* x i32>) -> ()
  return
}

// -----

// CHECK-LABEL: same_element_types
func @same_element_types(%arg0: tensor<* x i32>, %arg1: tensor<* x f32>) {
  %0 = "test.operand_one_and_result_have_same_element_type"(%arg1, %arg0) : (tensor<* x f32>, tensor<* x i32>) -> tensor<* x f32>
  return
}

// -----

func @same_element_types(%arg0: tensor<* x i32>, %arg1: tensor<* x f32>) {
  // expected-error@+1 {{all of {x, res} have same element type}}
  %0 = "test.operand_one_and_result_have_same_element_type"(%arg1, %arg0) : (tensor<* x f32>, tensor<* x i32>) -> tensor<* x i32>
  return
}

// -----

// CHECK-LABEL: same_types
func @same_types(%arg0: tensor<* x i32>, %arg1: tensor<* x i32>) {
  "test.operands_have_same_type"(%arg0, %arg1) : (tensor<* x i32>, tensor<* x i32>) -> ()
  return
}

// -----

func @same_types_element_mismatch(%arg0: tensor<* x i32>, %arg1: tensor<* x f32>) {
  // expected-error@+1 {{all of {x, y} have same type}}
  "test.operands_have_same_type"(%arg0, %arg1) : (tensor<* x i32>, tensor<* x f32>) -> ()
  return
}

// -----

func @same_types_shape_mismatch(%arg0: tensor<1x2xi32>, %arg1: tensor<2x1xi32>) {
  // expected-error@+1 {{all of {x, y} have same type}}
  "test.operands_have_same_type"(%arg0, %arg1) : (tensor<1x2xi32>, tensor<2x1xi32>) -> ()
  return
}

// -----

// CHECK-LABEL: same_types
func @same_types(%arg0: tensor<* x i32>, %arg1: tensor<* x f32>) {
  %0 = "test.operand_one_and_result_have_same_type"(%arg0, %arg1) : (tensor<* x i32>, tensor<* x f32>) -> tensor<* x i32>
  return
}

// -----

// CHECK-LABEL: operands_have_same_rank_success
func @operands_have_same_rank_success(%arg0: tensor<1xi32>, %arg1: tensor<2xf32>) {
  "test.operands_have_same_rank"(%arg0, %arg1) : (tensor<1xi32>, tensor<2xf32>) -> ()
  return
}

// -----

func @operands_have_same_rank_failure(%arg0: tensor<1xi32>, %arg1: tensor<1x2xf32>) {
  // expected-error@+1 {{all of {x, y} have same rank}}
  "test.operands_have_same_rank"(%arg0, %arg1) : (tensor<1xi32>, tensor<1x2xf32>) -> ()
  return
}

// -----

// CHECK-LABEL: operand1_and_result_have_same_rank_success
func @operand1_and_result_have_same_rank_success(%arg0: tensor<1xi32>, %arg1: tensor<1x2xf32>, %arg3: tensor<1x2xi32>) {
  "test.operand1_and_result_have_same_rank"(%arg0, %arg1) : (tensor<1xi32>, tensor<1x2xf32>) -> (tensor<3xf32>)
  "test.operand1_and_result_have_same_rank"(%arg3, %arg1) : (tensor<1x2xi32>, tensor<1x2xf32>) -> (tensor<3x3xf64>)
  return
}

// -----

func @operand1_and_result_have_same_rank_failure(%arg0: tensor<1xi32>, %arg1: tensor<1x2xf32>) {
  // expected-error@+1 {{all of {x, res} have same rank}}
  "test.operand1_and_result_have_same_rank"(%arg0, %arg1) : (tensor<1xi32>, tensor<1x2xf32>) -> (tensor<i32>)
  return
}

// -----

func @operand1_and_result_have_same_rank_failure(%arg0: tensor<1x2xi32>, %arg1: tensor<1x2xf32>) {
  // expected-error@+1 {{all of {x, res} have same rank}}
  "test.operand1_and_result_have_same_rank"(%arg0, %arg1) : (tensor<1x2xi32>, tensor<1x2xf32>) -> (tensor<3xi32>)
  return
}

// -----

// CHECK-LABEL: operand1_and_result_have_same_element_count_success
func @operand1_and_result_have_same_element_count_success(%arg0: tensor<36xi32>, %arg1: tensor<1x2xf32>, %arg3: tensor<f32>) {
  "test.operand1_and_result_have_same_element_count"(%arg0, %arg1) : (tensor<36xi32>, tensor<1x2xf32>) -> (tensor<3x4x3xf32>)
  "test.operand1_and_result_have_same_element_count"(%arg0, %arg1) : (tensor<36xi32>, tensor<1x2xf32>) -> (tensor<3x12xf64>)
  "test.operand1_and_result_have_same_element_count"(%arg3, %arg1) : (tensor<f32>, tensor<1x2xf32>) -> (tensor<1x1x1xi32>)
  return
}

// -----

func @operand1_and_result_have_same_element_count_failure(%arg0: tensor<1xi32>, %arg1: tensor<1x2xf32>) {
  // expected-error@+1 {{all of {x, res} have same element count}}
  "test.operand1_and_result_have_same_element_count"(%arg0, %arg1) : (tensor<1xi32>, tensor<1x2xf32>) -> (tensor<2xi32>)
  return
}

// -----

func @four_equals_five() {
  // expected-error@+1 {{failed to verify that 4 equals 5}}
  "test.four_equals_five"() : () -> ()
  return
}

// -----

func @operand_rank_equals_result_size_success(%arg : tensor<1x2x3x4xi32>) {
  %0 = "test.operand_rank_equals_result_size"(%arg) : (tensor<1x2x3x4xi32>) -> tensor<4xi32>
  %1 = "test.operand_rank_equals_result_size"(%arg) : (tensor<1x2x3x4xi32>) -> tensor<2x2xf32>
  return
}

// -----

func @operand_rank_equals_result_size_failure(%arg : tensor<1x2x3x4xi32>) {
  // expected-error@+1 {{failed to verify that operand rank equals result size}}
  %0 = "test.operand_rank_equals_result_size"(%arg) : (tensor<1x2x3x4xi32>) -> tensor<2xi32>
  return
}

// -----

func @same_types_element_mismatch(%arg0: tensor<* x i32>, %arg1: tensor<* x f32>) {
  // expected-error@+1 {{all of {x, res} have same type}}
  %0 = "test.operand_one_and_result_have_same_type"(%arg0, %arg1) : (tensor<* x i32>, tensor<* x f32>) -> tensor<* x f32>
  return
}

// -----

func @same_types_shape_mismatch(%arg0: tensor<1x2xi32>, %arg1: tensor<2x1xi32>) {
  // expected-error@+1 {{all of {x, res} have same type}}
  %0 = "test.operand_one_and_result_have_same_type"(%arg0, %arg1) : (tensor<1x2xi32>, tensor<2x1xi32>) -> tensor<2x1xi32>
  return
}

// -----

func @does_not_have_i32(%arg0: tensor<1x2xi32>, %arg1: none) {
  // expected-error@+1 {{either both none type operands or first is not none}}
  "test.if_first_operand_is_none_then_so_is_second"(%arg1, %arg0) : (none, tensor<1x2xi32>) -> ()
  return
}

// -----

func @does_not_have_static_memref(%arg0: memref<?xi32>) {
  // expected-error@+1 {{'test.takes_static_memref' op operand #0 must be statically shaped memref of any type values}}
  "test.takes_static_memref"(%arg0) : (memref<?xi32>) -> ()
}

// -----

func @elements_attr_not_i32_f32() {
  // expected-error@+1 {{32-bit integer elements attribute}}
  "test.i32ElementsAttr"() {attr = dense<[1.0, 20.0]>:tensor<2xf32>} : () -> ()
  return
}

// -----

func @elements_attr_not_i32_i64() {
  // expected-error@+1 {{32-bit integer elements attribute}}
  "test.i32ElementsAttr"() {attr = dense<[1, 20]>:tensor<2xi64>} : () -> ()
  return
}


// -----

func @elements_attr_i32(%arg0: tensor<1x2xi32>) {
  "test.i32ElementsAttr"() {attr = dense<[1, 2]>:tensor<2xi32>} : () -> ()
  return
}
