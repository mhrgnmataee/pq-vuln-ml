#!/usr/bin/env bash
# setup_repo.sh
# اسکریپت ساخت ساختار پروژه‌ی پژوهشی (شناسایی و اولویت‌بندی آسیب‌پذیری‌های کوانتومی با ML)
# اجرا: داخل پوشه‌ی ریپوی کلون‌شده  ->  bash setup_repo.sh
# اسکریپت امن است: فایل‌های موجود را بازنویسی نمی‌کند.

set -euo pipefail

if [ ! -d ".git" ]; then
  echo "خطا: این پوشه یک ریپوی گیت نیست. اول ریپو را clone کنید و وارد پوشه‌اش شوید."
  exit 1
fi

TODAY="$(date +%Y-%m-%d)"

# ---------- ابزار کمکی: نوشتن فایل فقط در صورت نبودن ----------
write_if_missing() {
  local path="$1"
  if [ -e "$path" ]; then
    echo "  [رد شد، موجود است] $path"
    cat > /dev/null   # مصرف stdin
  else
    mkdir -p "$(dirname "$path")"
    cat > "$path"
    echo "  [ساخته شد] $path"
  fi
}

echo "== ساخت پوشه‌ها =="
DIRS=(
  data/raw
  data/interim
  data/labeled
  data/splits
  src/discovery
  src/features
  src/models
  src/eval
  src/utils
  notebooks
  docs
  results/tables
  results/figures
  results/models
  rules/semgrep
  tests
  configs
)
for d in "${DIRS[@]}"; do
  mkdir -p "$d"
done

# فایل .gitkeep برای نگه‌داشتن پوشه‌های خالی
for d in data/raw data/interim data/splits results/tables results/figures results/models notebooks tests; do
  [ -e "$d/.gitkeep" ] || touch "$d/.gitkeep"
done

echo "== .gitignore =="
write_if_missing .gitignore <<'EOF'
# Python
__pycache__/
*.py[cod]
.venv/
venv/
.ipynb_checkpoints/
.pytest_cache/
.mypy_cache/
*.egg-info/

# OS / editor
.DS_Store
Thumbs.db
.idea/
.vscode/

# داده‌های حجیم (مخازن کلون‌شده و خروجی‌های میانی در گیت نمی‌روند)
data/raw/*
!data/raw/.gitkeep
data/interim/*
!data/interim/.gitkeep

# مدل‌های ذخیره‌شده‌ی حجیم
results/models/*
!results/models/.gitkeep

# اسرار
.env
*.key
*.pem
github_token.txt

# MLflow
mlruns/
EOF

echo "== README.md =="
write_if_missing README.md <<'EOF'
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
EOF

echo "== research-log.md =="
write_if_missing research-log.md <<EOF
# Research Log

هر تصمیم، تاریخ و دلیلش را اینجا بنویسید. این فایل بعداً پایه‌ی بخش روش‌شناسی مقاله است.

## قالب هر ورودی
- **تاریخ:**
- **تصمیم / کار انجام‌شده:**
- **دلیل:**
- **جایگزین‌هایی که رد شد:**
- **اثر بر مراحل بعد:**

---

## ${TODAY}
- **تصمیم:** ساخت ساختار اولیه‌ی ریپو.
- **دلیل:** شروع مرحله ۰ (آماده‌سازی محیط).
EOF

echo "== requirements.txt =="
write_if_missing requirements.txt <<'EOF'
# هسته
pandas
numpy
scikit-learn
xgboost
shap
scipy
statsmodels

# تحلیل کد
tree-sitter
tree-sitter-python
tree-sitter-java
semgrep

# مدل‌های زبانی کد
torch
transformers
datasets

# جمع‌آوری داده
requests
PyGithub
python-dotenv
tqdm
pyyaml

# ردیابی آزمایش‌ها و نمودار
mlflow
matplotlib
seaborn

# ابزار توسعه
pytest
jupyter
EOF

echo "== configs =="
write_if_missing configs/config.yaml <<'EOF'
seed: 42

split:
  train: 0.70
  val: 0.15
  test: 0.15
  level: repo        # تقسیم فقط در سطح مخزن

github:
  languages: [Python, Java]
  min_stars: 20
  active_since_years: 2
  target_repos: 400
  allowed_licenses: [mit, apache-2.0, bsd-2-clause, bsd-3-clause, mpl-2.0, isc, unlicense]

discovery:
  context_lines: 10  # تعداد خطوط اطراف هر مورد

labeling:
  sample_size: 2000
  pilot_size: 100
  min_kappa: 0.7
EOF

echo "== docs =="
write_if_missing docs/labeling-guide.md <<'EOF'
# راهنمای برچسب‌گذاری (Labeling Guide)

نسخه: 0.1

## هدف
برچسب‌زدن هر مورد استفاده‌ی رمزنگاری در کد از نظر آسیب‌پذیری کوانتومی و کاربرد.

## برچسب A: وضعیت آسیب‌پذیری
| برچسب | تعریف | مثال |
|---|---|---|
| `QUANTUM_VULNERABLE` | الگوریتم با الگوریتم شور شکسته می‌شود | RSA، ECDSA، ECDH، DH، DSA |
| `WEAKENED` | امنیت با الگوریتم گروور کاهش می‌یابد | AES-128، هش‌های کوتاه (مثل SHA-1/MD5 که ذاتاً ضعیف‌اند) |
| `RESISTANT` | در برابر تهدید کوانتومی شناخته‌شده مقاوم است | AES-256، SHA-384/512، ML-KEM، ML-DSA |
| `AMBIGUOUS` | از کد نمی‌توان تشخیص داد (پارامتر پویا، wrapper) | `Cipher.getInstance(cfg.algo)` |
| `NOT_CRYPTO` | استفاده‌ی غیررمزنگاری (مثلاً هش برای dict) | `hash(x)` در پایتون |

## برچسب B: کاربرد
`KEY_EXCHANGE`، `SIGNATURE`، `DATA_ENCRYPTION`، `HASHING`، `TLS_CONFIG`، `PASSWORD_HASHING`، `RANDOMNESS`، `OTHER`

## قوانین موارد مرزی
1. (اینجا هنگام کار روی نمونه‌ی آزمایشی ۱۰۰تایی اضافه کنید)
2. کد تست و مثال (در مسیرهای test/، examples/) با برچسب `is_test=true` جدا علامت می‌خورد.
3. اگر الگوریتم از ثابت تعریف‌شده در جای دیگر خوانده می‌شود، تا حد ممکن ثابت را دنبال کنید؛ در غیر این صورت `AMBIGUOUS`.

## روند
1. نمونه‌ی آزمایشی ۱۰۰تایی توسط دو برچسب‌زن
2. محاسبه‌ی Cohen's Kappa و اصلاح راهنما
3. برچسب‌گذاری کامل
4. حل اختلاف‌ها و ثبت تصمیم‌ها در همین فایل

## تاریخچه‌ی تغییرات
- 0.1: نسخه‌ی اولیه
EOF

write_if_missing docs/risk-scoring.md <<'EOF'
# معیار امتیاز ریسک کوانتومی

نسخه: 0.1

## فرمول پایه
```
risk = w1*algo + w2*lifetime + w3*exposure + w4*migration
```
هر عامل از ۱ تا ۵ امتیاز می‌گیرد. وزن‌ها را با ارجاع به NIST و CNSA 2.0 توجیه و اینجا ثبت کنید.

| عامل | توضیح | ۱ | ۵ |
|---|---|---|---|
| `algo` | نوع الگوریتم | مقاوم | شکسته‌شدن با Shor |
| `lifetime` | طول عمر محرمانگی داده | داده‌ی زودگذر (لاگ ساده) | داده‌ی چندده‌ساله (پزشکی، مالی، دولتی) |
| `exposure` | میزان در معرض بودن | کتابخانه‌ی داخلی | سرویس عمومی اینترنتی |
| `migration` | سختی مهاجرت | پیکربندی قابل تعویض | کلید/الگوریتم ثابت در پروتکل |

## وزن‌ها (پیش‌نویس، باید توجیه شود)
| عامل | وزن | توجیه |
|---|---|---|
| algo | 0.40 | TODO: منبع |
| lifetime | 0.25 | TODO: منبع |
| exposure | 0.20 | TODO: منبع |
| migration | 0.15 | TODO: منبع |

## اعتبارسنجی
- برای یک زیرمجموعه‌ی کوچک، رتبه‌بندی دو خبره‌ی امنیتی گرفته شود (برای RQ3).
- همبستگی رتبه‌ای (Spearman) با فرمول گزارش شود.
EOF

write_if_missing docs/literature-table.md <<'EOF'
# جدول مرور ادبیات

| # | مرجع | سال | ورودی | روش | خروجی | ضعف / شکاف | مرتبط با |
|---|---|---|---|---|---|---|---|
| 1 | | | | | | | |

## جمله‌ی شکاف پژوهش
(بعد از تکمیل جدول بنویسید)

## baselineهای قابل اجرا
-
EOF

echo "== بسته‌ی src =="
touch src/__init__.py src/discovery/__init__.py src/features/__init__.py \
      src/models/__init__.py src/eval/__init__.py src/utils/__init__.py

write_if_missing src/utils/config.py <<'EOF'
"""بارگذاری تنظیمات پروژه و ثابت‌کردن seed."""
import random
from pathlib import Path

import numpy as np
import yaml

ROOT = Path(__file__).resolve().parents[2]


def load_config(path: str = "configs/config.yaml") -> dict:
    with open(ROOT / path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def set_seed(seed: int) -> None:
    random.seed(seed)
    np.random.seed(seed)
EOF

write_if_missing src/discovery/collect_repos.py <<'EOF'
"""مرحله ۳: انتخاب مخازن از GitHub و ساخت data/splits/repos.csv

خروجی: ستون‌های url, commit, license, language, stars, split
نیاز: متغیر محیطی GITHUB_TOKEN (در فایل .env)
"""
# TODO: جست‌وجو با PyGithub، فیلتر لایسنس، ثبت commit hash، تقسیم در سطح مخزن


def main() -> None:
    raise NotImplementedError("مرحله ۳ هنوز پیاده‌سازی نشده است")


if __name__ == "__main__":
    main()
EOF

write_if_missing src/discovery/extract_crypto.py <<'EOF'
"""مرحله ۴: استخراج استفاده‌ی رمزنگاری (لایه‌ی قاعده‌محور = baseline)

خروجی: data/interim/candidates.jsonl
هر رکورد: repo, file, line, algorithm, params, context (±N خط)
"""
# TODO: Semgrep / tree-sitter برای Python و Java


def main() -> None:
    raise NotImplementedError("مرحله ۴ هنوز پیاده‌سازی نشده است")


if __name__ == "__main__":
    main()
EOF

write_if_missing src/features/build_features.py <<'EOF'
"""مرحله ۶: ساخت ویژگی‌ها (دستی، AST، زمینه‌ی کد)."""
# TODO


def main() -> None:
    raise NotImplementedError


if __name__ == "__main__":
    main()
EOF

write_if_missing src/models/train_classifier.py <<'EOF'
"""مرحله ۶: آموزش طبقه‌بند (RandomForest / XGBoost / CodeBERT).

نکته: cross-validation فقط به‌صورت GroupKFold بر اساس مخزن.
"""
# TODO


def main() -> None:
    raise NotImplementedError


if __name__ == "__main__":
    main()
EOF

write_if_missing src/models/train_risk.py <<'EOF'
"""مرحله ۶: مدل امتیاز ریسک (رگرسیون یا Learning-to-Rank)."""
# TODO


def main() -> None:
    raise NotImplementedError


if __name__ == "__main__":
    main()
EOF

write_if_missing src/eval/evaluate.py <<'EOF'
"""مرحله ۷: ارزیابی نهایی (فقط یک‌بار روی test).

Precision/Recall/F1، ablation، McNemar/bootstrap، SHAP، Spearman، NDCG@k.
"""
# TODO


def main() -> None:
    raise NotImplementedError


if __name__ == "__main__":
    main()
EOF

echo "== قاعده‌ی نمونه‌ی Semgrep =="
write_if_missing rules/semgrep/python-crypto.yml <<'EOF'
rules:
  - id: py-rsa-keygen
    languages: [python]
    severity: INFO
    message: RSA key generation (quantum-vulnerable)
    pattern-either:
      - pattern: rsa.generate_private_key(...)
      - pattern: RSA.generate(...)
  - id: py-ec-keygen
    languages: [python]
    severity: INFO
    message: Elliptic-curve key generation (quantum-vulnerable)
    pattern-either:
      - pattern: ec.generate_private_key(...)
      - pattern: ECC.generate(...)
EOF

write_if_missing rules/semgrep/java-crypto.yml <<'EOF'
rules:
  - id: java-keypairgenerator
    languages: [java]
    severity: INFO
    message: KeyPairGenerator usage (check algorithm, likely quantum-vulnerable)
    pattern: KeyPairGenerator.getInstance($ALG, ...)
  - id: java-cipher
    languages: [java]
    severity: INFO
    message: Cipher usage (check algorithm and key size)
    pattern: Cipher.getInstance($ALG, ...)
EOF

echo "== تست اولیه =="
write_if_missing tests/test_smoke.py <<'EOF'
def test_imports():
    import src.utils.config  # noqa: F401
EOF

echo "== .env.example =="
write_if_missing .env.example <<'EOF'
GITHUB_TOKEN=put_your_token_here
EOF

echo
echo "ساختار ساخته شد. مراحل بعد:"
echo "  git add ."
echo "  git commit -m \"chore: initial project structure\""
echo "  git push origin HEAD"
