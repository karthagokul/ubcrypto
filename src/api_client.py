# backend/api_client.py

import json
import urllib.request

COINGECKO_BASE = "https://api.coingecko.com/api/v3"


def get_coin_detail(coin_id):
    """
    Get coin metadata and current data
    """
    url = f"{COINGECKO_BASE}/coins/{coin_id}?localization=false"
    print(f"[API] Fetching coin detail: {url}")
    try:
        with urllib.request.urlopen(url) as response:
            return json.loads(response.read().decode())
    except Exception as e:
        print(f"[Error] Coin detail fetch failed: {e}")
        return {}

def get_chart_data(coin_id, days=1):
    """
    Get market chart data for a coin over the last N days (default = 1)
    """
    url = f"{COINGECKO_BASE}/coins/{coin_id}/market_chart?vs_currency=usd&days={days}"
    print(f"[API] Fetching chart: {url}")
    try:
        with urllib.request.urlopen(url) as response:
            return json.loads(response.read().decode())
    except Exception as e:
        print(f"[Error] Chart fetch failed: {e}")
        return {}

def get_coins(limit=1000):
        per_page = 250
        pages = (limit + per_page - 1) // per_page
        results = []

        for page in range(1, pages + 1):
            url = f"{COINGECKO_BASE}/coins/markets?vs_currency=usd&order=market_cap_desc&per_page={per_page}&page={page}&sparkline=false&price_change_percentage=1h,24h,7d,30d,90d"
            print(f"[API] Fetching page {page}: {url}")

            try:
                with urllib.request.urlopen(url) as response:
                    data = json.loads(response.read().decode())
                    for coin in data:
                        results.append({
                            "id": coin.get("id"),
                            "name": coin.get("name"),
                            "symbol": coin.get("symbol").upper(),
                            "price": coin.get("current_price"),
                            "change24h": coin.get("price_change_percentage_24h"),
                            "image": coin.get("image"),
                            "json":coin,
                        })
            except Exception as e:
                print(f"[Error] Page {page} failed: {e}")
                raise ("[Error] Page {page} failed: {e}")

        return results[:limit]
