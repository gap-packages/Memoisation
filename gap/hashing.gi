MEMO_Base64Digits :=
  "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_";

InstallGlobalFunction(MEMO_Digits,
function(n, base, args...)
  local minlen, len, digits, str;
  # Adapted from the DigitsNumber function in GAPDoc-1.6.1
  if Length(args) = 0 then
    minlen := 0;
  elif Length(args) = 1 then
    minlen := args[1];
  else
    return fail;
  fi;
  digits := MEMO_Base64Digits;
  str := "";
  while n <> 0 do
    Add(str, digits[(n mod base) + 1]);
    n := QuoInt(n, base);
  od;
  if Length(str) < minlen then
    # Pad with zeroes
    Append(str, ListWithIdenticalEntries(minlen - Length(str), digits[1]));
  fi;
  return Reversed(str);
end);

InstallGlobalFunction(MEMO_Hash,
function(key)
  local str, ints, sum, i;
  str := IO_Pickle(key);  # Pickle the key to a string
  ints := SHA256String(str);  # Get the SHA-256 checksum in 32-bit chunks
  sum := 0;  # Bring all 256 bits together into a single integer
  for i in [1..Length(ints)] do
    sum := sum + ints[i] * 2 ^ (32 * (i-1));
  od;
  str := MEMO_Digits(sum, 64, 43);  # Make into a padded base-64 string
  return str;
end);
