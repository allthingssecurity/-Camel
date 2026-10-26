#!/usr/bin/env python3
"""classify.py <mism.tsv>...: group route-level mismatches by the fields that differ (events count, per-event
fields, final b/h/p/v/e, globals) and print one decoded example per group."""
import sys, re, urllib.parse as u
from collections import defaultdict

def fields(s):
    return dict(kv.split('=', 1) for kv in s.split(';') if '=' in kv)

def split(r):
    m = re.match(r'\[(.*)\](.*)$', r)
    if not m: return None, r
    ev = [e.split('=', 1) for e in m.group(1).split('|')] if m.group(1) else []
    return ev, m.group(2)

groups = defaultdict(list)
for f in sys.argv[1:]:
    for line in open(f):
        c = line.rstrip('\n').split('\t')
        cid, kind, camel, spec = c[0], c[1], c[2], c[3]
        if kind in ('GLOBAL', 'SETUP'):
            groups[kind].append(c); continue
        ce, cf = split(camel); se, sf = split(spec)
        if ce is None or se is None:
            groups['shape'].append(c); continue
        key = []
        if [n for n, _ in ce] != [n for n, _ in se]:
            key.append('events(%d vs %d)' % (len(ce), len(se)))
        else:
            for (n, a), (_, b) in zip(ce, se):
                fa, fb = fields(a), fields(b)
                key += ['ev.' + k for k in fa if fa.get(k) != fb.get(k)]
        fa, fb = fields(cf), fields(sf)
        key += ['final.' + k for k in fa if fa.get(k) != fb.get(k)]
        groups[','.join(sorted(set(key))) or 'same?'].append(c)
d = u.unquote
for k, v in sorted(groups.items(), key=lambda kv: -len(kv[1])):
    c = v[0]
    print(f'== {len(v):5d}  {k}   e.g. {c[0]}')
    print('   camel:', d(c[2])[:300]); print('   spec :', d(c[3])[:300])
    print('   routes:', d(c[4])[:600]); print('   sends:', d(c[5])[:200])
