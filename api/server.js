"use strict";

import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";

// import { authenticate } from "./middlewares/auth.js";
import { getJobById } from "./routes/params.js";
import { getFiles, submit } from "./routes/submissions.js";

const app = express();

const allowedOrigins = ["http://localhost:3000", "http://localhost:4000"];

app.use(
    cors({
        origin: function (origin, callback) {
            if (!origin || allowedOrigins.includes(origin)) {
                callback(null, true);
            } else {
                callback(new Error("Not allowed by CORS"));
            }
        },
        credentials: true
    }),
    express.json(),
);

const wrapRoute = fn => (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
};
const wrapParam = fn => (req, res, next, value) => {
    Promise.resolve(fn(req, res, next, value)).catch(next);
};

app.param("jid", wrapParam(getJobById));

app.get("/submissions/:jid", wrapRoute(getFiles));
app.post("/submissions/:jid", wrapRoute(submit));


