# ROLLBACK (M8)
Toda tarefa mutadora gera backup `.katool-bak` antes da mutação (M4);
rollback.generated publicado no build do plano; restauração via
fs.rollbackRestore(backupPath,target) consumindo o backup.
Compiles/tests dependem do canal do compilador (GW-EXEC) e entram como
validation steps bloqueados-explicitos até J2/GW001 fecharem.
