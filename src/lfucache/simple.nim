import tables, options


type
  CachedInfo* = tuple
    hits: int
    misses: int
    maxSize: int

  KeyPair*[B] = tuple
    valuePart: B
    hits: int

  LFUCached*[A, B] = object
    map: Table[A, KeyPair[B]]
    info: CachedInfo

proc initLFUCached*[A, B](maxSize: int): LFUCached[A, B] =
  result.info.maxSize = maxSize

proc get*[A, B](x: var LFUCached[A, B], key: A): Option[B] =
  if key in x.map:
    x.info.hits += 1
    x.map[key].hits += 1
    return some(x.map[key].valuePart)
  x.info.misses += 1
  return none(B)

proc put*[A, B](x: var LFUCached[A, B], key: A, value: B) =
  if key in x.map:
    x.info.hits += 1
    x.map[key].hits += 1
    x.map[key].valuePart = value
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
  x.map[key] = (value, 0)




when isMainModule:
  import random, timeit


  randomize(128)

  timeOnce("cached"):
    var s = initLFUCached[int, int](128)
    for i in 1 .. 1000:
      s.put(rand(1 .. 200), rand(1 .. 126))
    s.put(5, 6)
    echo s.get(12)
    echo s.get(14).isNone
    echo s.get(5)
    echo s.info
    echo s.map.len
