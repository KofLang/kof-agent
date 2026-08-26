#!/usr/bin/env python3
"""KofLM QLoRA trainer — roda por dias se preciso; resume-safe; checkpoint a cada save_steps."""
import json, math, os, sys, time, pathlib
import torch
from datasets import Dataset
from transformers import (AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig,
                          TrainingArguments, Trainer, DataCollatorForLanguageModeling)
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training

CFG_PATH = pathlib.Path("training/configs/koflm.yaml")

def load_cfg():
    cfg = {}
    for line in CFG_PATH.read_text().splitlines():
        if ":" in line and not line.startswith("#"):
            k, v = line.split(":", 1)
            cfg[k.strip()] = v.strip()
    return cfg

def main():
    cfg = load_cfg()
    seed = int(cfg.get("seed", 42))
    torch.manual_seed(seed)
    out = pathlib.Path(cfg["output_dir"]); out.mkdir(parents=True, exist_ok=True)

    tok = AutoTokenizer.from_pretrained(cfg["model"])
    for st in json.loads(cfg.get("special_tokens", "[]")):
        tok.add_special_tokens({"additional_special_tokens": [st]})
    tok.pad_token = tok.eos_token

    rows = [json.loads(l) for l in open(cfg["dataset"]) if l.strip()]
    def fmt(r):
        return f"<kof>{r['instruction']}\n{r.get('input','')}</kof>\n{r['output']}</fix>"
    ds = Dataset.from_list([{"text": fmt(r)} for r in rows])
    ds = ds.map(lambda b: tok(b["text"], truncation=True, max_length=int(cfg["context"])),
                batched=True, remove_columns=["text"])

    bnb = BitsAndBytesConfig(load_in_4bit=True, bnb_4bit_quant_type="nf4",
                             bnb_4bit_compute_dtype=torch.bfloat16 if torch.cuda.is_bf16_supported() else torch.float16)
    model = AutoModelForCausalLM.from_pretrained(cfg["model"], quantization_config=bnb,
                                                 device_map="auto", torch_dtype="auto")
    model = prepare_model_for_kbit_training(model)
    model.resize_token_embeddings(len(tok))
    lora = LoraConfig(r=int(cfg["lora_rank"]), lora_alpha=int(cfg["lora_alpha"]),
                      lora_dropout=float(cfg["lora_dropout"]), task_type="CAUSAL_LM",
                      target_modules=["q_proj","k_proj","v_proj","o_proj","gate_proj","up_proj","down_proj"])
    model = get_peft_model(model, lora)
    model.print_trainable_parameters()

    args = TrainingArguments(
        output_dir=str(out / "checkpoints"),
        num_train_epochs=int(cfg["epochs"]),
        per_device_train_batch_size=int(cfg["batch_size"]),
        gradient_accumulation_steps=int(cfg["gradient_accumulation_steps"]),
        learning_rate=float(cfg["learning_rate"]),
        lr_scheduler_type="cosine",
        warmup_ratio=float(cfg["warmup_ratio"]),
        logging_steps=10,
        save_steps=int(cfg["save_every_steps"]),
        save_total_limit=3,
        bf16=(cfg.get("bf16") == "auto" and torch.cuda.is_available()),
        fp16=not torch.cuda.is_available(),
        optim="paged_adamw_8bit" if torch.cuda.is_available() else "adamw_torch",
        report_to=[],
        seed=seed,
    )
    trainer = Trainer(model=model, args=args, train_dataset=ds,
                      data_collator=DataCollatorForLanguageModeling(tok, mlm=False))
    ckpts = sorted((out / "checkpoints").glob("checkpoint-*"))
    trainer.train(resume_from_checkpoint=str(ckpts[-1]) if ckpts else None)
    trainer.save_model(str(out / "adapter-final"))
    tok.save_pretrained(str(out / "adapter-final"))
    (out / "TRAINING_DONE").write_text(f"finished={time.time():.0f} examples={len(ds)}\n")
    print("TREINO CONCLUÍDO — rodar scripts/merge_export_gguf.sh")

if __name__ == "__main__":
    main()
