.PHONY: ffi header xcode build clean update-core lint lint-rust lint-swift

# Build Rust FFI static library
ffi:
	cd devcap-ffi && cargo build --release

# Generate C header (happens automatically during cargo build via build.rs)
header: ffi

# Generate Xcode project from project.yml
xcode: header
	xcodegen generate

# Build the macOS app via xcodebuild
build: xcode
	xcodebuild -project DevcapApp.xcodeproj -scheme DevcapApp -configuration Release build

# Update devcap-core to latest upstream version, rebuild FFI + header
update-core:
	cd devcap-ffi && cargo update -p devcap-core
	@echo "Updated devcap-core to:"
	@cd devcap-ffi && cargo tree -p devcap-core --depth 0
	$(MAKE) ffi

# Lint all code (Rust + Swift)
lint: lint-rust lint-swift

# Rust: format check + clippy
lint-rust:
	cd devcap-ffi && cargo fmt --check
	cd devcap-ffi && cargo clippy -- -D warnings

# Swift: SwiftLint (auto-detect Xcode for SourceKit)
lint-swift:
	@if [ -z "$$DEVELOPER_DIR" ] && [ -d /Applications/Xcode.app ]; then \
		DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swiftlint lint --strict; \
	else \
		swiftlint lint --strict; \
	fi

clean:
	cd devcap-ffi && cargo clean
	rm -rf DerivedData build
