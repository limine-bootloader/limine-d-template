# Nuke built-in rules and variables.
override MAKEFLAGS += -rR

# This is the name that our final kernel executable will have.
# Change as needed.
override KERNEL := kernel.elf

# Convenience macro to reliably declare user overridable variables.
define DEFAULT_VAR =
    ifeq ($(origin $1),default)
        override $(1) := $(2)
    endif
    ifeq ($(origin $1),undefined)
        override $(1) := $(2)
    endif
endef

# It is suggested to use a custom built cross toolchain to build a kernel.
# We are using the standard "cc" here, it may work by using
# the host system's toolchain, but this is not guaranteed.
override DEFAULT_D := gdc
$(eval $(call DEFAULT_VAR,D,$(DEFAULT_D)))

# Same thing for "ld" (the linker).
override DEFAULT_LD := ld
$(eval $(call DEFAULT_VAR,LD,$(DEFAULT_LD)))

# User controllable C flags.
override DEFAULT_DFLAGS := -g -O2 -pipe
$(eval $(call DEFAULT_VAR,DFLAGS,$(DEFAULT_DFLAGS)))

# User controllable nasm flags.
override DEFAULT_NASMFLAGS := -F dwarf -g
$(eval $(call DEFAULT_VAR,NASMFLAGS,$(DEFAULT_NASMFLAGS)))

# User controllable linker flags. We set none by default.
override DEFAULT_LDFLAGS :=
$(eval $(call DEFAULT_VAR,LDFLAGS,$(DEFAULT_LDFLAGS)))

# Internal C flags that should not be changed by the user.
override DFLAGS += \
    -Wall \
    -Wextra \
    -fno-druntime \
    -fno-builtin \
    -fno-stack-protector \
    -fno-stack-check \
    -fno-lto \
    -fPIE \
    -m64 \
    -march=x86-64 \
    -mno-80387 \
    -mno-mmx \
    -mno-sse \
    -mno-sse2 \
    -mno-red-zone

# Internal linker flags that should not be changed by the user.
override LDFLAGS += \
    -m elf_x86_64 \
    -nostdlib \
    -static \
    -pie \
    --no-dynamic-linker \
    -z text \
    -z max-page-size=0x1000 \
    -T linker.ld

# Internal nasm flags that should not be changed by the user.
override NASMFLAGS += \
    -Wall \
    -f elf64

# Use "find" to glob all *.d, *.S, and *.asm files in the tree and obtain the
# object file names.
override DFILES := $(shell find -L . -type f -name '*.d' | grep -v 'limine.d') limine.d
override ASFILES := $(shell find -L . -type f -name '*.S')
override NASMFILES := $(shell find -L . -type f -name '*.asm')
override OBJ := $(DFILES:.d=.d.o) $(ASFILES:.S=.S.o) $(NASMFILES:.asm=.asm.o)

# Default target.
.PHONY: all
all: $(KERNEL)

limine.d:
	curl -Lo $@ https://github.com/limine-bootloader/limine-d/raw/trunk/limine.d

# Link rules for the final kernel executable.
$(KERNEL): GNUmakefile linker.ld $(OBJ)
	$(LD) $(OBJ) $(LDFLAGS) -o $@

# Compilation rules for *.d files.
%.d.o: %.d GNUmakefile limine.d
	$(D) $(DFLAGS) -c $< -o $@

# Compilation rules for *.S files.
%.S.o: %.S GNUmakefile
	$(D) $(DFLAGS) -c $< -o $@

# Compilation rules for *.asm (nasm) files.
%.asm.o: %.asm GNUmakefile
	nasm $(NASMFLAGS) $< -o $@

# Remove object files and the final executable.
.PHONY: clean
clean:
	rm -rf $(KERNEL) $(OBJ)

.PHONY: distclean
distclean: clean
	rm -rf limine.d
