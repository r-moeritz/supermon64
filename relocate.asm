// Relocatable code stub for Supermon 64 by Jim Butterfield
// This code was disassembled from the original Supermon+64 V1.2 binary.

// The relocation stub starts at the Start of Variables pointer (VARTAB) and
// works backwards through the Supermon64 machine code, copying it to the top
// of basic memory pointer (MEMSIZ), and decrementing the pointer as it goes.
// Relative addresses that need to be adjusted are marked with a $36 byte
// immediately following them. Since we're working backwards, the marker is
// encountered first, then the high byte, then the low byte of the address
// needing to be adjusted. The relative addresses are calculated such that
// adding the top of memory to them will yield the absolute address of the
// jump target in the relocated code.

// build.py will build a relocatable Supermon64 binary from this stub plus
// standard Supermon64 binaries assembled to two different pages.

.encoding "petscii_mixed"

// ----------------------------------------------------------------------------
// variables

.label source  = $22               // first temp variable
.label topmem  = $24               // highest address available to BASIC
.label lastbyt = $26               // previous byte encountered
.label vartab  = $2D               // pointer to start of BASIC variable storage area
.label fretop  = $33               // pointer to bottom of string text storage area
.label target  = $37               // end of basic memory/start of machine code (aka MEMSIZ)


// ----------------------------------------------------------------------------
// basic header

        * = $0801

        // 100 PRINT "{DOWN}SUPERMON+64    JIM BUTTERFIELD"
        // 110 SYS(PEEK(43)+256*PEEK(44)+71)

        .byte $29,$08,$64,$00,$99,$20,$22,$11
        .text "supermon+64    jim butterfield"
        .byte $22,$00,$43,$08,$6e,$00,$9e,$28
        .byte $c2,$28,$34,$33,$29,$aa,$32,$35
        .byte $36,$ac,$c2,$28,$34,$34,$29,$aa
        .byte $37,$31,$29,$00,$00,$00,$00,$00
        .byte $00

// ----------------------------------------------------------------------------
// relocator stub

        lda vartab          // start copying from the start of basic variables
        sta source
        lda vartab+1
        sta source+1
        lda target          // start copying to the end of BASIC memory
        sta topmem
        lda target+1
        sta topmem+1
loop:   ldy #$00            // no offset from pointers
        lda source          // decrement two-byte source address
        bne nb1
        dec source+1
nb1:    dec source
        lda (source),y      // get byte currently pointed to by SOURCE
        cmp #$36            // check for address marker ($36)
        bne noadj           // skip address adjustment unless found
        lda source          // decrement two-byte source address
        bne nb2
        dec source+1
nb2:    dec source
        lda (source),y      // get byte currently pointed to by SOURCE
        cmp #$36            // check for second consecutive marker ($36)
        beq done            // if found, we're done with relocation
        sta lastbyt         // if not, save byte for later
        lda source          // decrement two-byte source address
        bne nb3
        dec source+1
nb3:    dec source
        lda (source),y      // current byte is low byte of relative address
        clc 
        adc topmem          // calc absolute low byte by adding top of memory
        tax                 // save absolute low byte in X
        lda lastbyt         // previous byte is high byte of relative address
        adc topmem+1        // calc absolute high byte by adding top of memory
        pha                 // save absolute high byte on stack
        lda target          // decrement two-byte target address
        bne nb4
        dec target+1
nb4:    dec target
        pla                 // retrieve absolute high byte from stack
        sta (target),y      // save it to the target address
        txa                 // retrieve absolute low byte from stack
noadj:  pha                 // save current byte on stack
        lda target          // decrement two-byte target address
        bne nb5
        dec target+1
nb5:    dec target
        pla                 // retrieve current byte from stack
        sta (target),y      // save it in the target address
        clc                 // clear carry for unconditional loop
        bcc loop            // rinse, repeat
done:   lda target          // fix pointer to string storage
        sta fretop
        lda target+1
        sta fretop+1
        jmp (target)        // jump to the beginning of the relocated code
