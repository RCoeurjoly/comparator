import os
import sys
import subprocess


def main():
    args = sys.argv[1:]
    if (args[0].endswith() == ".cfg" and args[1].endswith() == ".cfg"):
        return subprocess.call(['graphtage -k --from-json --to-json <(wildq --ini "." ' + args[0] + ') <(wildq --ini "." ' + args[1] + ')'], shell=True)
    return subprocess.call(['graphtage -k ' + args[0] + ' ' + args[1]], shell=True)


if __name__ == '__main__':
    main()
