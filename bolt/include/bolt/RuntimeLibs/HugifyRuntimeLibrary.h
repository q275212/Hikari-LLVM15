//===- bolt/RuntimeLibs/HugifyRuntimeLibrary.h - Hugify Lib -----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the declaration of the HugifyRuntimeLibrary class.
//
//===----------------------------------------------------------------------===//

#ifndef BOLT_RUNTIMELIBS_HUGIFY_RUNTIME_LIBRARY_H
#define BOLT_RUNTIMELIBS_HUGIFY_RUNTIME_LIBRARY_H

#include "bolt/RuntimeLibs/RuntimeLibrary.h"

namespace llvm {
namespace bolt {

class HugifyRuntimeLibrary : public RuntimeLibrary {
public:
  /// Add custom section names generated by the runtime libraries to \p
  /// SecNames.
  void addRuntimeLibSections(std::vector<std::string> &SecNames) const final {}

  void adjustCommandLineOptions(const BinaryContext &BC) const final;

  void emitBinary(BinaryContext &BC, MCStreamer &Streamer) final {}

  void link(BinaryContext &BC, StringRef ToolPath, BOLTLinker &Linker,
            BOLTLinker::SectionsMapper MapSections) override;
};

} // namespace bolt
} // namespace llvm

#endif