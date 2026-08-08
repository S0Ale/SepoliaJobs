"use strict";

import db from "../db/connection.js";

export async function getFiles(req, res) {
    const j_files = await db("files")
        .where({ id: req.job.id })
        .first();

    if (!files)
        return req.status(404).json({ msg: "Job not found" });

    res.json({ file_ids: j_files.file_ids });
}

export async function submit(req, res) {
    if (!req.file_ids || req.file_ids.some((id) => !id))
        return res.status(400).json({ msg: "Invalid file ids" });

    await db("files")
        .insert({
            job_id: job.id,
            file_ids: req.file_ids
        });
    res.send();
}
