import os
import sys
import subprocess


def main():
    args = sys.argv[1:]
    subprocess.call(['graphtage -k --from-json --to-json <(wildq --ini "." ' + args[0] + ') <(wildq --ini "." ' + args[1] + ')'], shell=True)


if __name__ == '__main__':
    main()
