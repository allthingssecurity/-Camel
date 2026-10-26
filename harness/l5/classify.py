#!/usr/bin/env python3
"""classify.py <run dir>: bucket the mismatches of the L5 runs by their known class (notes/l5.md, findings/).
Prints: bucket <TAB> count <TAB> class <TAB> where it is written up. A mismatch matching no bucket is 'unclassified'."""
import glob, os, re, sys
from collections import Counter
B = [
    ('case-name-dropped', r'(lazyStartProducer|bridgeErrorHandler|autowiredEnabled): want B1 got B0;$|\tcase\t.*\tFAILANY ', 'code-bug',
     'findings/2026-10-26-l5-ignore-case-global-options-dropped.md'),
    ('log-logmask-default-null', r'logMask: want B0 got N;$', 'doc-bug', 'notes/l5.md'),
    ('timer-pattern-not-kept', r'pattern: want S\S* got N;$', 'code-bug (low)', 'findings/2026-10-26-l5-timer-pattern-not-kept.md'),
    ('seda-offertimeout-duration', r'offerTimeout', 'code-bug', 'findings/2026-10-26-l5-seda-offertimeout-duration.md'),
    ('cat-missing-path-invalid-enum', r'\tREP U=[^;]*;R=[^;]*;I=[^\t]*\tREP .*(enum|integer|boolean|number|duration):[^:]+:(,|$)', 'code-bug (low)',
     'findings/2026-10-26-l5-catalog-missing-path-reported-invalid.md'),
    ('seda-size-max-value', r'size: want I2147483647 got I1000;$', 'code-bug (low)', 'findings/2026-10-26-l5-seda-size-max-value-ignored.md'),
]
# extra buckets kept outside the repository (see the private note): $CAMELSPEC_PRIVATE/classify.tsv, name<TAB>regex<TAB>class
_x = os.path.join(os.environ.get('CAMELSPEC_PRIVATE', ''), 'classify.tsv')
if os.environ.get('CAMELSPEC_PRIVATE') and os.path.exists(_x):
    B = [tuple(l.rstrip('\n').split('\t')[:3]) + ('(see the private note)',) for l in open(_x) if l.strip()] + B
c = Counter(); ex = {}
for f in glob.glob(os.path.join(sys.argv[1], '*.mismatches')):
    for line in open(f):
        if '\tMISMATCH\t' not in line and '\tSETUP\t' not in line: continue
        for name, pat, cls, where in B:
            if re.search(pat, line):
                c[(name, cls, where)] += 1; break
        else:
            c[('unclassified', '-', '-')] += 1; ex.setdefault('unclassified', []).append(line.strip()[:300])
for (n, cls, where), k in sorted(c.items(), key=lambda x: -x[1]):
    print(f'{n}\t{k}\t{cls}\t{where}')
for l in ex.get('unclassified', [])[:15]:
    print('  ', l)
