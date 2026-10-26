#!/usr/bin/env python3
"""minimize.py <case-line-file> <grep-pattern> [--keep N]: shrink one route case (driver TSV line) while RouteRun's output still
contains <grep-pattern> (e.g. 'INFLIGHT'). Greedy: delete one s-expression subtree (a step, a route, a send) at a time,
keep the deletion if the pattern is still printed. Prints the minimal routes and sends. One JVM per try (niced)."""
import os, subprocess, sys, tempfile

S = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
B = os.path.join(S, 'build', 'camel-' + open(os.path.join(S, 'PIN')).readline().split()[1])
CP = os.path.join(S, 'build', 'harness-route') + ':' + os.path.join(B, 'classes') + ':' + open(os.path.join(B, 'deps.cp')).read().strip()
JAVA = os.path.expanduser('~/homebrew/opt/openjdk@21/bin/java')

def parse(s):
    toks, i, out = [], 0, []
    def rec():
        nonlocal i
        while s[i] == ' ': i += 1
        if s[i] == '(':
            i += 1; node = []
            while True:
                while s[i] == ' ': i += 1
                if s[i] == ')': i += 1; return node
                node.append(rec())
        j = i
        while i < len(s) and s[i] not in ' )': i += 1
        return s[j:i]
    while i < len(s):
        while i < len(s) and s[i] == ' ': i += 1
        if i < len(s): out.append(rec())
    return out

def show(n): return n if isinstance(n, str) else '(' + ' '.join(show(k) for k in n) + ')'

def paths(n, p=()):
    """deletable subtrees: list elements at index >= the fixed prefix of their head"""
    if isinstance(n, str): return
    for i, k in enumerate(n):
        if isinstance(k, list): yield p + (i,); yield from paths(k, p + (i,))

def delete(tree, path):
    import copy
    t = copy.deepcopy(tree); node = t
    for i in path[:-1]: node = node[i]
    del node[path[-1]]
    return t

def run(routes, sends, pat):
    with tempfile.NamedTemporaryFile('w', suffix='.tsv', delete=False) as f:
        f.write('min-1\t%s\t%s\t[]x G=\tmin\n' % (' '.join(show(r) for r in routes), ' '.join(show(x) for x in sends)))
        name = f.name
    try:
        out = subprocess.run(['nice', JAVA, '-Xmx512m', '-Dhang.seconds=3', '-cp', CP, 'RouteRun', name, name + '.o'],
                             capture_output=True, text=True, timeout=120)
        mism = open(name + '.o.mism.tsv').read() if os.path.exists(name + '.o.mism.tsv') else ''
        return pat in out.stdout + out.stderr + mism
    except subprocess.TimeoutExpired:
        return pat == 'HANG'
    finally:
        for x in (name, name + '.o.mism.tsv', name + '.o.unspec.tsv'):
            if os.path.exists(x): os.remove(x)

line = open(sys.argv[1]).read().strip().split('\t')
pat = sys.argv[2]
# --keep N: never delete inside the first N top-level forms (e.g. 3: the clauses, the error handler, the onCompletion),
# so that a pattern that depends on them keeps its meaning
KEEP = int(sys.argv[sys.argv.index('--keep') + 1]) if '--keep' in sys.argv else 0
routes, sends = parse(line[1]), parse(line[2])
assert run(routes, sends, pat), 'the pattern does not occur on the input'
changed = True
while changed:
    changed = False
    for which in ('routes',):
        tree = routes if which == 'routes' else sends
        for p in sorted(set(paths(['_'] + tree)), key=len):
            p = (p[0] - 1,) + p[1:]
            if p[0] < 0: continue
            # never delete a whole route, the clauses list, or a send: only steps (and clauses) inside them;
            # deleting a route makes a send to direct:<it> block (a false HANG)
            if len(p) < 2: continue
            if p[0] < KEEP: continue
            # protect what makes generated loops end: the body of a while-loop and the rdyn route
            node, guarded = tree, False
            for i in p[:-1]:
                node = node[i]
                if isinstance(node, list) and node and (node[0] == 'loop' and len(node) > 3 and node[3] == '1'
                                                        or node[:3] == ['route', 'rdyn', 'rdyn']):
                    guarded = True
            if guarded: continue
            # keep the fixed heads of forms: never delete position 0 (the head atom) or required option nodes
            try:
                t2 = delete(tree, p)
            except (IndexError, TypeError):
                continue
            r2, s2 = (t2, sends) if which == 'routes' else (routes, t2)
            if not s2 or not r2: continue
            if run(r2, s2, pat):
                routes, sends = r2, s2; changed = True
                print('  smaller:', len(show(routes)), file=sys.stderr)
                break
        if changed: break
print('ROUTES', ' '.join(show(r) for r in routes))
print('SENDS', ' '.join(show(x) for x in sends))
