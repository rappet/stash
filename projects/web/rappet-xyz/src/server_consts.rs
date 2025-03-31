use include_dir::{include_dir, Dir, DirEntry};
use lazy_static::lazy_static;
use std::collections::HashMap;

static MD_FILES_DIR: Dir<'_> = include_dir!("$CARGO_MANIFEST_DIR/src/md_files");

lazy_static! {
    pub static ref MD_FILES: HashMap<String, &'static str> = {
        let mut m = HashMap::new();
        for entry in MD_FILES_DIR.find("**/*.md").unwrap() {
            if let DirEntry::File(file) = entry {
                m.insert(
                    file.path().to_str().unwrap().to_owned(),
                    file.contents_utf8().unwrap(),
                );
            }
        }
        m
    };
}
