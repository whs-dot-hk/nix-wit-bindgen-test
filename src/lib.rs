wit_bindgen::generate!({path:"wit/host.wit",exports:{world: MyHost},});

struct MyHost;

impl Host for MyHost {
    fn run() {
        print!("Hello, world!");
    }
}
