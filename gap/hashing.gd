#! @Description
#!   Return a hash string for the key using IO_Pickle, SHA-256, and base 64.
#!   This is the default method which users can override by specifying `hash`.
#! @Arguments key
DeclareGlobalFunction("MEMO_Hash");

# Write the integer `n` in base `base`, optionally padding to length `minlen`
# Arguments n, base[, minlen]
DeclareGlobalFunction("MEMO_Digits");
