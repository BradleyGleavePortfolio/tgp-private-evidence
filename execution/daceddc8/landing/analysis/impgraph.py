import subprocess,re,os,sys,json
T='bb5436dd249744c52d5d1d0a30618a81c2b62829'
B='93389265a846095b846fa8f1fb0dad782fb6ee9f';L='a68cdac70d81aea384fdc99c01c9c983a08e80eb';C='87018a421f5be1064767d2cdd32e75ca935f7cdb'
def g(*a): return subprocess.run(['git',*a],capture_output=True,text=True).stdout
files=[f for f in g('ls-tree','-r','--name-only',T).split('\n') if re.search(r'\.(ts|js|cjs)$',f) and (f.startswith('src/') or f.startswith('test/') or f.startswith('scripts/'))]
fs=set(files)
Lc=set(g('diff','--name-only',B,L).split())-{'src/analytics/events.ts'}; Cc=set(g('diff','--name-only',B,C).split())
# batch read
out=subprocess.run(['git','cat-file','--batch'],input='\n'.join(f'{T}:{f}' for f in files).encode(),capture_output=True).stdout
# parse batch
deps={}
i=0;idx=0
data=out
pos=0
for f in files:
    nl=data.index(b'\n',pos); hdr=data[pos:nl].split(); size=int(hdr[2]); body=data[nl+1:nl+1+size].decode('utf8','replace'); pos=nl+1+size+1
    ds=set()
    for m in re.finditer(r"""(?:from\s+|require\(\s*|import\(\s*|import\s+)['"](\.{1,2}/[^'"]+)['"]""",body):
        p=os.path.normpath(os.path.join(os.path.dirname(f),m.group(1)))
        for cand in [p,p+'.ts',p+'.js',p+'.cjs',p+'/index.ts']:
            if cand in fs: ds.add(cand);break
    deps[f]=ds
memo={}
def closure(f):
    if f in memo: return memo[f]
    memo[f]=set()
    s={f}
    for d in deps.get(f,()): s|=closure(d)
    memo[f]=s; return s
specs=[f for f in files if re.search(r'\.spec\.ts$',f)]
res=[]
for s in specs:
    cl=closure(s)
    a=bool(cl&Lc); b=bool(cl&Cc)
    if a and b: res.append((s,sorted(cl&Lc)[:3],sorted(cl&Cc)[:3]))
print(len(specs),'specs total;',len(res),'span both sides')
for r in res: print(r[0],'| S7L:',r[1],'| S8C:',r[2])
