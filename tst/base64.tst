# MEMO_Digits: a few corner cases
gap> MEMO_Digits(1000, 16);
"3E8"
gap> MEMO_Digits(25, 8);
"31"
gap> MEMO_Digits(25, 8, 5);
"00031"
gap> MEMO_Digits(100, 25, true, false);
fail
