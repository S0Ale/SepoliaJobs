"use strict";

export async function errHandler(err, req, res, next) {
    console.error(`Error handling ${req.originalUrl} from ${req.ip}, caused by: ${err}`);

    if (res.headersSent)
        return next(err);
    if (err)
        return res.send(500).json({ msg: "Error while connecting with the database" });

    next();
}
