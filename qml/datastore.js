.import QtQuick.LocalStorage 2.7 as Sql

var DB_NAME = "ubcrypto"
var DB_VERSION = "1.0"
var DB_DISPLAY_NAME = "UBCrypto Portfolio DB"
var DB_SIZE = 100000

function getDb() {
    return Sql.LocalStorage.openDatabaseSync(DB_NAME, DB_VERSION, DB_DISPLAY_NAME, DB_SIZE)
}


function initializeDatabase() {
    try {
        var db = getDb()
        db.transaction(function (tx) {
            // Portfolios table
            tx.executeSql(`
                          CREATE TABLE IF NOT EXISTS portfolios (
                          id INTEGER PRIMARY KEY AUTOINCREMENT,
                          name TEXT UNIQUE
                          )
                          `)

            // Holdings table (Add new fields here in future)
            tx.executeSql(`
                          CREATE TABLE IF NOT EXISTS holdings (
                          id INTEGER PRIMARY KEY AUTOINCREMENT,
                          portfolio_id INTEGER,
                          coin_symbol TEXT,
                          amount REAL
                          )
                          `)

            // Add new column 'note' to holdings if not exists (example)
            var columnsRs = tx.executeSql("PRAGMA table_info(holdings)")
            var columnExists = false
            for (var i = 0; i < columnsRs.rows.length; ++i) {
                if (columnsRs.rows.item(i).name === "note") {
                    columnExists = true
                    break
                }
            }
            if (!columnExists) {
                tx.executeSql("ALTER TABLE holdings ADD COLUMN note TEXT")
                console.log("[DB] Added 'note' column to holdings")
            }

            // Coins table with extended fields and JSON backup
            tx.executeSql(`
                CREATE TABLE IF NOT EXISTS coins (
                    id TEXT PRIMARY KEY,
                    symbol TEXT UNIQUE,
                    name TEXT,
                    image_url TEXT,
                    current_price REAL,
                    market_cap REAL,
                    market_cap_rank INTEGER,
                    total_volume REAL,
                    high_24h REAL,
                    low_24h REAL,
                    price_change_24h REAL,
                    price_change_percentage_1h REAL,
                    price_change_percentage_24h REAL,
                    price_change_percentage_7d REAL,
                    price_change_percentage_30d REAL,
                    ath REAL,
                    atl REAL,
                    last_updated TEXT,
                    json TEXT
                )
            `)

            tx.executeSql(`CREATE TABLE IF NOT EXISTS portfolio_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                portfolio_id INTEGER,
                date TEXT, -- YYYY-MM-DD
                total_value REAL,
                UNIQUE(portfolio_id, date)
            )`
            )



            console.log("[DB] Database initialized")
        })
    } catch (e) {
        console.log("[DB Error] initializeDatabase: " + e)
    }
}

// Create and fetch all portfolios
function getPortfolios() {
    var list = []
    try {
        var db = getDb()
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
        var db = getDb()
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
        var db = getDb()
        db.transaction(function (tx) {
            tx.executeSql("INSERT INTO portfolios (name) VALUES (?)", [name])
        })
    } catch (e) {
        console.log("DB Error in addPortfolio: " + e)
    }
}

function deletePortfolio(id) {
    try {
        var db = getDb()
        db.transaction(function (tx) {
            tx.executeSql("DELETE FROM holdings WHERE portfolio_id = ?", [id])
            tx.executeSql("DELETE FROM portfolios WHERE id = ?", [id])
        })
    } catch (e) {
        console.log("DB Error in deletePortfolio: " + e)
    }
}

// Add a coin/holding to a portfolio
function addHolding(portfolioId, coinSymbol, amount, overwrite = false) {
    try {
        var db = getDb();
        db.transaction(function (tx) {
            coinSymbol = coinSymbol.toUpperCase();
            var rs = tx.executeSql(
                "SELECT * FROM holdings WHERE portfolio_id = ? AND coin_symbol = ?",
                [portfolioId, coinSymbol]
            );

            if (rs.rows.length > 0) {
                var existing = rs.rows.item(0);
                var newAmount = overwrite ? amount : existing.amount + amount;

                tx.executeSql(
                    "UPDATE holdings SET amount = ? WHERE id = ?",
                    [newAmount, existing.id]
                );
            } else {
                tx.executeSql(
                    "INSERT INTO holdings (portfolio_id, coin_symbol, amount) VALUES (?, ?, ?)",
                    [portfolioId, coinSymbol, amount]
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
        var db = getDb()
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
                var change_24h = ""
                var change_24h_raw = 0

                var change_1h = 0
                var change_7d = 0
                var change_30d = 0
                var market_cap_rank = -1

                // Case-insensitive match
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
                }

                list.push({
                    id:metaRow.id,
                    coin_symbol: symbol,
                    coin_name: name,
                    image_url: image_url,
                    amount: amount,
                    current_price: current_price.toFixed(2),
                    total_value: total_value.toFixed(2),
                    change_24h: change_24h,
                    price_change_percentage_1h: change_1h,
                    price_change_percentage_24h: change_24h_raw,
                    price_change_percentage_7d: change_7d,
                    price_change_percentage_30d: change_30d,
                    market_cap_rank: market_cap_rank
                })
            }
        })
    } catch (e) {
        console.log("DB Error in getHoldings: " + e)
    }
    return list
}

function getTopGainers() {
    var db = getDb()
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
     var db = getDb()
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
    var db = getDb()
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
    var db = getDb()
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
