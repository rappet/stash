-- Add migration script here

CREATE TABLE
    users (
        id INTEGER PRIMARY KEY ASC,
        user_name TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );