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
  local memo, post_string, db_response, res;
  memo := cache!.memo;
  post_string := Concatenation("funcname=", memo!.funcname,
                               "&hash=", memo!.hash(key),
                               "&namespace=", MEMO_MongoDBNamespace,
                               "&result=", memo!.pickle(val));
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
  local items;
  items := MEMO_MongoDBQuery(cache, key);
  if Length(items) = 0 then
    # We shouldn't normally get here, as we usually check KnowsDictionary first
    return fail;
  fi;
  return cache!.memo!.unpickle(items[1].result);
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
