---
id: kof-migration-java-to-kof-en
title: Java to Kof Migration
module: kof
category: kof-migration
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,migration,java-to-kof
status: stable
tags: kof,migration,en
---
[English](kof/migration/java-to-kof.md) | [Português](kof/migration/java-to-kof.pt_BR.md)

# Java to Kof Migration

**Version:** 0.4.0-beta (Sep 2026)

## Classes

### Java
```java
public class User {
    private String name;
    private int age;
    
    public User(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    public String getName() { return name; }
    public int getAge() { return age; }
}
```

### Kof (record-style for immutable data)
```kof
// class X(...) == record X(...): immutable, accessors, reading u.name ok
class User(String name, Int age) {
}
var u = User("Mel", 30)
println(u.name)
```

> **Mutable state (Java's `private` + setters does NOT translate 1:1):** in Kof
> the field is public and mutable — no getter/setter. If the entity changes, use
> a class with fields + `constructor(...)`:
> ```kof
> class User2 {
>     String name
>     Int age
>     public constructor(String name, Int age) {
>         this.name = name
>         this.age = age
>     }
> }
> var u2 = User2("Mel", 30)
> u2.age = 31      // direct field — no setAge()
> ```
> Immutable data → `record User(String name, Int age)` (accessors `u.name()`).

## Records

### Java
```java
public record Point(int x, int y) {}
```

### Kof
```kof
record Point(Int x, Int y)
var p = Point(10, 20)
switch (p) {
    case Point(var x, var y): println(x + "," + y) // destructuring
}
```

## Inheritance

### Java
```java
public class Animal {
    protected String name;
    public Animal(String name) { this.name = name; }
}
public class Dog extends Animal {
    public Dog(String name) { super(name); }
}
```

### Kof
```kof
class Animal(String name) { }
class Dog extends Animal {
    public constructor(String name) { super(name) }
}
```

## Interfaces

### Java
```java
public interface Speaker {
    String speak();
}
public class Dog implements Speaker {
    public String speak() { return "woof"; }
}
```

### Kof
```kof
interface Speaker {
    speak(): String
}
class Dog implements Speaker {
    public speak(): String { return "woof" }
}
```

## Collections

### Java
```java
List<String> list = new ArrayList<>();
list.add("hello");
Map<String, Integer> map = new HashMap<>();
map.put("a", 1);
Set<String> set = new HashSet<>();
```

### Kof (3 targets)
```kof
var list = listOf("hello")
list.add("world")
list.contains("hello")
var x = list.get(0)          // fix 27/08 — no manual workaround
println(list.size)

var map = mapOf("a", 1)
map.put("b", 2)
var v = map.get("a")

var set = setOf(1, 2, 3)
set.add(4)

// Higher-order
var nomes = users.map((u: User) -> u.name)
var pares = nums.filter((x: Int) -> x % 2 == 0)
var soma = nums.reduce((a: Int, b: Int) -> a + b, 0)

// Generics with primitive
var box: Box<Int> = Box(42)
```

`List`, `Map`, `Set` available on JVM/Native/JS with `map/filter/reduce` and `Box<T>`.

## Null safety — Option vs String?

### Java
```java
Optional<String> maybe = Optional.of("hi");
String nullable = null;
```

### Kof (0.4.0-beta)
```kof
String? maybe = mapOf("k", "hi").get("missing")   // null via API, NOT `= null` (SEM048 since 10/09)
if (maybe != null) {
    println(maybe.length)   // narrowing
}
String? other = "ola"
var len = if (other != null) other.length else 0
// generic Option<T> still planned — use String? for simple cases
```

## HTTP

### Java (Spring)
```java
@RestController
public class UserController {
    @GetMapping("/users/{id}")
    public User getUser(@PathVariable Long id) {
        return userService.findById(id);
    }
}
```

### Kof (0.4.0-beta)
```kof
// kof.http client — JVM + JS (Java HttpClient interop), Native HTTP002
// verbs: get/post/put/delete/patch/options
var html = http.get("https://example.com")
var resp = http.post(api, json.encode(user), "Content-Type: application/json")
if (http.status(url) == 404) { println("not found") }
http.timeout(30)    // resilience (30/08): timeout/retry/circuit
http.retry(3)
http.circuit(5)

// web server (JVM ✅; Native base ✅ 03/09 — TLS WEB002, ws WEB004, sse WEB003; JS base ✅ 16/09 — ws/sse = WEB004/WEB003)
var app = web.app()
app.get("/users/:id") { return "user " + param("id") }
return status(201, body())       // custom status per handler
headerSet("X-App", "kof")        // custom headers
app.ws("/chat") { wsSend(wsMessage()) }  // WebSocket
app.sse("/events") { sse.send("tick") }  // SSE
app.listen(8080)
```

## Imports

### Java
```java
import java.util.List;
import java.util.*;
```

### Kof (fix 27/08)
```kof
import a.b.C          // file-specific — large projects now OK
import a.b.*
```

## KofScript

### Java — not applicable

### Kof (0.4.0-beta)
```kof
var x = 5            // top-level var → KofScriptGlobals (.ks)
val y: Int = 10
var name = "Mel"
println(x + y)
```
