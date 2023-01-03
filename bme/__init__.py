
import os
import sys
import subprocess

def main():
    args = sys.argv[1:]
    first = open(args[0], "r")
    second = open(args[1], "r")

    #read whole files to a string
    data1 = first.read()
    data2 = second.read()
    #close files
    first.close()
    second.close()
    subprocess.call(['graphtage -k --from-json --to-json <(cat ' + args[0] + ' | wildq --ini ".") <(cat ' + args[1] + ' | wildq --ini ".")'], shell=True)

if __name__ == '__main__':
    print("Hello Poetry2nix!!")
