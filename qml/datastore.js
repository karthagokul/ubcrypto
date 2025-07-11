.import QtQuick.LocalStorage 2.7 as Sql
.import "db_core.js" as DBCore


// Create and fetch all portfolios
function getPortfolios() {
    var list = []
    try {
        var db = DBCore.getDb()
        db.transaction(function (tx) {
            var rs = tx.executeSql("SELECT * FROM portfolios ORDER BY id DESC")
            for (var i = 0; i < rs.rows.length; ++i) {
                list.push(rs.rows.item(i))
            }
        })
    } catch (e) {
        console.log("DB Error in getPortfolios: " + e)
    }
    return list
}

function getAllCoins() {
    var coins = []
    try {
        var db = DBCore.getDb()
        db.transaction(function (tx) {
            var rs = tx.executeSql("SELECT * FROM coins ORDER BY market_cap DESC")
            for (var i = 0; i < rs.rows.length; ++i) {
                coins.push(rs.rows.item(i))
            }

        })
    } catch (e) {
        console.log("DB Error in getAllCoins: " + e)
    }
    return coins
}


function addPortfolio(name) {
    try {
        var db = DBCore.getDb()
        db.transaction(function (tx) {
            tx.executeSql("INSERT INTO portfolios (name) VALUES (?)", [name])
        })
    } catch (e) {
        console.log("DB Error in addPortfolio: " + e)
    }
}

function deletePortfolio(id) {
    try {
        var db = DBCore.getDb()
        db.transaction(function (tx) {
            tx.executeSql("DELETE FROM holdings WHERE portfolio_id = ?", [id])
            tx.executeSql("DELETE FROM portfolios WHERE id = ?", [id])
        })
    } catch (e) {
        console.log("DB Error in deletePortfolio: " + e)
    }
}
function addHolding(portfolioId, coinSymbol, amount, overwrite = false) {
    try {
        var db = DBCore.getDb()
        db.transaction(function (tx) {
            coinSymbol = coinSymbol.toUpperCase();

            // Get current price from coins table
            var meta = tx.executeSql("SELECT current_price FROM coins WHERE LOWER(symbol) = LOWER(?)", [coinSymbol]);
            if (meta.rows.length === 0) {
                console.log("⚠️ No coin data found for: " + coinSymbol);
                return;
            }

            var current_price = meta.rows.item(0).current_price || 0;
            var newPurchaseValue = current_price * amount;

            var rs = tx.executeSql("SELECT * FROM holdings WHERE portfolio_id = ? AND coin_symbol = ?", [portfolioId, coinSymbol]);

            if (rs.rows.length > 0) {
                var existing = rs.rows.item(0);

                if (overwrite) {
                    // Overwrite everything — use the latest price to record purchase value
                    tx.executeSql(
                        "UPDATE holdings SET amount = ?, total_purchase_value = ? WHERE id = ?",
                        [amount, newPurchaseValue, existing.id]
                    );
                } else {
                    // Add to existing amount and total purchase value
                    var updatedAmount = existing.amount + amount;
                    var updatedPurchaseValue = (existing.total_purchase_value || 0) + newPurchaseValue;

                    tx.executeSql(
                        "UPDATE holdings SET amount = ?, total_purchase_value = ? WHERE id = ?",
                        [updatedAmount, updatedPurchaseValue, existing.id]
                    );
                }
            } else {
                // New record — insert with calculated purchase value
                tx.executeSql(
                    "INSERT INTO holdings (portfolio_id, coin_symbol, amount, total_purchase_value) VALUES (?, ?, ?, ?)",
                    [portfolioId, coinSymbol, amount, newPurchaseValue]
                );
            }
        });
    } catch (e) {
        console.log("DB Error in addHolding: " + e);
    }
}
function getHoldings(portfolioId) {
    var list = []
    try {
        var db = DBCore.getDb()
        db.transaction(function (tx) {
            var rs = tx.executeSql("SELECT * FROM holdings WHERE portfolio_id = ?", [portfolioId])
            for (var i = 0; i < rs.rows.length; ++i) {
                var row = rs.rows.item(i)

                var amount = row.amount
                var symbol = row.coin_symbol
                var name = symbol
                var image_url = ""
                var current_price = 0
                var total_value = 0
                var total_purchase_value = row.total_purchase_value
                var delta = 0
                var delta_percent = 0
                var change_24h = ""
                var change_24h_raw = 0

                var change_1h = 0
                var change_7d = 0
                var change_30d = 0
                var market_cap_rank = -1

                // Get metadata first so we can compute total_value
                var meta = tx.executeSql("SELECT * FROM coins WHERE LOWER(symbol) = LOWER(?)", [symbol])
                if (meta.rows.length > 0) {
                    var metaRow = meta.rows.item(0)
                    name = metaRow.name
                    image_url = metaRow.image_url
                    current_price = metaRow.current_price || 0
                    change_1h = metaRow.price_change_percentage_1h || 0
                    change_24h_raw = metaRow.price_change_percentage_24h || 0
                    change_7d = metaRow.price_change_percentage_7d || 0
                    change_30d = metaRow.price_change_percentage_30d || 0
                    market_cap_rank = metaRow.market_cap_rank || -1

                    total_value = current_price * amount
                    change_24h = (change_24h_raw >= 0 ? "+" : "") + change_24h_raw.toFixed(2) + "%"

                    // Backfill purchase value if missing
                    if (total_purchase_value === null || total_purchase_value === undefined || total_purchase_value === 0) {
                        total_purchase_value = total_value
                        tx.executeSql("UPDATE holdings SET total_purchase_value = ? WHERE id = ?", [total_purchase_value, row.id])
                        console.log("📦 Backfilled purchase value for", symbol, "→", total_purchase_value.toFixed(2))
                    }

                    // Calculate delta and percent
                    delta = total_value - total_purchase_value
                    if (total_purchase_value > 0) {
                        delta_percent = (delta / total_purchase_value) * 100
                    }

                    list.push({
                        id: metaRow.id,
                        coin_symbol: symbol,
                        coin_name: name,
                        image_url: image_url,
                        amount: amount,
                        current_price: current_price.toFixed(2),
                        total_value: total_value.toFixed(2),
                        total_purchase_value: total_purchase_value.toFixed(2),
                        delta: delta.toFixed(2),
                        delta_percent: delta_percent.toFixed(2),
                        change_24h: change_24h,
                        price_change_percentage_1h: change_1h,
                        price_change_percentage_24h: change_24h_raw,
                        price_change_percentage_7d: change_7d,
                        price_change_percentage_30d: change_30d,
                        market_cap_rank: market_cap_rank
                    })
                } else {
                    console.log("⚠️ Coin metadata not found for symbol:", symbol)
                }
            }
        })
    } catch (e) {
        console.log("DB Error in getHoldings: " + e)
    }
   // console.log("📊 Final holdings list:", JSON.stringify(list, null, 2))
    return list
}


function getTopGainers() {
    var db = DBCore.getDb()
    var result = [];

    db.transaction(function(tx) {
        var rs = tx.executeSql(`
                               SELECT * FROM coins
                               WHERE price_change_percentage_24h IS NOT NULL
                               ORDER BY price_change_percentage_24h DESC
                               LIMIT 20
                               `);

        for (var i = 0; i < rs.rows.length; i++) {
            result.push(rs.rows.item(i));
        }
    });

    return result;
}

function getTopLosers() {
    var db = DBCore.getDb()
    var result = [];

    db.transaction(function(tx) {
        var rs = tx.executeSql(`
                               SELECT * FROM coins
                               WHERE price_change_percentage_24h IS NOT NULL
                               ORDER BY price_change_percentage_24h ASC
                               LIMIT 20
                               `);

        for (var i = 0; i < rs.rows.length; i++) {
            result.push(rs.rows.item(i));
        }
    });

    return result;
}


function getPortfolioHistory(portfolioId) {
    var db = DBCore.getDb()
    var results = [];

    db.readTransaction(function (tx) {
        var rs = tx.executeSql(
                    `SELECT date, total_value
                    FROM portfolio_history
                    WHERE portfolio_id = ?
                    ORDER BY date ASC`,
                    [portfolioId]
                    );

        for (var i = 0; i < rs.rows.length; i++) {
            results.push({
                             date: rs.rows.item(i).date,
                             total_value: rs.rows.item(i).total_value
                         });
        }
    });

    return results;
}


function deleteHolding(portfolioId, coinSymbol) {
    var db = DBCore.getDb()
    try {
        db.transaction(function(tx) {
            tx.executeSql(
                        `DELETE FROM holdings WHERE portfolio_id = ? AND coin_symbol = ?`,
                        [portfolioId, coinSymbol]
                        );
            console.log(`Holding deleted: ${coinSymbol} from portfolio ${portfolioId}`);
        });
    } catch (error) {
        console.error("Failed to delete holding:", error);
    }
}
