use anyhow::{Context, Result};
use sqlx::{
    migrate,
    sqlite::{SqliteConnectOptions, SqliteJournalMode, SqlitePoolOptions},
    Pool, Sqlite,
};
use tracing::info;

use crate::model::User;

pub struct Database {
    pool: Pool<Sqlite>,
}

impl Database {
    pub async fn connect(database_path: &str) -> Result<Self> {
        info!(database_path, "connecting to database");
        let pool = SqlitePoolOptions::new()
            .connect_with(
                SqliteConnectOptions::new()
                    .filename(database_path)
                    .create_if_missing(true)
                    .journal_mode(SqliteJournalMode::Wal),
            )
            .await
            .context("failed connecting to database")?;

        info!("running database migrations");
        migrate!("./migrations").run(&pool).await?;

        Ok(Self { pool })
    }

    pub async fn add_user(&self, name: &str) -> Result<()> {
        sqlx::query("INSERT INTO users (user_name) VALUES ($1);")
            .bind(name)
            .execute(&self.pool)
            .await?;
        Ok(())
    }

    pub async fn get_users(&self) -> Result<Vec<User>> {
        Ok(
            sqlx::query_as("SELECT id, user_name AS name, created_at FROM users;")
                .fetch_all(&self.pool)
                .await?,
        )
    }
}
