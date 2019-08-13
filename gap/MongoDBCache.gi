InstallGlobalFunction(MEMO_MongoDBCache,
function(memo, path)
  local url, cache, type;

  # Full URL including function name
  url := path;
  if not EndsWith(url, "/") then
    Add(url, '/');
  fi;
  Append(url, memo!.funcname);

  # Make cache object
  cache := rec(memo := memo,  # memoised function
               url := url);  # URL of the database
  # Objectify
  type := NewType(DictionariesFamily, MEMO_IsMongoDBCache);
  cache := Objectify(type, cache);

  return cache;
end);

InstallMethod(AddDictionary,
"for a memoisation disk cache and two objects",
[MEMO_IsMongoDBCache, IsObject, IsObject],
function(cache, key, val)
  local memo, h, storedkey, query, hash, namespace, result, args, post_string,
        db_response, res;
  memo := cache!.memo;

  # Get hash
  h := memo!.hash(key);

  # OPTION: unhash
  if memo!.unhash <> fail then
    # unhash and check if key still matches
    storedkey := memo!.unhash(h);
    if storedkey <> key then
      ErrorNoReturn("Hash collision: <key> does not match <storedkey>");
    fi;
  fi;

  # Construct MongoDB query as record
  query := rec(funcname := memo!.funcname,
               hash := h,
               namespace := MEMO_MongoDBNamespace,
               result := memo!.pickle(val));

  # OPTION: storekey
  if memo!.storekey then
    query.key := memo!.pickle(key);
  fi;

  # OPTION: metadata
  if memo!.metadata <> fail then
    query.metadata := memo!.metadata();
  fi;

  # Query the server
  args := List(RecNames(query), rnam -> Concatenation(rnam, "=", query.(rnam)));
  post_string := JoinStringsWithSeparator(args, "&");
  db_response := PostToURL(cache!.url, post_string);
  if db_response.success = false then
    # No valid response from server
    Error("AddDictionary (MongoDB cache): ", db_response.error);
  fi;
  res := JsonStringToGap(db_response.result);

  if res._status = "ERR" then
    # Problem with database
    Error("AddDictionary (MongoDB cache): ", res);
  elif res._status = "OK" then
    # Success
    return;
  fi;
  Error("AddDictionary (MongoDB cache): ",
        "<res>._status should be \"ERR\" or \"OK\"");

  # no return value
end);

InstallMethod(KnowsDictionary,
"for a memoisation disk cache and an object",
[MEMO_IsMongoDBCache, IsObject],
function(cache, key)
  local items;
  items := MEMO_MongoDBQuery(cache, key);
  return Length(items) > 0;
end);

InstallMethod(LookupDictionary,
"for a memoisation disk cache and an object",
[MEMO_IsMongoDBCache, IsObject],
function(cache, key)
  local memo, items, storedkey;
  memo := cache!.memo;

  # Request list of items (hopefully length 1)
  items := MEMO_MongoDBQuery(cache, key);
  if Length(items) = 0 then
    # We shouldn't normally get here, as we usually check KnowsDictionary first
    Info(InfoMemoisation, 1, "No entry found in database");
    return fail;
  fi;

  # OPTION: storekey
  if memo!.storekey then
    storedkey := memo!.unpickle(items[1].key);
    # check if key still matches
    if key <> storedkey then
      ErrorNoReturn("Hash collision: <key> does not match <storedkey>");
    fi;
    Info(InfoMemoisation, 2, "Key matches that stored on the server");
  fi;

  return memo!.unpickle(items[1].result);
end);

InstallMethod(MEMO_ClearCache,
"for a memoisation disk cache",
[MEMO_IsMongoDBCache],
function(cache)
  local db_response;
  db_response := DeleteURL(cache!.url);
  if db_response.success <> true then
    Error("MongoDB cache: failed to clear");
  fi;
  return db_response.success;
end);

InstallGlobalFunction(MEMO_MongoDBQuery,
function(cache, key)
  local memo, url, db_response, items;
  memo := cache!.memo;
  url := Concatenation(cache!.url,
                       "?where={%22funcname%22:%22", memo!.funcname,  # needed?
                       "%22,%22hash%22:%22", memo!.hash(key),
                       "%22}");  # TODO: pypersist just GETs /funcname/hash
  db_response := DownloadURL(url);
  if db_response.success = false then
    # No valid response from server
    Error("MongoDB cache: ", db_response.error);
  fi;
  items := JsonStringToGap(db_response.result)._items;
  if Length(items) >= 2 then
    Error("MongoDB cache: Multiple database entries for function ",
          memo!.funcname, " and hash ", memo!.hash(key));
  fi;
  return items;
end);
