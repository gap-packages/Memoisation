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
  local memo, h, storedkey, query, namespace, result, args, post_string, url,
        db_response, res;
  memo := cache!.memo;

  # Get hash
  h := memo!.hash(key);

  # Construct MongoDB query as record
  query := rec(hash := h,
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
  url := cache!.url;
  Info(InfoMemoisation, 3, "Posting to ", url);
  Info(InfoMemoisation, 3, "(including ",
       JoinStringsWithSeparator(RecNames(query), ", "), ")");
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
  local item;
  item := MEMO_MongoDBQuery(cache, key);
  return item <> fail;
end);

InstallMethod(LookupDictionary,
"for a memoisation disk cache and an object",
[MEMO_IsMongoDBCache, IsObject],
function(cache, key)
  local memo, item, storedkey;
  memo := cache!.memo;

  # Request item from database
  item := MEMO_MongoDBQuery(cache, key);
  if item = fail then
    # We shouldn't normally get here, as we usually check KnowsDictionary first
    Info(InfoMemoisation, 1, "No entry found in database");
    return fail;
  fi;

  # OPTION: storekey
  if memo!.storekey then
    storedkey := memo!.unpickle(item.key);
    # check if key still matches
    if key <> storedkey then
      ErrorNoReturn("Hash collision: <key> does not match <storedkey>");
    fi;
    Info(InfoMemoisation, 3, "Key matches that stored on the server");
  fi;

  # OPTION: unhash
  if memo!.unhash <> fail then
    # unhash and check if key still matches
    storedkey := memo!.unhash(item.hash);
    if storedkey <> key then
      ErrorNoReturn("Hash collision: <key> does not match <storedkey>");
    fi;
  fi;

  return memo!.unpickle(item.result);
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
  local memo, query, url, db_response, item;
  memo := cache!.memo;

  # Construct the arguments
  query := rec(namespace := MEMO_MongoDBNamespace);
  query := List(RecNames(query), rnam -> Concatenation("%22",
                                                      rnam,
                                                      "%22=%22",
                                                      query.(rnam),
                                                      "%22"));
  query := JoinStringsWithSeparator(query, ",");
  url := Concatenation(cache!.url, "/", memo!.hash(key),
                       "?where={", query, "}");
  Info(InfoMemoisation, 3, "Querying ", url);
  db_response := DownloadURL(url);
  if db_response.success = false then
    # No valid response from server
    Error("MongoDB cache: ", db_response.error);
  fi;
  item := JsonStringToGap(db_response.result);
  if IsBound(item._status) and item._status = "ERR" then
    if item._error.code = 404 then
      # No result for this hash on server (no problem!)
      return fail;
    else
      # Something else went wrong
      Error("MongoDB cache: ", item._error.code, " ", item._error.message);
    fi;
  fi;

  # Return a single item as a record
  return item;
end);
