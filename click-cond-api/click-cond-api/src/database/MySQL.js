const db = require('mysql2');

const { DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD } = process.env;
const dbConfig = {
	host: DB_HOST || '',
	port: parseInt(DB_PORT || '3306', 10),
	user: DB_USER || '',
	password: DB_PASSWORD || '',
	database: DB_NAME || '',
	charset: 'utf8mb4'
};

// Compatibilidade com queries legadas que usam GROUP BY parcial.
// Railway MySQL 8 vem com ONLY_FULL_GROUP_BY ativo por padrão, o que
// rejeita SELECTs com colunas fora do GROUP BY (caso de listCondominios etc).
const SQL_MODE_INIT = `SET SESSION sql_mode = ''`;

function queryDB(query) {
	return new Promise((resolve, reject) => {
		const con = db.createConnection(dbConfig);
		con.connect((connErr) => {
			if (connErr) {
				console.error('[DB] Connection error:', connErr.code, connErr.message);
				resolve({ status: 'Error', error: connErr, results: [] });
				return;
			}
			con.query(SQL_MODE_INIT, (modeErr) => {
				if (modeErr) {
					console.error('[DB] sql_mode set error:', modeErr.message);
				}
				try {
					con.query(query, function (err, results) {
						con.destroy();
						if (err) {
							console.error('[DB] Query error:', err.code, err.sqlMessage || err.message);
							console.error('[DB] Query was:', query.substring(0, 200));
							resolve({ status: 'Error', error: err, results: [] });
							return;
						}
						resolve({ status: 'Success', results });
					});
				} catch (err) {
					console.error('[DB] Sync exception:', err.message);
					reject(err);
				}
			});
		});
	});
}

function queryParamDB(query, params) {
	return new Promise((resolve, reject) => {
		const con = db.createConnection(dbConfig);
		con.connect((connErr) => {
			if (connErr) {
				console.error('[DB] Connection error:', connErr.code, connErr.message);
				resolve({ status: 'Error', error: connErr, results: [] });
				return;
			}
			con.query(SQL_MODE_INIT, (modeErr) => {
				if (modeErr) console.error('[DB] sql_mode set error:', modeErr.message);
				try {
					con.execute(query, params, function (err, results) {
						con.destroy();
						if (err) {
							console.error('[DB] Param Query error:', err.code, err.sqlMessage || err.message);
							resolve({ status: 'Error', error: err, results: [] });
							return;
						}
						resolve({ status: 'Success', results });
					});
				} catch (err) {
					console.error('[DB] Sync exception:', err.message);
					reject(err);
				}
			});
		});
	});
}

function transactionDB(query, callback) {
	const con = db.createConnection(dbConfig);
	con.connect();
	query = query.reverse();
	con.beginTransaction(function (err) {
		con.destroy();
		if (err) {
			callback(err);
			return;
		}
		transactionQuery(query, con, callback);
	});
}

function transactionQuery(comm, con, callback) {
	const query = comm.pop();
	try {
		con.query(query, function (error, results, fields) {
			con.destroy();
			if (error) {
				return con.rollback(function () {
					callback(false);
				});
			}
			if (comm.length > 0) {
				transactionQuery(comm, con, callback);
				return;
			}
			con.commit(function (err) {
				if (err) {
					return con.rollback(function () {
						callback(false);
					});
				} else {
					callback(results);
					return;
				}
			});
		});
	} catch (error) {
		callback(false);
	}
}

module.exports = {
	query: queryDB,
	queryParam: queryParamDB,
	transaction: function (query, callback) {
		transactionDB(query, function (result) {
			callback(result);
		});
	},
};
