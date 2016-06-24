#! /usr/bin/env python3

dec = str.maketrans("1234567890xyztabcdef",
                    "abcdef1234567890xyzt")

while True:
    try:
        line = input()
    except EOFError:
        break
    print(line.translate(dec))
