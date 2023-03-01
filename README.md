IDA PRO: https://rutracker.org/forum/viewtopic.php?t=6218777
Hiew: https://www.hiew.ru/

Описание команд ассемблера: https://sysprog.ru/posts?cat_id=1&thread_id=3&page=1

Интересный сборник програмок: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS

# Прерывания
Общее, не полное руководство: http://www.codenet.ru/progr/dos/int_0026.php

Самое мощное и удобное по прерываниям:http://biosprog.narod.ru/real/dos/ints.htm 

Из мощного, по 21h: http://biosprog.narod.ru/real/dos/int21/

Еще по 21h: http://www.avprog.narod.ru/progs/fdos01.html

# TASM Arguments 
Turbo Assembler Version 2.0 Copyright (c) 1988, 1990 Borland International
Syntax: TASM [options] source [,object] [,listing] [,xref]
/a,/s Alphabetic or Source-code segment ordering
/c Generate cross-reference in listing
/dSYM[=VAL] Define symbol SYM = 0, or = value VAL
/e,/r Emulated or Real floating-point instructions
/h,/? Display this help screen
/iPATH Search PATH for include files
/jCMD Jam in an assembler directive CMD (eg. /jIDEAL)
/kh#,/ks# Hash table capacity #, String space capacity #
/l,/la Generate listing: l=normal listing, la=expanded listing
/ml,/mx,/mu Case sensitivity on symbols: ml=all, mx=globals, mu=none
/mv# Set maximum valid length for symbols
/m# Allow # multiple passes to resolve forward references
/n Suppress symbol tables in listing
/o,/op Generate overlay object code, Phar Lap-style 32-bit fixups
/p Check for code segment overrides in protected mode
/q Suppress OBJ records not needed for linking
/t Suppress messages if successful assembly
/w0,/w1,/w2 Set warning level: w0=none, w1=w2=warnings on
/w-xxx,/w+xxx Disable (-) or enable (+) warning xxx
/x Include false conditionals in listing
/z Display source line with error message
/zi,/zd Debug info: zi=full, zd=line numbers only

# TLINK Arguments 
Turbo Link Version 3.0 Copyright (c) 1987, 1990 Borland International
Syntax: TLINK objfiles, exefile, mapfile, libfiles
@xxxx indicates use response file xxxx
Options: /m = map file with publics
/x = no map file at all
/i = initialize all segments
/l = include source line numbers
/s = detailed map of segments
/n = no default libraries
/d = warn if duplicate symbols in libraries
/c = lower case significant in symbols
/3 = enable 32-bit processing
/v = include full symbolic debug information
/e = ignore Extended Dictionary
/t = create COM file
/o = overlay switch
/ye = expanded memory swapping
/yx = extended memory swapping