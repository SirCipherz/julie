import sys
editor   = sys.argv[1]
raw_file = open('./send.sh')
output   = raw_file.read().replace("editor='vim'", "editor='{}'".format(editor))
raw_file.close()

send = open('/tmp/tmp-julie-send.sh', 'w')
send.write(output)
send.close()
