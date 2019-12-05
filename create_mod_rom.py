#!/usr/bin/env python3

import argparse
import sys
import shutil
import os
import binascii

lookup_table = b"\x00\x00\x00\x00\x01\x00\x00\x00\x00\x02\x00\x00\x00\x00\x04\x00" \
               b"\x00\x00\x00\x08\x00\x00\x00\x01\x06\x00\x00\x00\x03\x02\x00\x00" \
               b"\x00\x06\x04\x00\x00\x01\x02\x08\x00\x00\x02\x05\x06\x00\x00\x05" \
               b"\x01\x02\x00\x01\x00\x02\x04\x00\x02\x00\x04\x08\x00\x04\x00\x09" \
               b"\x06\x00\x08\x01\x09\x02\x01\x06\x03\x08\x04\x03\x02\x07\x06\x08"

def insert_binary(source_file, bin_file, offset):
    int_offset = int(offset, 16)
    shutil.copyfile(source_file, "mod.nes")
    source = open("mod.nes", "br+")
    bin = bytearray(open(bin_file, "rb").read())
    source.seek(int("0x3F80", 16))
    source.write(lookup_table)
    source.seek(int("0x01CC3E", 16))
    jump_position = "50B8"
    source.write(binascii.unhexlify(jump_position))
    source.seek(int_offset)
    source.write(bin)
    source.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("source", help="Input source (.nes) file")
    parser.add_argument("bin", help="Binary file to insert")
    parser.add_argument("position", help="Hex position to overwrite binary")
    args = parser.parse_args()

    insert_binary(args.source, args.bin, args.position)