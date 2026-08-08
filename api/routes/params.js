"use strict";

import contractJson from "../FreelancePlatform.json" with { type: "json" }
import config from "../contract-address.json" with { type: "json" }
import { ethers } from "ethers";

const contract = new ethers.Contract(config.address, contractJson.abi, new ethers.JsonRpcProvider(process.env.RPC_URL));

export async function getJobById(req, res, next, id) {
    const addr = req.query.address || req.address;

    try {
        const job = (await contract.jobs(id)).toObject();
    } catch (e) {
        console.log(e);
        return req.status(404).json({ msg: "Job not found" });
    }

    if (addr != job.client && addr != job.freelancer)
        return req.status(403).json({ msg: "Address not authorized" })

    job.id = id;
    req.job = job;
    next();
}
