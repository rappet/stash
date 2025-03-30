use leptos::prelude::*;
use markdown::{to_mdast, ParseOptions};
use markdown::mdast::Node;

#[component]
pub fn MdContainer(markdown: String) -> impl IntoView {
    match to_mdast(&markdown, &ParseOptions::default()) {
        Ok(mdast) => {
            view!{ <MdAst mdast={mdast} /> }.into_any()
        },
        Err(err) => view!{ <p>{ format!("{:?}", err) }</p> }.into_any(),
    }
}

#[component]
pub fn MdAst(mdast: Node) -> impl IntoView {
    match mdast {
        Node::Root(root) => root.children.into_iter().map(|ast| view!{ <MdAst mdast={ast} /> }).collect::<Vec<_>>().into_any(),
        Node::Text(text) => view!{ {text.value} }.into_any(),
        Node::Heading(heading) => match heading.depth {
            1 => view!{ <h1><MdAsts asts={heading.children} /></h1> }.into_any(),
            2 => view!{ <h2><MdAsts asts={heading.children} /></h2> }.into_any(),
            3 => view!{ <h3><MdAsts asts={heading.children} /></h3> }.into_any(),
            4 => view!{ <h4><MdAsts asts={heading.children} /></h4> }.into_any(),
            5 => view!{ <h5><MdAsts asts={heading.children} /></h5> }.into_any(),
            6 => view!{ <h6><MdAsts asts={heading.children} /></h6> }.into_any(),
            _ => view!{ <p>{"Unsupported heading"}</p> }.into_any(),
        }
        Node::Emphasis(em) => view!{ <em><MdAsts asts={em.children} /></em> }.into_any(),
        Node::Strong(strong) => view!{ <b><MdAsts asts={strong.children} /></b> }.into_any(),
        Node::Paragraph(paragraph) => view!{ <p><MdAsts asts={paragraph.children} /></p> }.into_any(),
        Node::Break(_) => view!{<br/>}.into_any(),
        Node::Blockquote(quote) => view!{<blockquote><MdAsts asts={quote.children}/></blockquote>}.into_any(),
        Node::Link(link) => view!{<a href={link.url} rel="noopener"><MdAsts asts={link.children}/></a>}.into_any(),
        _ => view!{<p>{format!("other: {:?}", mdast)}</p>}.into_any()
    }
}

#[component]
pub fn MdAsts(asts: Vec<Node>) -> impl IntoView {
    let components: Vec<_> = asts.into_iter().map(|ast| view!{ <MdAst mdast={ast}  /> }).collect();
    components
}