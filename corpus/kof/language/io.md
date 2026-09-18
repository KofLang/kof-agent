---
id: kof-language-io-en
title: kof.io — filesystem API
module: kof
category: kof-language
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,language,io
status: stable
tags: kof,language,en
---
[English](kof/language/io.md) | [Português](kof/language/io.pt_BR.md)

# kof.io — filesystem API

Facts about Kof's official filesystem API. Use it to answer questions
about reading/writing files, working with paths and listing directories.

## Model

- `File`, `Path` and `Directory` are types from `kof.io`.
- All three represent a path; the operations are the same for all three.
- The programmer never sees POSIX, `java.nio`, syscalls or per-platform
  separators: `kof.io` resolves that in the backend (JVM → `java.nio.file`;
  Native → POSIX syscalls on Linux x86-64).
- **`readLine()` (top-level, stdin)** → `String?` (02/09): `null` at EOF on
  JVM and Native (previously Native returned `""`). Handle it with
  `if (line != null)`.

## Path

| Operation | Result |
|----------|-----------|
| `Path("a").resolve("b")` | `a/b` (platform separator) |
| `Path("a/b").parent()` | `a` (or null) |
| `Path("a/b.txt").fileName()` | `b.txt` |
| `Path("a/b.txt").extension()` | `txt` |
| `Path("a/./b/../c").normalize()` | `a/c` |
| `Path("a").isAbsolute()` | `false` |
| `Path("a").toAbsolute().isAbsolute()` | `true` |

`normalize()` resolves `.` and `..`; an empty relative path becomes `.`.

## File

| Operation | Behavior |
|----------|---------------|
| `File("x").exists()` | Bool |
| `File("x").isFile()` / `.isDirectory()` | Bool |
| `File("x").readText()` | `String?` — `null` if it fails (JVM and Native) |
| `File("x").writeText(s)` / `.appendText(s)` | Bool |
| `File("x").readBytes()` | `Int[]` (0-255); `null` if it fails |
| `File("x").writeBytes(b)` / `.appendBytes(b)` | Bool |
| `File("x").size()` | Long; **throws an exception** if the file does not exist (02/09 — no `-1` sentinel) |
| `File("x").delete()` | Bool |
| `File("x").name()` / `.path()` | String |

Statics: `File.exists(p)`, `File.readText(p)`, `File.writeText(p, s)`,
`File.delete(p)`, `File.size(p)`.

## Directory

| Operation | Behavior |
|----------|---------------|
| `Directory("d").exists()` | Bool |
| `Directory("d").create()` | creates; fails if it already exists |
| `Directory("d").createDirectories()` | creates recursively |
| `Directory("d").list()` | `List<String>` of the names (sorted) |
| `Directory("d").delete()` | removes an empty directory |

Iteration:

```kof
for (var entry in dir.list()) {
    println(entry.name)
}
```

`entry.name` and `entry.path` return the entry's own string.

## Examples

```kof
var path = Path("data/users.txt")
path.parent().createDirectories()
path.writeText("Mel\nKof\n")
println(path.readText())
println(path.size())
```

```kof
var file = File("binary.dat")
var bytes = new Int[4]
bytes[0] = 65
bytes[1] = 0
bytes[2] = 255
bytes[3] = 66
file.writeBytes(bytes)
println(file.readBytes().length)
```

## Encoding

- `readText`/`writeText`/`appendText` always use UTF-8.
- The system default encoding is never used.

## Errors

- **Absence as a value (02/09):** `readText()`/`readFile()` return `String?`
  (`null` when the file does not exist) — on the JVM **and** Native (Native
  previously terminated with an error; it now returns `null` like the JVM).
- `size()` **throws** a recoverable exception (`catch (String e)`) for a
  nonexistent file — the `-1` sentinel was removed (it was an anti-pattern in
  the corpus).
- Boolean operations return `true`/`false`.

## Current limitations (0.4.0-beta)

- Native: Linux x86_64 (POSIX syscalls) + riscv64/aarch64 placeholder via qemu; the free-list GC applies to file buffers.
- Symlinks, timestamps and permissions are future.
- There is no streams API (`Reader`/`Writer`); operations are whole-file.
