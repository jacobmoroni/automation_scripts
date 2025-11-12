# !/usr/bin/env python3
import requests
import yaml
import os
from datetime import datetime


def isInStock(name, product):
    """Scrapes website to see if the item is in stock

    Args:
        name (string): name of the product
        product (dict): product dictionary from config.yaml

    Returns:
        tuple availble(bool), message(string): availability status and message
    """
    response = requests.get(product["url"], timeout=5)
    if response.status_code != 200:
        message = f"Failed to fetch product JSON (status {response.status_code})"
        return None, message

    product_data = response.json()
    for variant in product_data.get("variants", []):
        if variant["id"] == product["variant_id"]:
            title = variant["title"]
            available = variant["available"]
            message = f"{name}:{title} -> {'IN STOCK' if available else 'SOLD OUT'}"
            return available, message
    message = "Variant not found."
    return None, message


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(script_dir, "config.yaml")
    config = yaml.safe_load(open(config_path, "r", encoding="utf-8"))
    products = config["products"]
    for product in products:
        name = product
        message = ""
        last_check = products[product].get("last_check")
        current_date = str(datetime.now().date())
        if products[product].get("last_date_reset") != current_date:
            last_check = None
            products[product]["last_date_reset"] = current_date
            message = f"Resetting last_check for {name} for new day.\n"
        print(f"Checking stock for {name}...")
        in_stock, stock_message = isInStock(name, products[product])
        current_time = datetime.now().strftime("%m-%d-%Y %H:%M")
        if in_stock != last_check:
            if in_stock is None:
                message += f"[{current_time}] Could not determine stock status for {name}: {stock_message}."
            else:
                message += f"[{current_time}] {stock_message}"
            requests.post(
                "https://ntfy.sh/jacob_in_stock_notifications", data=message, timeout=5
            )
            # Update last_check in the config
            products[product]["last_check"] = in_stock
    with open(config_path, "w", encoding="utf-8") as f:
        yaml.dump(config, f)


if __name__ == "__main__":
    main()
