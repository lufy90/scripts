#!/usr/bin/python3
# ls.py
# list files.


import os, sys
import hashlib

def md5sum(src):
  if os.path.isdir(src):
    return ''
  else:
    ha = hashlib.md5()
    with open(src, 'rb') as f:
      for chunck in iter(lambda: f.read(2048), b''):
        ha.update(chunck)

    return ha.hexdigest()



def ls(path,l):
  if path[-1] != '/':
    path = path + '/'
  
#  print(path)
  try:
    for i in os.listdir(path):
      tmp_path = path + str(i)
      if os.path.isdir(tmp_path):
#        print("\033[0;34m%s\033[0m"%tmp_path)
        ls(tmp_path,l)
      else:
#         print(tmp_path)
        print(md5sum(tmp_path), i)
  except OSError as e:
    print(e)

def ls2(p):
  if p[-1] != '/':
    p = p + '/'
  ls(p, len(p))


if __name__ == '__main__':
  if sys.argv[1:]:
    for p in sys.argv[1:]:
      ls2(p)
  else: 
    ls2('.')
    
