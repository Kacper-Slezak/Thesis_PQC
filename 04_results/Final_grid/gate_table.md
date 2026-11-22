| session | dates | attempts | rejected | rejected % | accepted | entry first | entry ok | entry shifted | gate tries | gate CV % | calib ms |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 11-10..11-11 | 40 | 12 | 30 | 28 | 14 | 12 | 14 | 1 | 0.64 | 398 |
| 2 | 11-11..11-12 | 30 | 2 | 7 | 28 | 14 | 12 | 5 | 2 | 0.80 | 425 |
| 3 | 11-13 | 36 | 8 | 22 | 28 | 14 | 10 | 12 | 1 | 0.28 | 390 |
| 4 | 11-12..11-13 | 31 | 3 | 10 | 28 | 14 | 12 | 5 | 1 | 1.18 | 364 |
| 5 | 11-15 | 5 | 1 | 20 | 4 | 4 | 0 | 1 | 1 | 0.14 | 406 |
| total |  | 142 | 26 | 18 | 116 | 60 | 46 | 37 | 6 |  | 394 |

Session 5 re-measured 4 blocks that replace blocks of sessions 1-3 (state flip inside the block, missed by the exit canary), so 112 of the 116 accepted blocks enter the analysis (8 per grid point). Session 2 has two session gates because its first attempt was interrupted by a kubectl exec failure.
