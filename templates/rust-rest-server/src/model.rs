use chrono::{DateTime, Utc};
use paperclip::actix::Apiv2Schema;
use serde::{Deserialize, Serialize};
use sqlx::FromRow;

/// Information about the server software
#[derive(Serialize, Deserialize, Apiv2Schema)]
pub struct ServerInfo {
    /// Name of the application
    pub name: String,
    /// Description of the application
    pub description: String,
    /// Software version
    pub version: String,
}

/// Someone who was greeted
#[derive(Serialize, Deserialize, Apiv2Schema, FromRow)]
pub struct User {
    /// Database ID of an user
    pub id: i64,
    /// Name the user wants to be greet with
    pub name: String,
    /// Time the user was greeted
    pub created_at: Option<DateTime<Utc>>,
}
