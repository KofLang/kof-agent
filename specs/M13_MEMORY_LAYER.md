# M13 — AGENT MEMORY LAYER
MemoryLayer(clock): put(key,kind,value,ttl) · get · remove · purgeExpired ·
byKind(episodic|semantic|session) · snapshotTo/restoreFrom(MEMSNP v1) ·
statsJson. TTL por entrada; expiração lazy no get/purge.
