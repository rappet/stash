use actix_web::{App, Error, HttpServer};
use anyhow::Result;
use clap::Parser;
use paperclip::actix::{
    api_v2_operation, get,
    web::{Json, Path},
    Apiv2Schema, OpenApiExt,
};
use serde::{Deserialize, Serialize};
use tracing::{debug, info};
use tracing_actix_web::TracingLogger;

use rust_rest_server_template::cli::Cli;

#[derive(Serialize, Deserialize, Apiv2Schema)]
struct ServerInfo {
    name: String,
    description: String,
    version: String,
}

#[api_v2_operation]
#[get("/info")]
async fn info() -> Result<Json<ServerInfo>, Error> {
    debug!("host is asking for server info");
    Ok(Json(ServerInfo {
        name: env!("CARGO_PKG_NAME").to_string(),
        description: env!("CARGO_PKG_DESCRIPTION").to_string(),
        version: env!("CARGO_PKG_VERSION").to_string(),
    }))
}

#[api_v2_operation]
#[get("/api/v1/hello/{name}")]
async fn hello(params: Path<String>) -> Result<Json<String>, Error> {
    let name = params.into_inner();
    debug!("host is asking for server info");
    Ok(Json(format!("Hello, {name}!")))
}

#[actix_web::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();
    let args = Cli::parse();

    info!(
        http_address = args.http_address,
        http_port = args.http_port,
        "start http server"
    );
    HttpServer::new(|| {
        App::new()
            .wrap(TracingLogger::default())
            .wrap_api()
            .service(info)
            .service(hello)
            .with_json_spec_at("/api/spec/v1")
            .with_swagger_ui_at("/api")
            .build()
    })
    .bind((args.http_address, args.http_port))?
    .run()
    .await?;

    Ok(())
}
