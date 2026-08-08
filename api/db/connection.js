"use strict";

import knex from "knex";

const db = knex({
    client: 'pg',
    connection: {
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        user: process.env.USER,
        password: process.env.PSW,
        database: process.env.DB_NAME,
    },
});

async function waitForDb(knex, retries = 10, delay = 2000) {
    for (let i = 0; i < retries; i++) {
        try {
            await knex.raw('select 1+1 as result');
            console.log('Db connection ready...');
            return;
        } catch (err) {
            console.warn(`Cannot connect to db (attempt ${i + 1} / ${retries})`);
            if (i === retries - 1)
                throw err;
            await new Promise((res) => setTimeout(res, delay));
        }
    }
}

try {
    await waitForDb(db);
} catch (err) {
    console.log(err);
    process.exit(1);
}

export default db;
