# Using HTMX with Rust - A Quickstart Guide

1704478712
## Introduction

If you've been following web development, you've probably seen the hype about [htmx](https://htmx.org/). In simple terms, it's a front-end web development framework in which the goal is to minimize the amount of javascript that gets shipped to the browser. The philosophy behind it seeks to return to the golden age of hypermedia-driven applications, which means that rather than receiving JSON data from the server, you receive whole html blocks that get swapped into your application with lightening speed. 

This tutorial is a simple quickstart guide for building your first htmx application using Rust. Specifically, we'll be using the [actix-web server framework](https://actix.rs/docs/) for serving our requests, as well as the [Tera templating engine](https://keats.github.io/tera/docs/) to render the actual html. Follow along, or clone the repository [here](). 

In order to follow along, you'll only need to install [Rust](https://www.rust-lang.org/tools/install). Optionally, you can make use of my favorite css framework, [tailwindcss](https://tailwindcss.com/docs/installation). You'll need to install [Nodejs](https://nodejs.org/en/download) to add tailwind to your application. Let's get started!

## Getting Started

To get started, initialize a new cargo project in the command-line terminal of your choice.

```
cargo new actix_htmx
```

This will create a directory called `actix_htmx`. It should look like this:

```
actix_htmx
+-- src
|   +-- main.rs
+-- Cargo.toml
```

To add the required Rust dependencies, we'll change directory to `actix_htmx`, and use `cargo add` to include them in our Cargo.toml:

```
cd actix_htmx
cargo add actix actix-web actix-files env_logger log tera
```

This will add the required dependencies for the actix-web server framework, logging utilities, and the tera templating engine.

Next, let's set up the `/templates` directory, which will house our html templates.

```
mkdir templates
touch templates/main.html
```

In the IDE of your choice, add the following boilerplate to your `main.html`.

```
<!DOCTYPE html>

<head>

	<title>actix htmx</title>
	
	<script src="https://unpkg.com/htmx.org@1.9.10" integrity="sha384-D1Kt99CQMDuVetoL1lrYwg5t+9QdHe7NLX/SoJYkXDFfX37iInKRy5xLSi8nO7UC" crossorigin="anonymous"></script>

</head>

<body>

<h1>Hello World</h1>

</body>
```

This will be the entry point for your web application. Finally, we're ready to implement that actix-web server in Rust! 

## A Basic Actix-Web Server

In `src/main.rs`, replace the existing code with this:

```
use actix_web::{get, App, web::Data, HttpResponse, HttpServer, Responder};

use tera::{Tera, Context};


#[get("/")]

async fn home(tera: Data<Tera>) -> impl Responder {

	HttpResponse::Ok().body(tera.render("main.html", &Context::new()).unwrap())

}

  

#[actix::main]

async fn main() -> std::io::Result<()> {

	env_logger::init();
	
	log::debug!("Starting Server");
	
	  
	
	let tera = Data::new(Tera::new("./templates/**/*.html").unwrap());
	
	  
	
	HttpServer::new( move || {
	
			App::new()
			
			.app_data(tera.clone())
			
			.service(home)
		
		})
		
		.bind(("127.0.0.1", 8000))?
		
		.run()
		
		.await
	
	}
```

Let's go through what this is doing. First, we import the required systems from our dependencies. Then we define a function that runs when the / path is hit with a GET request. This function returns an `HttpResponse` of OK (status code 200). In the body of that response is a string that renders the `main.html` template with an empty context. Finally, in the main function, we start an HTTP Server that runs our application. This application passes around the tera rendering so that all of our routes can render html with the `.app_data()` method. With the `.service()`, our application provides access to the `/` route, which stores the `home` function. This server is bound to the IP address 127.0.0.1, and the 8000 port. We can access this server with our browser at `localhost:8000/` when we run the following command.

```
RUST_LOG=debug cargo run
```

You should see a web page with a header tag that reads "Hello World"! That being said, we definitely don't need htmx for this example, so let's add some more functionality.

## Adding Counter Functionality

Let's implement a feature that allows the user to increment and decrement a counter, starting at zero. In our `templates/main.html`, replace the `<body>...</body>` with the following snippet.

```
... rest of templates/main.html ...
<body>
	
	<p id="counter">Counter: {{ counter_value }}</p>
	
	  
	
	<button hx-get="/increment" hx-target="#counter">increment</button>
	
	  
	
	<button hx-get="/decrement" hx-target="#counter">decrement</button>

</body>
```

What's going on here? In our `<p>...</p>` tag, we're using a piece of context that we'll provide in our `home` function of our Rust code. We'll see in a moment how that's implemented. Button immediately below includes our first piece of htmx magic. Rather than using AJAX written in a javascript file, htmx elements can fetch data by themselves! `hx-get` creates a GET request to the corresponding endpoint, here `/increment`. In `hx-target`, we specify where we want the response to go, here replacing our counter `<p>...</p>` element. The button below is essentially the same, but provides functionality to decrement the counter. Now let's implement the fun stuff in Rust.

First, let's add some new dependencies to the very top of the `src/main.rs` file. This will come in handy when dealing with application state. 

```
use std::sync::Mutex
... rest of src/main.rs ...
```

I can't go into detail about what `Mutex` does. (Really, I do not have the ability nor the knowledge to explain all of the wonderful things it does.) Suffice to say, it enables thread-safe mutability of data, which means we can safely change the value across the entire application. 

Next, let's add a struct that will house the state of our application. Below the imports, add the struct.

```
... rest of src/main.rs

struct AppStateCounter {

	counter: Mutex<i32>

}

... rest of src/main.rs ...
```

This is simple enough. Inside of our struct, we define an element that includes our magical `Mutex`, which stores an unsigned 32-bit integer.

Remember our `templates/main.html` has buttons that refer to a `/increment` and `/decrement` endpoint? The `/` route also needs context from tera to display the initial counter value. Let's implement our new route handlers next.

```
... rest of src/main.rs ...
#[get("/")]
async fn home(tera: Data<Tera>, data: Data<AppStateCounter>) -> impl Responder {

	let counter = data.counter.lock().unwrap();

	let mut home_context = Context::new();

	home_context.insert("counter_value", &*counter);

	HttpResponse::Ok().body(tera.render("main.html", &home_context).unwrap())

}


#[get("/increment")]
async fn increment(tera: Data<Tera>, data: Data<AppStateCounter>) -> impl Responder {

	let mut counter = data.counter.lock().unwrap();
	
	*counter += 1;
	
	log::info!("Incremented Counter Value: {}", *counter);
	
	let mut increment_context = Context::new();
	
	increment_context.insert("counter_value", &*counter);
	
	HttpResponse::Ok().body(tera.render("components/counter.html", &increment_context).unwrap())

}

  

#[get("/decrement")]
async fn decrement(tera: Data<Tera>, data: Data<AppStateCounter>) -> impl Responder {

	let mut counter = data.counter.lock().unwrap();
	
	*counter -= 1;
	
	log::info!("Decremented Counter Value: {}", *counter);
	
	let mut decrement_context = Context::new();
	
	decrement_context.insert("counter_value", &*counter);
	
	HttpResponse::Ok().body(tera.render("components/counter.html", &decrement_context).unwrap())

}
... rest of src/main.rs ...

```

These are relatively simple, but let's go through what they accomplish. In the function parameters, we've added a new item that pulls in our `AppStateCounter` for later use. In our `/` route, we pull out the numeric value from this struct. After creating a new Tera `Context`, we insert our counter value, and then pass it into our Tera rendering function in the response body. Our new `/increment` and `/decrement` route handlers are similar, pulling out the counter value and modifying it. 

Finally, we'll add our new Tera template by creating a new `templates/components` directory, and adding a file called `templates/components/counter.html`. This is what it should look like:

```
<p id="counter">Counter: {{ counter_value }}</p>
```

Let's head back to our `src/main.rs` file, since we need to add everything to the application implementation in our `main` function. Replace the main function with the following implementation which incorporates our state into our actix-web application.

```
... rest of src/main.rs ...
#[actix::main]
async fn main() -> std::io::Result<()> {

	env_logger::init();
	
	log::debug!("Starting Server");
	
	  
	let tera = Data::new(Tera::new("./templates/**/*.html").unwrap());
	
	let counter = Data::new(AppStateCounter {
	
		counter: Mutex::new(0)
	
	});
	
	HttpServer::new( move || {
	
		App::new()
		
		.app_data(tera.clone())
		
		.app_data(counter.clone())
		
		.service(home)
		
		.service(increment)
		
		.service(decrement)
	
	})
	
	.bind(("0.0.0.0", 8000))?
	
	.run()
	
	.await

}
```

In this snippet, we added a counter implementation of our AppStateCounter struct, and passed it as application data into our application. We've also added two new routes for `/increment` and `/decrement`.

Finally, when we rerun our Rust application, we should be able to increment and decrement our counter! We've used essential parts of actix-web, htmx, and tera to create this lightweight and performant web application. 

## Optional: Add TailwindCSS

I love tailwindcss because it makes styling a breeze. If you're wondering how to implement tailwind outside of a javascript framework, this section is for you.

 To initialize tailwindcss, use the following command, which requires Nodejs.
 
```
npx tailwindcss init
```

This will create a `tailwind.config.js` file in your project directory. In this file, add our templates to the content. This will make sure that tailwindcss generates the utility classes when we add them into our html templates. Your tailwind.config.js should look like this:

```
/** @type {import('tailwindcss').Config} */

module.exports = {

	content: ["./templates/**/*.html"],
	
	theme: {
	
		extend: {},
	
	},
	
	plugins: [],

}
```

Let's add a new `/static` directory to house or css files. Here, add a file called `/static/main.css`. Add the following directives to load tailwind.

```
@tailwind base;

@tailwind components;

@tailwind utilities;
```

To generate our final css files, use the tailwind command.

```
npx tailwindcss -i ./static/main.css -o ./static/tailwind.css
```

Running this, it will generate `/static/tailwind.css`.

In our `src/main.rs` file, add a new `.service()` under our `.app_data()` initializations. Your `main` function should now look like this:

```
... rest of src/main.rs ...

#[actix::main]

async fn main() -> std::io::Result<()> {

	env_logger::init();
	
	log::debug!("Starting Server");
	
	  
	
	let tera = Data::new(Tera::new("./templates/**/*.html").unwrap());
	
	let counter = Data::new(AppStateCounter {
	
	counter: Mutex::new(0)
	
	});
	
	  
	
	HttpServer::new( move || {
	
		App::new()
		
		.app_data(tera.clone())
		
		.app_data(counter.clone())
		
		.service(actix_files::Files::new("/static", "./static").show_files_listing()) // making /static files accessible to the client
		
		.service(home)
		
		.service(increment)
		
		.service(decrement)
	
	})
	
	.bind(("0.0.0.0", 8000))?
	
	.run()
	
	.await

}
```

Finally, alter your `templates/main.html` to include a link to our `/static/tailwind.css` file.

```
<!DOCTYPE html>

<head>

	<title>actix htmx p5</title>

	<script src="https://unpkg.com/htmx.org@1.9.10" integrity="sha384-D1Kt99CQMDuVetoL1lrYwg5t+9QdHe7NLX/SoJYkXDFfX37iInKRy5xLSi8nO7UC" crossorigin="anonymous"></script>
	
	{# Adding a link to our tailwind.css #}
	<link rel="stylesheet" href="/static/tailwind.css"/>

</head>

<body>

	<h1 class="text-xl">Actix Htmx</h1>
	
	  
	
	<p id="counter">Counter: {{ counter_value }}</p>
	
	  
	
	<button hx-get="/increment" hx-target="#counter">increment</button>
	
	  
	
	<button hx-get="/decrement" hx-target="#counter">decrement</button>

</body>
```

Now when you run the server, the `<h1>...</h1>` element should appear larger!

You will have to rerun the tailwind output command every time you make a change, so I've implemented the following build script in `build.rs`:

```
use std::process::Command;

  

fn main() {

let _ = Command::new("npx")

	.arg("tailwindcss")
	
	.arg("-i")
	
	.arg("./static/main.css")
	
	.arg("-o")
	
	.arg("./static/tailwind.css")
	
	.output();

}
```

Simply put, everything the application is built, I use a process to run the tailwind output command, so I don't have to do it manually. Make sure to reference the build script in your `Cargo.toml` by adding `build = "build.rs"` under the `edition` line in the `[package]` section.

## Conclusion

I've had a lot of fun learning htmx, and paring back my web applications with Rust. I built a whole web user interface around [ollama](https://ollama.ai/)that's hosted publicly [here](https://ai.moonstripe.com) using the stack I've just talked about. Go on and make cool things using web technology as they were intended to be used!