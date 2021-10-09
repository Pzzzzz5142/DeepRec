#!/bin/bash
# Copyright 2021 Alibaba Group Holding Limited. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# =============================================================================

set -eo pipefail

export TF_NEED_TENSORRT=0
export TF_NEED_ROCM=0
export TF_NEED_COMPUTECPP=0
export TF_NEED_OPENCL=0
export TF_NEED_OPENCL_SYCL=0
export TF_ENABLE_XLA=1
export TF_NEED_MPI=0

yes "" | bash ./configure || true

if [[ ! -z "$BAZEL_CACHE" ]]; then
  wget -nv -O cibuild/bazel_cache.tar $BAZEL_CACHE
  tar -xf cibuild/bazel_cache.tar -C $(bazel info output_base)/../cache
fi

set -x

mkdir -p cibuild/cache
bazel build \
--disk_cache=cibuild/cache \
--config=nogcp \
--verbose_failures \
//tensorflow/tools/pip_package:build_pip_package \
--copt="-march=native" \
--copt="-Wno-sign-compare"

bazel-bin/tensorflow/tools/pip_package/build_pip_package \
cibuild/

