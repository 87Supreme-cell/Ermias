//! SHA-256 file hashing for the model integrity check (02_header_status).

use sha2::{Digest, Sha256};
use std::fs::File;
use std::io::{ErrorKind, Read};

/// Model files are several GB; hash them in fixed-size chunks.
const READ_BUFFER_BYTES: usize = 64 * 1024;
const SHA256_HEX_LEN: usize = 64;

/// Returns the lowercase hex SHA-256 of the file at `path`.
pub fn sha256_file(path: String) -> Result<String, String> {
    let mut file = File::open(&path).map_err(|e| format!("cannot open {path}: {e}"))?;
    let mut hasher = Sha256::new();
    let mut buffer = vec![0u8; READ_BUFFER_BYTES];
    loop {
        match file.read(&mut buffer) {
            Ok(0) => break,
            Ok(n) => hasher.update(&buffer[..n]),
            Err(e) if e.kind() == ErrorKind::Interrupted => continue,
            Err(e) => return Err(format!("cannot read {path}: {e}")),
        }
    }
    Ok(to_hex(&hasher.finalize()))
}

/// True when the file's SHA-256 equals `expected_hex` (case-insensitive).
/// A missing or unreadable file, or a malformed expected hash, is an error,
/// never a pass.
pub fn verify_pinned(path: String, expected_hex: String) -> Result<bool, String> {
    let expected = expected_hex.trim().to_ascii_lowercase();
    let is_hex = expected.len() == SHA256_HEX_LEN && expected.bytes().all(|b| b.is_ascii_hexdigit());
    if !is_hex {
        return Err(format!("pinned hash is not a 64-character hex SHA-256: {expected_hex}"));
    }
    Ok(sha256_file(path)? == expected)
}

fn to_hex(bytes: &[u8]) -> String {
    bytes.iter().map(|b| format!("{b:02x}")).collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;

    fn test_file(name: &str, bytes: &[u8]) -> String {
        let dir: PathBuf = std::env::temp_dir().join(format!("ermias_core_{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let path = dir.join(name);
        std::fs::write(&path, bytes).unwrap();
        path.display().to_string()
    }

    fn sha256_reference(bytes: &[u8]) -> String {
        to_hex(&Sha256::digest(bytes))
    }

    #[test]
    fn sha256_of_known_bytes() {
        let p = test_file("abc.bin", b"abc");
        assert_eq!(
            sha256_file(p).unwrap(),
            "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
        );
    }

    #[test]
    fn hashes_files_larger_than_the_read_buffer() {
        // 200 kB spans several 64 KiB reads, including a partial last one.
        let data = vec![b'a'; 200_000];
        let p = test_file("big.bin", &data);
        assert_eq!(sha256_file(p).unwrap(), sha256_reference(&data));
    }

    #[test]
    fn pinned_hash_matches_regardless_of_case() {
        let p = test_file("model_ok.bin", b"abc");
        let pinned = "BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD";
        assert_eq!(verify_pinned(p, pinned.into()), Ok(true));
    }

    #[test]
    fn changed_file_fails_pinned_check() {
        let p = test_file("model_changed.bin", b"abc");
        let pinned = sha256_file(p.clone()).unwrap();
        std::fs::write(&p, b"abd").unwrap();
        assert_eq!(verify_pinned(p, pinned), Ok(false));
    }

    #[test]
    fn missing_file_is_an_error_not_a_pass() {
        let pinned = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad";
        assert!(verify_pinned("/no/such/ermias/file".into(), pinned.into()).is_err());
    }

    #[test]
    fn malformed_pinned_hash_is_an_error() {
        let p = test_file("model_bad_pin.bin", b"abc");
        assert!(verify_pinned(p, "not-a-hash".into()).is_err());
    }
}
