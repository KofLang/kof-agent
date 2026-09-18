#!/usr/bin/env python3
# E2 (specs/ENGINE_V2.md §5): dataset v4 — conciso + verdade + pedir-esclarecimento.
# Transformacao DETERMINISTICA do v3 (sem saidas inventadas) + seeds de ASK/REFUSE.
# 3 classes de acao: EXECUTE (resultado + <=2 linhas) | ASK (pergunta unica) | REFUSE (motivo tecnico em 1 linha).
import json, re, hashlib, sys, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
V3 = ROOT / 'datasets/jsonl/koflm-v3.jsonl'
V4 = ROOT / 'datasets/jsonl/koflm-v4.jsonl'
EVAL_OLD = ROOT / 'eval/ptbr-suite.jsonl'
EVAL_NEW = ROOT / 'eval/ptbr-suite-v4.jsonl'

ASK_RE = re.compile(r'\b(isso|aquilo|la\b|coisa|bonitinho|mexe|acerta)\b', re.I)
REFUSE_RE = re.compile(r'StringBuilder|\.equals\(|new Thread|\bfun \w|\bfunc \w|\bfn \w|mutableListOf|async|\bval \w|\blet \w|\bPair\(|\?:|\b0\.\.|!!|\bf\(\w+=|\bobject \w|open fun|override fun')

ASK_QUESTIONS = {
    'isso': 'O que exatamente devo mudar em "isso"? Aponte arquivo ou trecho.',
    'aquilo': 'Qual "aquilo"? Dê o nome do arquivo ou função.',
    'ajusta': 'Ajustar o quê para quê? Estado atual e estado desejado.',
    'melhora': 'Melhorar o que, medido por quê? (qual criterio de "melhor")',
    'conserta': 'Consertar o que? Cole o erro ou o comportamento esperado.',
    'arruma': 'Arrumar o quê? Aponte o arquivo e o problema.',
    'resolve': 'Resolver o quê? Qual o resultado que falta?',
}

REFUSE_REASONS = [
    (re.compile(r'StringBuilder', re.I), 'Kof nao tem StringBuilder; concatenacao com + ja e eficiente (training/anti-patterns/fake-idioms.md).'),
    (re.compile(r'\.equals\(', re.I), 'Em Kof == compara conteudo; .equals() e Java (fake-idioms.md).'),
    (re.compile(r'new Thread|Executor', re.I), 'Kof usa spawn/await; nao existe Thread (fake-idioms.md).'),
    (re.compile(r'\bfun \w|\bfunc \w|\bfn \w', re.I), 'Kof nao tem fun/func/fn; declare como "Tipo nome(...) { }".'),
    (re.compile(r'mutableListOf|listOf<.*>\(\)\s*to', re.I), 'Kof tem listOf(); mutableListOf e Kotlin (nao existe).'),
    (re.compile(r'async \w+|async fn', re.I), 'Kof nao tem async; use spawn (KofScript nao e JavaScript).'),
    (re.compile(r'\bval \w|top-level val|let \w', re.I), 'val/var/let so existem dentro de funcoes em Kof (top-level e proibido).'),
    (re.compile(r'\bPair\('), 'Kof nao tem Pair; use record Ponto(Int a, Int b) ou Map (fake-idioms.md).'),
    (re.compile(r'\?:'), 'Kof nao tem Elvis ?:; use if (x != null) ... else ... com narrowing.'),
    (re.compile(r'\b0\.\.'), 'Kof nao tem faixa 0..n; use while ou for-in numa lista.'),
    (re.compile(r'!!'), 'Kof nao tem !!; nullable e T? com teste != null e narrowing.'),
    (re.compile(r'\bobject \w'), 'Kof nao tem object; use uma class com constructor ou funcoes top-level.'),
    (re.compile(r'open fun|override fun'), 'Kof nao tem open/override; heranca se declara com extends, sem modificadores.'),
    (re.compile(r'\b\w+\(\w+='), 'Kof nao tem argumentos nomeados; passe posicoes em ordem.'),
]

def first_sentences(text, n=2):
    body = re.sub(r'```.*?```', '', text, flags=re.S)
    if body.count('\n') < 2:
        body = re.sub(r'\s*##\s+', '\n', body)
    out = []
    for line in body.splitlines():
        l = re.sub(r'[#*`]', '', line).strip()
        if not l or l.startswith('Name') or len(l) < 12:
            continue
        out.append(l[:140])
        if len(out) >= n:
            break
    return ' | '.join(out) if out else re.sub(r'\s+', ' ', body).strip()[:200]

def code_block(text):
    m = re.search(r'```(?:kof)?\s*\n(.*?)\n```', text, flags=re.S)
    return m.group(1).strip() if m else ''

def classify(row):
    inst = row['instruction']
    if REFUSE_RE.search(inst):
        for rx, why in REFUSE_REASONS:
            if rx.search(inst):
                return 'REFUSE', why
    if ASK_RE.search(inst) and len(inst.split()) < 8:
        best = None
        for k, q in ASK_QUESTIONS.items():
            if re.search(r'\b' + k, inst, re.I):
                best = q
        if best is not None:
            return 'ASK', best
    out = row.get('output', '')
    code = code_block(out)
    if code:
        return 'EXECUTE', code + '\n' + first_sentences(out, 1)
    return 'EXECUTE', first_sentences(out, 2)

def bucket_of(h):
    m = int(h[:8], 16) % 100
    return 'train' if m < 75 else ('validation' if m < 87 else 'test')

def emit(rows, src, tag):
    out = []
    for r in rows:
        h = hashlib.sha256((tag + r['instruction']).encode()).hexdigest()
        action, resp = classify(r)
        out.append({'instruction': r['instruction'], 'input': r.get('input', ''),
                    'output': resp, 'action': action, 'bucket': bucket_of(h),
                    'source': r.get('source', src), 'checksum': h[:16]})
    return out

def main():
    v3 = [json.loads(l) for l in open(V3)]
    rows = emit(v3, 'v3-minified', 'v4')
    # ASK seeds (metade train, metade eval) — ambiguidade de 1-2 palavras
    ask_base = ['ajusta isso', 'melhora aquilo', 'conserta la', 'arruma isso', 'resolve aquilo',
                'faz la', 'poe bonitinho', 'refaz aquilo', 'aumenta aquilo', 'diminui isso',
                'troca la', 'atualiza aquilo', 'conserta a coisa', 'acerta aquilo', 'mexe nisso']
    ask_pre = ['', 'agora ', 'por favor ', 'de novo ', 'rapidao: ']
    ask_seeds = [pfx + b for b in ask_base for pfx in ask_pre]
    ref_base = ['reescreva usando StringBuilder no laco', 'chame .equals() nas Strings',
                'crie um new Thread para o worker', 'declare fun processar(x: Int)',
                'use mutableListOf para o acúmulo', 'marque com async fn o handler',
                'crie let config no topo do arquivo', 'adicione override fun salvar()',
                'crie a classe com open fun base', 'retorne Pair(a, b) da funcao',
                'use ?: como fallback padrao', 'facas um map com 0..n', 'marque o campo com !!',
                'chame f(p=v) com argumentos nomeados', 'declare object Singleton']
    ref_ctx = ['', ' para Kof', ' no modulo de tools', ' no engine']
    ref_seeds = [b + c for b in ref_base for c in ref_ctx]
    ask_rows = []
    for s in ask_seeds:
        q = next((v for k, v in ASK_QUESTIONS.items() if re.search(r'\b' + k, s, re.I)),
                 'O que exatamente devo fazer? Aponte arquivo e objetivo.')
        ask_rows.append({'instruction': s, 'input': '', 'output': 'ASK: ' + q,
                         'action': 'ASK', 'bucket': bucket_of(hashlib.sha256(('seedask' + s).encode()).hexdigest()),
                         'source': 'seed-ask', 'checksum': hashlib.sha256(('seedask' + s).encode()).hexdigest()[:16]})
    ref_rows = []
    for s in ref_seeds:
        why = next(w for rx, w in REFUSE_REASONS if rx.search(s))
        ref_rows.append({'instruction': s, 'input': '', 'output': 'REFUSE: ' + why,
                         'action': 'REFUSE', 'bucket': bucket_of(hashlib.sha256(('seedref' + s).encode()).hexdigest()),
                         'source': 'seed-refuse', 'checksum': hashlib.sha256(('seedref' + s).encode()).hexdigest()[:16]})
    allrows = rows + ask_rows + ref_rows
    train = [r for r in allrows if r['bucket'] != 'test']
    with open(V4, 'w') as f:
        for r in train:
            f.write(json.dumps(r, ensure_ascii=False) + '\n')
    # eval: rotula as 540 existentes + seeds ASK/REFUSE de test (disjuntos do train por bucket)
    ev = []
    for l in open(EVAL_OLD):
        e = json.loads(l)
        action, _ = classify({'instruction': e['instruction'], 'output': e.get('expected', '')})
        e['expected_action'] = action
        ev.append(e)
    for r in allrows:
        if r['bucket'] == 'test':
            ev.append({'id': 'v4-' + r['checksum'], 'category': 'acao',
                       'instruction': r['instruction'], 'expected_action': r['action'],
                       'expected_output': r['output']})
    with open(EVAL_NEW, 'w') as f:
        for e in ev:
            f.write(json.dumps(e, ensure_ascii=False) + '\n')
    # baseline report
    import collections
    cnt = collections.Counter(r['action'] for r in train)
    med3 = sorted(len(json.loads(l)['output']) for l in open(V3))[len(v3) // 2]
    med4 = sorted(len(r['output']) for r in train)[len(train) // 2]
    rep = pathlib.Path(ROOT / 'docs/dataset-v4-baseline.md')
    rep.write_text(
        '# Baseline dataset v4 (E2)\n\n'
        '| Metrica | v3 | v4 |\n|---|---|---|\n'
        f'| exemplos (train+val) | {len(v3)} | {len(train)} |\n'
        f'| mediana output (chars) | {med3} | {med4} |\n\n'
        f'Acoes v4: EXECUTE={cnt["EXECUTE"]} ASK={cnt["ASK"]} REFUSE={cnt["REFUSE"]}\n'
        f'Eval rotulada: {len(ev)} itens em eval/ptbr-suite-v4.jsonl '
        f'(acoes: {collections.Counter(e["expected_action"] for e in ev)})\n\n'
        'Regra: saida = resultado + <=2 frases; ambiguo -> ASK de 1 linha; '
        'idioma estrangeiro (Java/Kotlin) -> REFUSE tecnico. Seeds de eval sao '
        'disjuntas do train (hash bucket). Transformacao deterministica, sem '
        'saida inventada: EXECUTE so preserva codigo/documento real do v3.\n')
    print(rep)

if __name__ == '__main__':
    main()
