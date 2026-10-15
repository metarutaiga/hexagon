OUTPUT_ARCH(hexagon)
ENTRY(0x00000000)

/* Explicitly define only the required Program Headers */
PHDRS
{
    text_phdr    PT_LOAD FILEHDR PHDRS FLAGS(5) ; /* r-x : Read (4) + Execute (1) */
    data_phdr    PT_LOAD               FLAGS(6) ; /* rw- : Read (4) + Write (2)   */
    dynamic_phdr PT_DYNAMIC            FLAGS(6) ; /* rw- : Dynamic section tag    */
}

SECTIONS
{
    /* Reserve space at 0x0 for ELF Header + Program Headers */
    . = SIZEOF_HEADERS;

    /* ==================== LOAD 1: Read-Execute (r-x) ==================== */
    .dynsym   : { *(.dynsym) }           : text_phdr
    .dynstr   : { *(.dynstr) }           : text_phdr
    .hash     : { *(.hash) }             : text_phdr
    .rela.dyn : { *(.rela.dyn) }         : text_phdr
    .rela.plt : { *(.rela.plt) }         : text_phdr
    .init     : { *(.init) }             : text_phdr
    .plt      : { *(.plt) }              : text_phdr
    .text     : { *(.text .text.*) }     : text_phdr
    .fini     : { *(.fini) }             : text_phdr
    .rodata   : { *(.rodata .rodata.*) } : text_phdr
    .eh_frame : { KEEP(*(.eh_frame)) }   : text_phdr

    /* Align to 4KB (0x1000) page boundary */
    . = ALIGN(0x1000);

    /* ==================== LOAD 2: Read-Write (rw-) ==================== */
    .dynamic     : { *(.dynamic) }                    : data_phdr : dynamic_phdr
    .data.rel.ro : { *(.data.rel.ro .data.rel.ro.*) } : data_phdr
    .ctors       : { KEEP(*(.ctors)) }                : data_phdr
    .dtors       : { KEEP(*(.dtors)) }                : data_phdr
    .got         : { *(.got) }                        : data_phdr
    .got.plt     : { *(.got.plt) }                    : data_phdr
    .data        : { *(.data .data.*) }               : data_phdr
    .bss         : { *(.bss .bss.*) }                 : data_phdr

    /* Unmapped / Debug sections (VMA = 0) */
    .comment  0 : { *(.comment) }
    .shstrtab 0 : { *(.shstrtab) }
    .symtab   0 : { *(.symtab) }
    .strtab   0 : { *(.strtab) }

    /DISCARD/ : {
        *(.note*)
        *(.gnu.attributes)
    }
}