.PHONY: ffi header xcode build clean

# Build Rust FFI static library
ffi:
	cd worklog-ffi && cargo build --release

# Generate C header (happens automatically during cargo build via build.rs)
header: ffi

# Generate Xcode project from project.yml
xcode: header
	xcodegen generate

# Build the macOS app via xcodebuild
build: xcode
	xcodebuild -project WorklogMenubar.xcodeproj -scheme WorklogMenubar -configuration Release build

clean:
	cd worklog-ffi && cargo clean
	rm -rf DerivedData build
