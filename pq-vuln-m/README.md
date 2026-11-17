# pq-vuln-ml

A Machine Learning-Based Framework for Detecting and Prioritizing
Quantum-Vulnerable Cryptographic Usage in Software Systems.

چارچوبی مبتنی بر یادگیری ماشین برای شناسایی و اولویت‌بندی آسیب‌پذیری‌های کوانتومی در سیستم‌های نرم‌افزاری.

## ساختار پروژه

```
data/
  raw/        مخازن کلون‌شده (در گیت نیست)
  interim/    خروجی‌های میانی (در گیت نیست)
  labeled/    داده‌ی برچسب‌خورده (در گیت هست)
  splits/     تقسیم train/val/test در سطح مخزن
src/
  discovery/  لایه‌ی کشف قاعده‌محور (baseline)
  features/   مهندسی ویژگی
  models/     مدل‌های ML (RF/XGBoost/CodeBERT/Ranking)
  eval/       ارزیابی، ablation، آزمون آماری
  utils/      توابع کمکی و تنظیمات
rules/semgrep/  قواعد Semgrep
docs/           راهنمای برچسب‌گذاری، معیار ریسک
results/        جدول‌ها، نمودارها، مدل‌ها
notebooks/      تحلیل اکتشافی
configs/        تنظیمات (seed، نسبت تقسیم، ...)
```

## راه‌اندازی

```bash
python -m venv .venv
source .venv/bin/activate        # ویندوز: .venv\Scripts\activate
pip install -r requirements.txt
pip freeze > requirements.lock.txt
```

## قواعد پژوهش

1. تقسیم داده فقط در سطح مخزن (repo-level) و یک‌بار ثابت می‌شود.
2. مجموعه‌ی test قفل است و فقط یک‌بار برای ارزیابی نهایی استفاده می‌شود.
3. هر تصمیم در `research-log.md` ثبت می‌شود.
