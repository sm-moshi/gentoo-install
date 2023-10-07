smeya@musl-clang-box ~ $ sudo emerge -a llvm-ocaml dev-python/lit lldb clang-python clang clang-runtime lld llvm compiler-rt compiler-rt-sanitizers libcxx libcxxabi llvm-libunwind libclc llvmgold clang-toolchain-symlinks lld-toolchain-symlinks llvm-toolchain-symlinks

These are the packages that would be merged, in order:

Calculating dependencies... done!
Dependency resolution took 2.01 s.

[ebuild  NS   *] sys-devel/llvm-17.0.0_rc4:17::gentoo [16.0.6:16::miapersonal] USE="binutils-plugin libffi ncurses xml -debug -debuginfod% -doc -exegesis -libedit -test -verify-sig -xar -z3 -zstd (-polly%)" LLVM_TARGETS="(AArch64) (AMDGPU) (ARM) (AVR) (BPF) (Hexagon) (Lanai) (LoongArch) (MSP430) (Mips) (NVPTX) (PowerPC) (RISCV) (Sparc) (SystemZ) (VE) (WebAssembly) (X86) (XCore) -ARC -CSKY -DirectX -M68k -SPIRV -Xtensa" 0 KiB
[ebuild     U *] sys-devel/llvmgold-17::gentoo [16::gentoo] 0 KiB
[ebuild  NS   *] sys-devel/llvm-toolchain-symlinks-17:17::gentoo [16-r1:16::gentoo] USE="native-symlinks -multilib-symlinks" 0 KiB
[ebuild  NS   *] sys-devel/clang-17.0.0_rc4:17::gentoo [16.0.6:16::gentoo] USE="extra (pie) static-analyzer xml -debug -doc (-ieee-long-double) -test -verify-sig" LLVM_TARGETS="(AArch64) (AMDGPU) (ARM) (AVR) (BPF) (Hexagon) (Lanai) (LoongArch) (MSP430) (Mips) (NVPTX) (PowerPC) (RISCV) (Sparc) (SystemZ) (VE) (WebAssembly) (X86) (XCore) -ARC -CSKY -DirectX -M68k -SPIRV -Xtensa" PYTHON_SINGLE_TARGET="python3_11 -python3_10 -python3_12" 0 KiB
[ebuild  NS   *] sys-devel/clang-toolchain-symlinks-17:17::gentoo [16-r2:16::gentoo] USE="native-symlinks -gcc-symlinks -multilib-symlinks" 0 KiB
[ebuild  NS   *] sys-libs/compiler-rt-17.0.0_rc4:17::gentoo [16.0.6:16::gentoo] USE="(clang) -debug -test -verify-sig" 0 KiB
[ebuild     U *] sys-libs/libcxxabi-17.0.0_rc4::gentoo [16.0.6::gentoo] USE="(clang) static-libs -test -verify-sig" 0 KiB
[ebuild     U *] sys-libs/libcxx-17.0.0_rc4::gentoo [16.0.6::gentoo] USE="(clang) (libcxxabi) static-libs -test -verify-sig" 0 KiB
[ebuild  NS   *] sys-devel/clang-runtime-17.0.0_rc4:17::gentoo [16.0.6:16::gentoo] USE="compiler-rt libcxx openmp -sanitize" 0 KiB
[ebuild     U *] sys-libs/llvm-libunwind-17.0.0_rc4-r1::gentoo [16.0.6-r1::gentoo] USE="(clang) static-libs -debug -test -verify-sig" 0 KiB
[ebuild  N    *] dev-ml/llvm-ocaml-17.0.0_rc4:0/17.0.0_rc4::gentoo  USE="-debug -test -verify-sig" LLVM_TARGETS="(AArch64) BPF -AMDGPU -ARC -ARM -AVR -CSKY -DirectX -Hexagon -Lanai -LoongArch -M68k -MSP430 -Mips -NVPTX -PowerPC -RISCV -SPIRV -Sparc -SystemZ -VE -WebAssembly -X86 -XCore -Xtensa" 0 KiB
[ebuild  N    *] dev-python/lit-17.0.0_rc4::gentoo  USE="-test -verify-sig" PYTHON_TARGETS="python3_11 -python3_10 -python3_12" 0 KiB
[ebuild     U *] dev-util/lldb-17.0.0_rc4:0/17::gentoo [16.0.6:0/16::gentoo] USE="libedit ncurses python xml -debug -lzma -test -verify-sig" PYTHON_SINGLE_TARGET="python3_11 -python3_10 -python3_12" 0 KiB
[ebuild     U *] dev-python/clang-python-17.0.0_rc4::gentoo [16.0.6::gentoo] USE="-test -verify-sig" PYTHON_TARGETS="python3_11 -python3_10 -python3_12" 0 KiB
[ebuild  N    *] sys-libs/compiler-rt-sanitizers-17.0.0_rc4:17::gentoo  USE="asan cfi (clang) dfsan hwasan libfuzzer lsan msan orc profile safestack scudo shadowcallstack tsan ubsan xray -debug (-gwp-asan) (-memprof) -test -verify-sig" 0 KiB
[ebuild  N    *] dev-libs/libclc-17.0.0_rc4::gentoo  USE="spirv -verify-sig" VIDEO_CARDS="(-nvidia) (-r600) -radeonsi" 0 KiB
[ebuild  NS   *] sys-devel/lld-17.0.0_rc4:17::gentoo [16.0.6:16::gentoo] USE="-debug -test -verify-sig -zstd" 0 KiB
[ebuild  NS   *] sys-devel/lld-toolchain-symlinks-17:17::gentoo [16-r2:16::gentoo] USE="native-symlinks -multilib-symlinks" 0 KiB

Total: 18 packages (6 upgrades, 4 new, 8 in new slots), Size of downloads: 0 KiB

!!! The following installed packages are masked:
- sys-devel/llvm-16.0.6::miapersonal (masked by: package.mask)
For more information, see the MASKED PACKAGES section in the emerge
man page or refer to the Gentoo Handbook.