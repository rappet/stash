use assert_cmd::prelude::*;
use predicates::prelude::*;
use std::process::Command;

#[test]
fn prints_hello_world() -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = Command::cargo_bin("rust-rest-server-template")?;

    cmd.assert()
        .success()
        .stdout(predicate::str::contains("Hello, World!"));

    Ok(())
}

#[test]
fn prints_hello_name() -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = Command::cargo_bin("rust-rest-server-template")?;

    cmd.arg("-n").arg("Fnord");
    cmd.assert()
        .success()
        .stdout(predicate::str::contains("Hello, Fnord!"));

    Ok(())
}
