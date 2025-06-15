.import QtQuick.LocalStorage 2.7 as Sql

var DB_NAME = "ubcrypto"
var DB_VERSION = "1.0"
var DB_DISPLAY_NAME = "UBCrypto Portfolio DB"
var DB_SIZE = 100000

function getDb() {
    return Sql.LocalStorage.openDatabaseSync(DB_NAME, DB_VERSION, DB_DISPLAY_NAME, DB_SIZE)
}

// Create and fetch all portfolios
function getPortfolios() {
    var list = []
    try {
        var db = getDb()
        db.transaction(function (tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS portfolios (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE)")
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
            tx.executeSql("CREATE TABLE IF NOT EXISTS coins (id TEXT PRIMARY KEY, symbol TEXT, name TEXT, json TEXT)")
            var rs = tx.executeSql("SELECT json FROM coins ORDER BY name COLLATE NOCASE")
            for (var i = 0; i < rs.rows.length; ++i) {
                var raw = rs.rows.item(i).json
                var obj = JSON.parse(raw)
                coins.push(obj)
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
function addHolding(portfolioId, coinSymbol, amount) {
    try {
        var db = getDb()
        db.transaction(function (tx) {
            tx.executeSql(`
                CREATE TABLE IF NOT EXISTS holdings (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    portfolio_id INTEGER,
                    coin_symbol TEXT,
                    amount REAL
                )
            `)

            // If coin already exists, update the amount
            var rs = tx.executeSql("SELECT * FROM holdings WHERE portfolio_id = ? AND coin_symbol = ?", [portfolioId, coinSymbol.toUpperCase()])
            if (rs.rows.length > 0) {
                var existing = rs.rows.item(0)
                var newAmount = existing.amount + amount
                tx.executeSql("UPDATE holdings SET amount = ? WHERE id = ?", [newAmount, existing.id])
            } else {
                tx.executeSql("INSERT INTO holdings (portfolio_id, coin_symbol, amount) VALUES (?, ?, ?)", [portfolioId, coinSymbol.toUpperCase(), amount])
            }
        })
    } catch (e) {
        console.log("DB Error in addHolding: " + e)
    }
}

function getHoldings(portfolioId) {
    var list = []
    try {
        var db = getDb()
        db.transaction(function (tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS holdings (id INTEGER PRIMARY KEY AUTOINCREMENT, portfolio_id INTEGER, coin_symbol TEXT, amount REAL)")
            var rs = tx.executeSql("SELECT * FROM holdings WHERE portfolio_id = ?", [portfolioId])
            for (var i = 0; i < rs.rows.length; ++i) {
                list.push(rs.rows.item(i))
            }
        })
    } catch (e) {
        console.log("DB Error in getHoldings: " + e)
    }
    return list
}
