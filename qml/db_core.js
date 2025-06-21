.import QtQuick.LocalStorage 2.7 as Sql

var DB_NAME = "ubcrypto"
var DB_VERSION = "1.0"
var DB_DISPLAY_NAME = "UBCrypto Portfolio DB"
var DB_SIZE = 100000

function getDb() {
    return Sql.LocalStorage.openDatabaseSync(DB_NAME, DB_VERSION, DB_DISPLAY_NAME, DB_SIZE)
}

function initializeDatabase() {
    var db = getDb();

    function createOrUpdateTable(label, createSQL, matchColumnList) {
        try {
            db.transaction(function (tx) {
                tx.executeSql(createSQL);
                console.log("✅ Created table: " + label);

                var info = tx.executeSql('PRAGMA table_info(' + label + ')');
                var existingCols = [];
                for (var i = 0; i < info.rows.length; i++) {
                    existingCols.push(info.rows.item(i).name);
                }

                for (var j = 0; j < matchColumnList.length; j++) {
                    var colName = matchColumnList[j].split(' ')[0];
                    if (!existingCols.includes(colName)) {
                        tx.executeSql(`ALTER TABLE ${label} ADD COLUMN ${matchColumnList[j]}`);
                        console.log("➕ Added column: " + matchColumnList[j] + " to " + label);
                    }
                }
            });
        } catch (e) {
            console.log("❌ Failed to create or update " + label + ": " + e);
        }
    }

    // Portfolios Table
    createOrUpdateTable("portfolios",
        `CREATE TABLE IF NOT EXISTS portfolios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE
        )`,
        ['id INTEGER', 'name TEXT']
    );

    // Holdings Table
    createOrUpdateTable("holdings",
        `CREATE TABLE IF NOT EXISTS holdings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            portfolio_id INTEGER,
            coin_symbol TEXT,
            amount REAL
        )`,
        [
            'id INTEGER',
            'portfolio_id INTEGER',
            'coin_symbol TEXT',
            'amount REAL',
            'note TEXT',
            'total_purchase_value REAL',      // Or replace with average_buy_price
            'average_buy_price REAL',
            'last_purchase_date TEXT'
        ]
    );


    // Coins Table
    createOrUpdateTable("coins",
        `CREATE TABLE IF NOT EXISTS coins (
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
        )`,
        ['id TEXT', 'symbol TEXT', 'name TEXT', 'image_url TEXT', 'current_price REAL', 'market_cap REAL',
         'market_cap_rank INTEGER', 'total_volume REAL', 'high_24h REAL', 'low_24h REAL',
         'price_change_24h REAL', 'price_change_percentage_1h REAL', 'price_change_percentage_24h REAL',
         'price_change_percentage_7d REAL', 'price_change_percentage_30d REAL', 'ath REAL', 'atl REAL',
         'last_updated TEXT', 'json TEXT']
    );

    // Portfolio History Table
    createOrUpdateTable("portfolio_history",
        `CREATE TABLE IF NOT EXISTS portfolio_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            portfolio_id INTEGER,
            date TEXT,
            total_value REAL,
            UNIQUE(portfolio_id, date)
        )`,
        ['id INTEGER', 'portfolio_id INTEGER', 'date TEXT', 'total_value REAL']
    );

    console.log("[DB] ✅ Database initialized with all required tables and fields");
}

