from api_client import get_coin_detail,get_prices,get_chart_data
import json

if __name__ == "__main__":
    data = get_prices(["bitcoin", "ethereum"])
    print(json.dumps(data, indent=2))

    details = get_coin_detail("bitcoin")
    print(details.get("name"), details.get("market_data", {}).get("current_price", {}).get("usd"))

    chart = get_chart_data("bitcoin", days=7)
    print(f"7-day chart points: {len(chart.get('prices', []))}")
