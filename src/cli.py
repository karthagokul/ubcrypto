import sqlite3
from api_client import get_coins
import json
import threading
import time
from pathlib import Path
import logging

DB_FILE = "UBCrypto"
SYNC_INTERVAL_SECONDS = 900  # 15 minutes

from logger import setup_logger
log = setup_logger()

from datetime import datetime

def update_portfolio_snapshots(conn):
    cursor = conn.cursor()
    today = datetime.now().strftime("%Y-%m-%d")

    portfolios = cursor.execute("SELECT id FROM portfolios").fetchall()

    for (portfolio_id,) in portfolios:
        holdings = cursor.execute("""
            SELECT h.coin_symbol, h.amount, c.current_price
            FROM holdings h
            JOIN coins c ON LOWER(h.coin_symbol) = LOWER(c.symbol)
            WHERE h.portfolio_id = ?
        """, (portfolio_id,)).fetchall()

        total_value = sum(amount * (price or 0) for symbol, amount, price in holdings)

        cursor.execute("""
            INSERT OR REPLACE INTO portfolio_history (id, portfolio_id, date, total_value)
            VALUES (
                COALESCE(
                    (SELECT id FROM portfolio_history WHERE portfolio_id = ? AND date = ?),
                    NULL
                ),
                ?, ?, ?
            )
        """, (portfolio_id, today, portfolio_id, today, total_value))

    conn.commit()


def check_table_exists(db_path, table_name):
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = [row[0] for row in cursor.fetchall()]
        print(f"[DEBUG] Tables in DB: {tables}")
        conn.close()
        return table_name in tables
    except Exception as e:
        print(f"[ERROR] Failed to inspect DB: {e}")
        return False

    import json
    from datetime import datetime

def is_file_present(file_path):
    file = Path(file_path)
    if file.exists() and file.is_file():
        log.error(f"[INFO] File exists: {file_path}")
        return True
    else:
        log.error(f"[ERROR] File NOT found: {file_path}")
        return False


def resolve_qml_db_path(app_id=DB_FILE):

    db_paths = []
    current_dir = Path(__file__).parent.resolve()

    # Real user home, e.g., /home/gokul
    user_home = Path.home()
    db_paths.append(user_home / ".local" / "share" / app_id / "Databases")

    # Clickable sandbox, e.g., /home/gokul/.clickable/home/
    clickable_home = user_home / ".clickable" / "home"
    db_paths.append(clickable_home / ".local" / "share" / app_id / "Databases")

    for db_dir in db_paths:
        log.debug(f"[DEBUG] Checking DB path: {db_dir}")
        if not db_dir.exists():
            continue

        sqlite_files = list(db_dir.glob("*.sqlite"))
        if sqlite_files:
            latest = max(sqlite_files, key=lambda f: f.stat().st_mtime)
            log.debug(f"[INFO] Found QML DB: {latest}")
            if is_file_present(latest):
                log.debug(f"file is present {latest}")
                return str(latest)
            else:
                log.critical(f"SQlite file found , but do not see a table")

    log.debug("[ERROR] No QML DB found.")
    return None

def sync_coins():
    try:
        coins = get_coins(limit=500)
        conn = sqlite3.connect(resolve_qml_db_path())
        c = conn.cursor()

        for coin in coins:
            meta = coin.get("json", {})
            c.execute('''
                INSERT OR REPLACE INTO coins (
                    id, symbol, name, image_url, current_price,
                    market_cap, market_cap_rank, total_volume,
                    high_24h, low_24h, price_change_24h,
                    price_change_percentage_1h,
                    price_change_percentage_24h,
                    price_change_percentage_7d,
                    price_change_percentage_30d,
                    ath, atl, last_updated, json
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                coin.get("id"),
                coin.get("symbol", "").upper(),
                coin.get("name"),
                meta.get("image"),
                meta.get("current_price"),
                meta.get("market_cap"),
                meta.get("market_cap_rank"),
                meta.get("total_volume"),
                meta.get("high_24h"),
                meta.get("low_24h"),
                meta.get("price_change_24h"),
                meta.get("price_change_percentage_1h_in_currency"),
                meta.get("price_change_percentage_24h_in_currency"),
                meta.get("price_change_percentage_7d_in_currency"),
                meta.get("price_change_percentage_30d_in_currency"),
                meta.get("ath"),
                meta.get("atl"),
                meta.get("last_updated"),
                json.dumps(meta)  # Keep full JSON for future flexibility
            ))

        update_portfolio_snapshots(conn)
        conn.commit()      
        conn.close()
        print(f"[✔] Synced {len(coins)} coins.")
    except Exception as e:
        print(f"[ERROR] Sync failed: {e}")


def background_sync_loop():
    while True:
        sync_coins()
        time.sleep(SYNC_INTERVAL_SECONDS)

def start_background_sync():
    thread = threading.Thread(target=background_sync_loop, daemon=True)
    thread.start()
    print("Background coin sync started.")
