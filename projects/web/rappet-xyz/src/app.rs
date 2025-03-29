use leptos::prelude::*;
use leptos_meta::{provide_meta_context, MetaTags, Stylesheet, Title};
use leptos_router::{
    components::{Route, Router, Routes, A},
    StaticSegment,
};

pub fn shell(options: LeptosOptions) -> impl IntoView {
    view! {
        <!DOCTYPE html>
        <html lang="en">
            <head>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1"/>
                <meta name="fediverse:creator" content="@rappet@chaos.social"/>
                <link rel="me" href="https://chaos.social/@rappet">Mastodon</link>
                <AutoReload options=options.clone() />
                <HydrationScripts options={options.clone()} islands=false/>
                <HashedStylesheet options id="leptos" />
                <MetaTags/>
            </head>
            <body>
                <App/>
            </body>
        </html>
    }
}

#[component]
pub fn App() -> impl IntoView {
    // Provides context that manages stylesheets, titles, meta tags, etc.
    provide_meta_context();

    view! {
        // sets the document title
        <Title text="rappet's blog and tools"/>

        // content for this welcome page
        <Router>
            <Routes fallback=|| view!{<Shell>"Page not found."</Shell>}>
                <Route path=StaticSegment("") view=HomePage/>
                <Route path=StaticSegment("/about") view=AboutPage/>
            </Routes>
        </Router>
    }
}

/// Renders the home page of your application.
#[component]
fn HomePage() -> impl IntoView {
    view! {
        <Shell>
            <article>
                <h1>"rappet's blog and tools"</h1>
                <p>"I'm working on it. Nothing interresting here..."</p>
            </article>
        </Shell>
    }
}

/// Renders the home page of your application.
#[component]
fn AboutPage() -> impl IntoView {
    view! {
        <Shell>
            <article>
                <h1>"About"</h1>
                <p>"This is build by rappet."</p>
                <p>"Contact me under blog@rappet.de"</p>
                <p>"Currently, this page is non-commercial and I don't collect personal information."</p>
            </article>
        </Shell>
    }
}

#[component]
fn Shell(children: Children) -> impl IntoView {
    view! {
        <Header/>
        <main>
            {children()}
        </main>
        <Footer/>
    }
}

#[component]
fn Header() -> impl IntoView {
    view! {
        <header>
            <ul>
                <li><A href="/">Home</A></li>
                <li><A href="/about">About</A></li>
            </ul>
        </header>
    }
}

#[component]
fn Footer() -> impl IntoView {
    view! {
        <footer>"rappet 2024 - self written with Leptos"</footer>
    }
}
