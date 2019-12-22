import tables, options, times


type
  CachedInfo* = tuple
    hits: int
    misses: int
    maxSize: int
    lasting: int

  KeyPair*[B] = tuple
    valuePart: B
    hits: int
    expire: DateTime # seconds

  LFUCached*[A, B] = object
    map: Table[A, KeyPair[B]]
    info: CachedInfo


proc initLFUCached*[A, B](maxSize: int, lasting: int = 10): LFUCached[A, B] =
  result.info.maxSize = maxSize
  result.info.lasting = lasting


proc get*[A, B](x: var LFUCached[A, B], key: A): Option[B] =
  if key in x.map:
    x.info.hits += 1
    x.map[key].hits += 1
    return some(x.map[key].valuePart)
  x.info.misses += 1
  return none(B)

proc put*[A, B](x: var LFUCached[A, B], key: A, value: B, expire: int) =
  if key in x.map:
    x.info.hits += 1
    x.map[key].hits += 1
    x.map[key].valuePart = value
    x.map[key].expire = now() + initDuration(seconds = expire)
    return
  x.info.misses += 1
  if x.map.len >= x.info.maxSize:
    var minValue = high(int)
    var minkey: B
    for key in x.map.keys:
      if x.map[key].hits < minValue:
        minValue = x.map[key].hits
        minkey = key
    x.map.del(minKey)
    var allDelKey: seq[A]
    for key, value in x.map.pairs:
      if value.expire >= now():
        allDelkey.add(key)
    while x.map.len >= x.info.maxSize:
      for key, value in x.map.pairs:
        if value.expire >= now():
          allDelkey.add(key)
    for key in allDelKey:
      x.map.del(key)
  x.map[key] = (value, 0, now() + initDuration(seconds = x.info.lasting))





when isMainModule:
  import random, timeit, times, os


  randomize(128)

  var s = initLFUCached[int, int](128)
  for i in 1 .. 1000:
    s.put(rand(1 .. 200), rand(1 .. 126), rand(2 .. 4))
  s.put(5, 6, 3)
  echo s.get(12)
  echo s.get(14).isNone
  echo s.get(5)
  echo s.info
  echo s.map.len
  sleep(5)
  echo s.map
