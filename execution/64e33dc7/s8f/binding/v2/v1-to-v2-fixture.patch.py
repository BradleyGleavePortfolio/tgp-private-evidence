# RT-NEW-1 v1 -> v2 fixture substitution (environment pins only; lane logic unchanged)
import sys
p=sys.argv[1]; s=open(p).read()
R=[
("EXEC-DACEDDC8 under 64e33dc7 runtime","EXEC-1910A060 under the 1910a060 runtime (binding v2, RT-NEW-1)"),
("execution/64e33dc7/s8f/binding/v1/s8f-pg-proof.sh","execution/64e33dc7/s8f/binding/v2/s8f-pg-proof.sh"),
("port 55643 (daceddc8 SCOPE guard port;","port 55643 (S8-F guard port kept from v1; not occupied in the 1910a060 environment;"),
("#   * FRESH NAMESPACE (RUNTIME_SETUP_RECEIPT §Donor-copy 6-7): binaries from the SHA-pinned\n#     recovery-reset/pg17/dist; data and socket directories under recovery-reset/proof-s8f-v1/clusters/s8-f and\n#     recovery-reset/proof-s8f-v1/run/s8-f (fresh S8-F lane; every S8-C and S7-L lane under proof-*/clusters is another lane, retained, never adopted)",
 "#   * FRESH NAMESPACE (execution/1910a060/runtime/RUNTIME_SETUP_RECEIPT.md): binaries from the SHA-pinned\n#     execution/1910a060/runtime/pg17/dist; data and socket directories under 1910a060/runtime/proof-s8f-v2/clusters/s8-f and\n#     1910a060/runtime/proof-s8f-v2/run/s8-f (fresh S8-F lane; any other lane under clusters/* or proof-*/clusters is another lane, retained, never adopted)"),
("RUNTIME_ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset","RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime"),
("proof-s8f-v1/","proof-s8f-v2/"),
]
for a,b in R:
    assert a in s, a
    s=s.replace(a,b)
open(p,'w').write(s)
