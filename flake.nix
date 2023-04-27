{
  outputs = { self }: {
  templates.rust-cli = {
    path = ./templates/rust-cli;
    description = "A rust CLI app";
  };
};
}
