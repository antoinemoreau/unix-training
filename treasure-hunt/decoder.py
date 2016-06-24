#! /usr/bin/env python3

dec = str.maketrans("1234567890/abcdefghijklmnopqrstuvwxyz",
                    "abcdefghijklmnopqrstuvwxyz/1234567890")

while True:
    try:
        line = input()
    except EOFError:
        break
    print(line.translate(dec))
    
