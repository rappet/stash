use actix_web::{error::ErrorBadRequest, web::Data, Error};
use paperclip::actix::{
    api_v2_operation, get,
    web::{Json, Path},
};
use tracing::debug;

use crate::{
    database::Database,
    model::{ServerInfo, User},
};

/// Gives information about this web service
#[api_v2_operation]
#[get("/info")]
pub async fn info() -> Result<Json<ServerInfo>, Error> {
    debug!("host is asking for server info");
    Ok(Json(ServerInfo {
        name: env!("CARGO_PKG_NAME").to_string(),
        description: env!("CARGO_PKG_DESCRIPTION").to_string(),
        version: env!("CARGO_PKG_VERSION").to_string(),
    }))
}

#[api_v2_operation]
#[get("/api/v1/hello/{name}")]
pub async fn hello(params: Path<String>, db: Data<Database>) -> Result<Json<String>, Error> {
    let name = params.into_inner();
    db.add_user(&name).await.map_err(ErrorBadRequest)?;
    debug!("host is asking for server info");
    Ok(Json(format!("Hello, {name}!")))
}

#[api_v2_operation]
#[get("/api/v1/users")]
pub async fn get_users(db: Data<Database>) -> Result<Json<Vec<User>>, Error> {
    let users = db.get_users().await.map_err(ErrorBadRequest)?;
    Ok(Json(users))
}
