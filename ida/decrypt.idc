
    auto a, from, to;
    for (a = 0x100; a<0x120; a++){
        from = [0x1000, a];
        to = [0x1000, a];
        PatchByte(from, Byte(to)^0x0AA);
    }
    msg("DONE!");


