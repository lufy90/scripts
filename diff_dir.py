#!/bin/env python

# v20190524

import sys
import os
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

def file_mata(p, l, content=[]):
  ''' content: [file_name, chksum] '''
  if p[-1] is '/':
    p = p[:-1]
  try:
    for i in os.listdir(p):
      tmp_name = p + '/' + i
      if os.path.isdir(tmp_name):
        content.append([tmp_name[l:], ''])
        file_mata(tmp_name, l, content=content)
      else:
        content.append([tmp_name[l:], md5sum(tmp_name)])
  except Exception as e:
    print(e)

def diff(a, b):
  '''a = {f_name1: md5sum1, f_name2:md5sum2}, b the same'''
  re = []
  ak = list(a.keys())
  bk = list(b.keys())
  for i in ak:
    if (i in bk) and (a[i] == b[i]):
      bk.remove(i)
      pass
    elif (i in bk):
      bk.remove(i)
      print('%-10s %s' % ('Modified:', i))
    else:
      print('%-10s %s' % ('New:', i))

  for j in bk:
    print('%-10s %s' % ('Deleted:', j))

def usage():
  '''usage'''
  return('Usage: %s path1 path2')


if __name__ == '__main__':
  try:
    path1 = sys.argv[1]
    path2 = sys.argv[2]
  except Exception as e:
    print(usage()%sys.argv[0])
    print(e)
    sys.exit(2)

  if path1[-1] is not '/':
    path1 = path1 + '/'

  if path2[-1] is not '/':
    path2 = path2 + '/'

  md5s1 = []
  md5s2 = []

  file_mata(path1, len(path1), md5s1)
  file_mata(path2, len(path2), md5s2)

  meta1 = {}
  for i in md5s1:
    meta1[i[0]] = i[1]

  meta2 = {}
  for i in md5s2:
    meta2[i[0]] = i[1]
  print('Compared with %s, %s has followed chages:' % (path1[:-1], path2[:-1]))
  diff(meta1, meta2)
