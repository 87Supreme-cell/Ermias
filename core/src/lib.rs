//! Ermias core. Everything that touches the operating system lives here,
//! behind small functions the Flutter app calls through flutter_rust_bridge.
//! No function in this crate opens a network connection.

pub mod api;
mod frb_generated;
