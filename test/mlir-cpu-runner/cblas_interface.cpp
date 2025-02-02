//===- cblas_interface.cpp - Simple Blas subset interface -----------------===//
//
// Copyright 2019 The MLIR Authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================
//
// Simple Blas subset interface implementation.
//
//===----------------------------------------------------------------------===//

#include "include/cblas.h"
#include <assert.h>

template <typename T, int N> struct ViewType {
  T *data;
  unsigned long offset;
  unsigned long sizes[N];
  unsigned long strides[N];
};

template <typename T> struct ViewType<T, 0> {
  T *data;
  unsigned long offset;
};

extern "C" void linalg_fill_viewf32_f32(ViewType<float, 0> *X, float f) {
  X->data[X->offset] = f;
}

extern "C" void linalg_fill_viewsxf32_f32(ViewType<float, 1> *X, float f) {
  for (unsigned i = 0; i < X->sizes[0]; ++i)
    *(X->data + X->offset + i * X->strides[0]) = f;
}

extern "C" void linalg_fill_viewsxsxf32_f32(ViewType<float, 2> *X, float f) {
  for (unsigned i = 0; i < X->sizes[0]; ++i)
    for (unsigned j = 0; j < X->sizes[1]; ++j)
      *(X->data + X->offset + i * X->strides[0] + j * X->strides[1]) = f;
}

extern "C" void linalg_copy_viewf32_viewf32(ViewType<float, 0> *I,
                                            ViewType<float, 0> *O) {
  O->data[O->offset] = I->data[I->offset];
}

extern "C" void linalg_copy_viewsxf32_viewsxf32(ViewType<float, 1> *I,
                                                ViewType<float, 1> *O) {
  assert(I->sizes[0] == O->sizes[0]);
  for (unsigned i = 0; i < I->sizes[0]; ++i)
    O->data[O->offset + i * O->strides[0]] =
        I->data[I->offset + i * I->strides[0]];
}

extern "C" void linalg_copy_viewsxsxf32_viewsxsxf32(ViewType<float, 2> *I,
                                                    ViewType<float, 2> *O) {
  assert(I->sizes[0] == O->sizes[0]);
  assert(I->sizes[1] == O->sizes[1]);
  auto so0 = O->strides[0], so1 = O->strides[1];
  auto si0 = I->strides[0], si1 = I->strides[1];
  for (unsigned i = 0; i < I->sizes[0]; ++i)
    for (unsigned j = 0; j < I->sizes[1]; ++j)
      O->data[O->offset + i * so0 + j * so1] =
          I->data[I->offset + i * si0 + j * si1];
}

extern "C" void linalg_dot_viewsxf32_viewsxf32_viewf32(ViewType<float, 1> *X,
                                                       ViewType<float, 1> *Y,
                                                       ViewType<float, 0> *Z) {
  assert(X->strides[0] == 1);
  assert(Y->strides[0] == 1);
  assert(X->sizes[0] == Y->sizes[0] && "Expected X and Y of same size");
  Z->data[Z->offset] +=
      cblas_sdot(X->sizes[0], X->data + X->offset, X->strides[0],
                 Y->data + Y->offset, Y->strides[0]);
}

extern "C" void linalg_matmul_viewsxsxf32_viewsxsxf32_viewsxsxf32(
    ViewType<float, 2> *A, ViewType<float, 2> *B, ViewType<float, 2> *C) {
  assert(A->strides[1] == B->strides[1]);
  assert(A->strides[1] == C->strides[1]);
  assert(A->strides[1] == 1);
  assert(A->sizes[0] >= A->strides[1]);
  assert(B->sizes[0] >= B->strides[1]);
  assert(C->sizes[0] >= C->strides[1]);
  assert(C->sizes[0] == A->sizes[0]);
  assert(C->sizes[1] == B->sizes[1]);
  assert(A->sizes[1] == B->sizes[0]);
  cblas_sgemm(CBLAS_ORDER::CblasRowMajor, CBLAS_TRANSPOSE::CblasNoTrans,
              CBLAS_TRANSPOSE::CblasNoTrans, C->sizes[0], C->sizes[1],
              A->sizes[1], 1.0f, A->data + A->offset, A->strides[0],
              B->data + B->offset, B->strides[0], 1.0f, C->data + C->offset,
              C->strides[0]);
}
