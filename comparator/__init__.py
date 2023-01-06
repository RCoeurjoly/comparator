import os
import sys
import subprocess
import pathlib

def get_wildq_command(extension):
    return 'wildq --' + extension + ' \'walk(if type == "array" then sort else . end)\' '

def graphtage_extra_args(extension1, extension2):
    if (extension1 == 'xml' or extension2 == 'xml'):
        return '--join-dict-items'
    return ''

def get_extensions(filename1, filename2):
    if (filename1.endswith(".cfg") and filename2.endswith(".cfg")):
        extension1 = 'ini'
        extension2 = 'ini'
    else:
        extension1 = pathlib.Path(filename1).suffix[1:]
        extension2 = pathlib.Path(filename2).suffix[1:]
    return extension1, extension2

def main():
    args = sys.argv[1:]
    filename1 = args[0]
    filename2 = args[1]
    rest_of_args = ''.join(sys.argv[3:])
    extension1, extension2 = get_extensions(filename1, filename2)
    return subprocess.call(['graphtage -k '
                            + graphtage_extra_args(extension1, extension2)
                            + ' --from-json --to-json '
                            + '<(' + get_wildq_command(extension1) + filename1 + ') '
                            + '<(' + get_wildq_command(extension2) + filename2 + ')'], shell=True)


if __name__ == '__main__':
    main()
