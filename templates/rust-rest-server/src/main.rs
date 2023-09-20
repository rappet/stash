use actix_web::{web, App, HttpServer};
use anyhow::Result;
use clap::Parser;
use paperclip::actix::OpenApiExt;
use tracing::info;
use tracing_actix_web::TracingLogger;

use rust_rest_server_template::cli::Cli;

mod database;
mod model;
mod routes;

use database::Database;

#[actix_web::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();
    let args = Cli::parse();

    let database = web::Data::new(Database::connect(&args.database_file).await?);

    info!(
        http_address = args.http_address,
        http_port = args.http_port,
        "start http server"
    );
    HttpServer::new(move || {
        App::new()
            .app_data(database.clone())
            .wrap(TracingLogger::default())
            .wrap_api()
            .service(routes::info)
            .service(routes::hello)
            .service(routes::get_users)
            .with_json_spec_at("/api/spec/v1")
            .with_swagger_ui_at("/api")
            .build()
    })
    .bind((args.http_address, args.http_port))?
    .run()
    .await?;

    Ok(())
}
