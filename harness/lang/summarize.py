# Summaries of a LangRun output: UNSPECIFIED reasons with Camel's outcomes, and the disagreements by class.
# usage: python3 summarize.py <out-prefix>   (reads <prefix>.unspec.tsv and <prefix>.mism.tsv)
import sys, collections, re, urllib.parse as u
pre = sys.argv[1]
r = collections.defaultdict(collections.Counter)
for l in open(pre + '.unspec.tsv'):
    if l.startswith('#'): continue
    f = l.rstrip('\n').split('\t'); r[f[1]][f[2]] += int(f[3])
with open(pre + '.unspec-summary.txt', 'w') as o:
    for reason, c in sorted(r.items(), key=lambda kv: -sum(kv[1].values())):
        o.write('%6d  %s  ->  camel: %s\n' % (sum(c.values()), reason,
                ', '.join('%s x%d' % (u.unquote(k)[:40], v) for k, v in c.most_common(4))))
def cls(f):
    txt, env, exp, act = u.unquote(f[3]), u.unquote(f[2]), u.unquote(f[4]), u.unquote(f[6])
    msg = f[7] if len(f) > 7 else ''
    if f[1] == 'PH':
        if re.search(r'\{\{ |[^ ] \}\}|\{\{[^}]* \}\}', txt) or '{{ ' in env: return 'doc-bug? key with spaces {{ k }} [PP.582]'
        if '{{!' in txt + env and not txt.startswith('{{!'): return 'code-bug? negation not leading'
        if '\\' in txt + env:
            if act.startswith('E') and 'Missing' in msg: return 'code-bug? escape: lone \\{{ fails'
            if '{{' not in txt.replace('\\{{', '') and act[1:] == txt: return 'code-bug? escape: kept when no {{'
            if act.startswith('S') and exp.startswith('S') and act[1:].replace('\\', '') == exp[1:].replace('\\', ''): return 'code-bug? escape: backslash lost (nested=false)'
            return 'code-bug? escape: other (\\{{x\\ -> {{x}})'
        return 'UNCLASSIFIED'
    o = dict(x.split('=', 1) for x in f[2].split(';'))
    if o.get('lang') == 'tokenize':
        tok = u.unquote(o.get('token', ''))
        if any(ch in tok for ch in '[]+*.|\\(){}?^$') and 'regex' not in o and 'end' not in o: return 'code-bug? tokenize: token is a regex'
        if 'end' in o and tok.strip() == '': return 'code-bug? tokenize: pair mode white-space start token'
        if 'end' in o and f[3].startswith('body=N'): return 'code-bug? tokenize: pair mode null body'
    return 'UNCLASSIFIED'
c = collections.Counter(); ex = {}
for l in open(pre + '.mism.tsv'):
    f = l.rstrip('\n').split('\t')
    if len(f) < 7: continue
    k = cls(f); c[k] += 1; ex.setdefault(k, []).append(l)
with open(pre + '.disagreements.tsv', 'w') as o:
    for k, v in c.most_common():
        o.write('# %d\t%s\n' % (v, k))
        for l in ex[k][:5]: o.write(l)
for k, v in c.most_common(): print('%6d  %s' % (v, k))
