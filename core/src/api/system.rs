//! Live memory and CPU readings for the header resource strip.

use std::sync::{Mutex, OnceLock};
use sysinfo::System;

pub struct MemorySnapshot {
    pub used_bytes: u64,
    pub total_bytes: u64,
}

/// One shared `System`: CPU usage is measured between two refreshes, so the
/// previous sample must be kept. Creating it can fail on an unsupported OS;
/// that failure is kept and reported on every call, never hidden.
fn system() -> Result<&'static Mutex<System>, String> {
    static SYSTEM: OnceLock<Result<Mutex<System>, String>> = OnceLock::new();
    SYSTEM
        .get_or_init(|| System::new().map(Mutex::new).map_err(|e| format!("system info unavailable: {e}")))
        .as_ref()
        .map_err(Clone::clone)
}

fn with_system<T>(read: impl FnOnce(&mut System) -> T) -> Result<T, String> {
    // A panic while holding the lock leaves readable data; recover it rather
    // than failing every later reading.
    let mut guard = system()?.lock().unwrap_or_else(|poisoned| poisoned.into_inner());
    Ok(read(&mut guard))
}

pub fn memory_snapshot() -> Result<MemorySnapshot, String> {
    with_system(|sys| {
        sys.refresh_memory();
        MemorySnapshot { used_bytes: sys.used_memory(), total_bytes: sys.total_memory() }
    })
}

/// Global CPU usage in percent (0–100) since the previous call.
pub fn cpu_percent() -> Result<f32, String> {
    with_system(|sys| {
        sys.refresh_cpu_usage();
        sys.global_cpu_usage().clamp(0.0, 100.0)
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn memory_snapshot_is_sane() {
        let m = memory_snapshot().unwrap();
        assert!(m.total_bytes > 0);
        assert!(m.used_bytes <= m.total_bytes);
    }

    #[test]
    fn cpu_percent_is_in_range() {
        cpu_percent().unwrap();
        std::thread::sleep(sysinfo::MINIMUM_CPU_UPDATE_INTERVAL);
        let p = cpu_percent().unwrap();
        assert!((0.0..=100.0).contains(&p), "{p}");
    }
}
