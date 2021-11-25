use rune::{EmitDiagnostics, Diagnostics, Options, Sources};
use rune::termcolor::{ColorChoice, StandardStream};
use runestick::{Any, Context, FromValue, Module, Protocol, Source, Vm, Component};
use std::sync::Arc;

#[derive(Any, Default, Copy, Clone)]
struct Constant {
    value: i64,
}

impl Constant {
    pub fn new() -> Constant {
        Default::default()
    }

    pub fn field_get(&self) -> i64 {
        self.value
    }

    pub fn field_set(&mut self, v: i64) {
        self.value = v;
    }
}

fn main() -> runestick::Result<()> {
    let mut module = Module::new();
    let mut context = Context::with_default_modules()?;

    module.ty::<Constant>()?;
    module.function(&["Constant", "new"], Constant::default)?;
    module.function(&["new_constant"], Constant::new)?;
    module.field_fn(Protocol::GET, "value", Constant::field_get)?;
    module.field_fn(Protocol::SET, "value", Constant::field_set)?;

    context.install(&module)?;

    let mut sources = Sources::new();

    sources.insert(Source::new(
        "test",
        r#"
        pub fn main() {
            let c = Constant::new();
            c.value
        }
        "#,
    ));

    let mut diagnostics = Diagnostics::new();

    let unit = rune::load_sources(
        &context,
        &Options::default(),
        &mut sources,
        &mut diagnostics,
    );
    if !diagnostics.is_empty() {
        let mut writer = StandardStream::stderr(ColorChoice::Always);
        diagnostics.emit_diagnostics(&mut writer, &sources)?;
    }

    let vm = Vm::new(Arc::new(context.runtime()), Arc::new(unit?));
    let output = vm.execute(&["main"], ())?.complete()?;
    let output = i64::from_value(output)?;

    println!("output: {}", output);
    Ok(())
}
