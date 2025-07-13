# python functions to be used in UltiSnips snippets.
# NB: modifications require a restart of vim in order to be picked up by UltiSnips.

import re

# tex
def align_helper(s):  # {{{
  # delete the top line if it's \[
  r = re.compile(r"^ *\\\[ *\n").sub("", s, count=1)
  # delete the last line if it's \]
  r = re.compile(r"\n *\\\] *$").sub("", r, count=1)
  # delete trailing newline. For some reason this cannot be combined with above.
  r = re.compile(r"\n$").sub("", r, count=1)

  return r
#----------------------------------------------------------------------------}}}
def label_make(s): # {{{
  try:
    rv = s[1].lower().replace(' ', '_')
  except:
    rv = ''
  return rv
#--------------------------------------------------------------------------}}}
def parens_helper(s): # {{{
  try:
    L = s[1].split(' ')[0]
    if L == 'big': rv = 'big'
    elif L == 'left': rv = 'right'
    else: rv = L

    P = s[2].split(' ')[0]
    if P == '(': rv += ')'
    elif P == '[': rv += ']'
    elif P == '\{': rv += '\}'
    elif P == '<': rv += '>'
    else: rv += P
  except:
    rv = ""

  return rv
#--------------------------------------------------------------------------}}}
