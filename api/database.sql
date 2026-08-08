CREATE TABLE files (
    job_id BIGINT PRIMARY KEY,
    file_ids VARCHAR(255)[] NOT NULL,
);
