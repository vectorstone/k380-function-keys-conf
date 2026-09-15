# AGENTS.md

## Project

macOS command-line app that makes the function keys default on a Logitech K380
Bluetooth keyboard. It talks to the device through
[hidapi](https://github.com/libusb/hidapi).

## Build

```shell
# Apple Silicon (arm64)
./build_Apple_Silicon.sh

# Intel (x86_64)
./build_Intel.sh
```

Both scripts compile `k380_conf.c` into `k380`.

## Run

```shell
sudo ./k380 -f on    # enable direct F-keys
sudo ./k380 -f off   # disable
```

Root is required to access the HID device.

## Important: hidapi is linked dynamically

Both build scripts link against the Homebrew `hidapi` **dylib**, not a static
library:

- `build_Apple_Silicon.sh` -> `/opt/homebrew/lib/libhidapi.dylib`
- `build_Intel.sh` -> `/usr/local/lib/libhidapi.dylib`

The linker records hidapi's install name (for example
`/opt/homebrew/opt/hidapi/lib/libhidapi.0.dylib`) inside the `k380` binary, so
**`hidapi` must remain installed at runtime**. Confirm the recorded path with:

```shell
otool -L k380
```

If hidapi is missing, running `k380` fails with a dyld abort:

```
dyld[...]: Library not loaded: /opt/homebrew/opt/hidapi/lib/libhidapi.0.dylib
  Referenced from: .../k380
  Reason: tried: '/opt/homebrew/opt/hidapi/lib/libhidapi.0.dylib' (no such file)
```

This usually happens because nothing in Homebrew depends on `hidapi` — the
binary is built by hand, so Homebrew does not track it — and `brew autoremove` /
cleanup treats the library as an orphan and removes it. Fix:

```shell
brew install hidapi
```

To keep it from being removed again, either pin it:

```shell
brew pin hidapi
```

or make the binary self-contained by copying the dylib next to it and rewriting
the load path:

```shell
cp /opt/homebrew/opt/hidapi/lib/libhidapi.0.dylib .
install_name_tool -change /opt/homebrew/opt/hidapi/lib/libhidapi.0.dylib \
  @executable_path/libhidapi.0.dylib k380
```

Note the Homebrew keg ships only `.dylib`, no `.a`, so static linking is not an
option when building against the installed package.

## Based on

https://github.com/jergusg/k380-function-keys-conf
