import tables, times

type
  KeyPair[A, B] = tuple
    key: A
    value: B
    dt: DateTime
  Foo*[A, B] = object
    map*: Table[A, KeyPair[A, B]]

proc initFoo[A, B](): Foo[A, B] = discard 


when isMainModule:
  var a = initFoo[int, int]()
  for i in 1 .. 10:
    a.map[i] = (12, 3, now())

  for key in a.map.keys:
    echo key




  
