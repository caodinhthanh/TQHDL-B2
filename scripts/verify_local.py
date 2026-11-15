"""Execute project SQL against original CSVs in SQLite, without Snowflake credentials."""
import csv
import json
import re
import sqlite3
from decimal import Decimal
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def main():
    db = sqlite3.connect(":memory:")
    counts = {}
    for table in ("customers", "orders", "products"):
        with (ROOT / "data" / f"{table}.csv").open(encoding="utf-8-sig", newline="") as f:
            reader = csv.DictReader(f)
            fields = reader.fieldnames
            rows = list(reader)
        columns = [f'"{c}" ' + ("NUMERIC" if c in ("OrderCostPrice", "OrderSellingPrice") else "TEXT") for c in fields]
        db.execute(f"create table source_{table} ({','.join(columns)})")
        db.executemany(f"insert into source_{table} values ({','.join('?' for _ in fields)})", [tuple(r[c] if r[c] != "" else None for c in fields) for r in rows])
        counts[table] = len(rows)

    def render(sql):
        sql = re.sub(r"\{\{\s*source\('globalmart',\s*'([^']+)'\)\s*\}\}", r"source_\1", sql)
        sql = re.sub(r"\{\{\s*ref\('([^']+)'\)\s*\}\}", r"\1", sql)
        return re.sub(r"\{\{\s*config\(.*?\)\s*\}\}", "", sql)

    for path in [*(ROOT / "models/raw").glob("*.sql"), ROOT / "models/staging/stg_orders.sql", *(ROOT / "models/reporting").glob("*.sql")]:
        db.execute(f"create view {path.stem} as " + render(path.read_text()))
    checks = {}
    for path in sorted((ROOT / "tests").glob("*.sql")):
        result = db.execute(render(path.read_text())).fetchall()
        checks[path.stem] = {"rows": len(result), "status": "WARN" if result and path.stem.startswith("warn_") else "FAIL" if result else "PASS"}
        if not path.stem.startswith("warn_"):
            assert not result, (path.name, result[:5])
    totals = {}
    for model, column in [("stg_orders", "orderprofit"), ("customer_profit", "profit"), ("product_profit", "profit")]:
        totals[model] = str(Decimal(str(db.execute(f"select sum({column}) from {model}").fetchone()[0])).quantize(Decimal("0.01")))
    for model in ("customer_profit", "product_profit"):
        cur = db.execute(f"select * from {model} order by profit desc limit 10")
        with (ROOT / "docs" / f"{model}_top10.csv").open("w", encoding="utf-8", newline="") as f:
            writer = csv.writer(f); writer.writerow([d[0] for d in cur.description]); writer.writerows(cur)
    report = {"engine": "SQLite local SQL verification; not a Snowflake execution", "source_rows": counts, "staging_rows": db.execute("select count(*) from stg_orders").fetchone()[0], "report_rows": {m: db.execute(f"select count(*) from {m}").fetchone()[0] for m in ("customer_profit", "product_profit")}, "profit_totals": totals, "checks": checks}
    (ROOT / "docs/local_validation.json").write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print(json.dumps(report, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    main()
