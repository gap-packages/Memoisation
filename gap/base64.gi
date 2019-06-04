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

