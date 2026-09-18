---
id: kof-language-security-en
title: Security (kof.security)
module: kof
category: kof-language
version: 1
languageVersion: 0.4.0
author: Kof4j
createdAt: 2026-09-18
updatedAt: 2026-09-18
keywords: kof,language,security
status: stable
tags: kof,language,en
---
[English](kof/language/security.md) | [Português](kof/language/security.pt_BR.md)

# Security (kof.security)

`kof.security` is the Standard Library's security layer: passwords, crypto,
JWT, secrets and web authentication — secure by default, with target gaps
reported at compile time (SECN00x).

## Intent

```kof
passwords.hash(password)                  // secure by default
passwords.verify(password, storedHash)    // constant-time
jwt.create(claimsJson, secret)            // HS256 + iat/exp
jwt.verify(token, secret, iss, aud)       // sig + exp + iss + aud
secrets.get("API_KEY")                    // env, never logged
secrets.redact(value)                     // for logs
security.constantTimeEquals(a, b)         // safe comparison
crypto.sha256(data) / crypto.hmacSha256(key, data)
crypto.encryptAesGcm(text, keyHex) / decryptAesGcm(ct, keyHex)
```

## Anti-patterns

- `sha256(password)` to store a password — use `passwords.hash`.
- `==` to compare tokens/hashes — use `security.constantTimeEquals`.
- Printing secrets in logs — use `secrets.redact`.
- Trusting the token's `alg` — Kof fixes HS256.

## Web

```kof
auth.secret("s3cret")
app.use {
    if (!auth.authenticated()) { return "{\"error\":\"unauthorized\"}" }
    if (!auth.hasRole("admin")) { return "{\"error\":\"forbidden\"}" }
    return null
}
```

## Support per target (0.4.0-beta)

| Function | JVM | Native | JS |
|--------|-----|--------|----|
| passwords (PBKDF2 600k) | ✅ | ✅ (asm SHA-256 + hmac) | ✅ (via platform) |
| sha256 / hmacSha256 | ✅ | ✅ | ✅ |
| sha512 | ✅ | ✅ (asm FIPS 180-4) | ✅ |
| aesGcm | ✅ | ✅ (asm; SECN002 closed 30/08) | ❌ SECN002 |
| jwt HS256 | ✅ | ✅ (asm, iat/exp/iss/aud) | ✅ |
| secrets | ✅ | ✅ (/proc/self/environ) | ✅ |
| constantTimeEquals | ✅ | ✅ | ✅ |
| web auth (rateLimit/sessions/apiKeys) | ✅ | ✅ | ✅ |

Reference: docs/stdlib/security.md (0.4.0-beta), learn/36-security.md.
