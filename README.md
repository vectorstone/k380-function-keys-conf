# k380-function-keys-conf
MacOS app to make function keys default on Logitech k380 bluetooth keyboard

## Instalation

1. Install `hidapi` library
```shell
brew install hidapi
```
2. Build this app
```
# suitable for intel chip mac
./build_Intel.sh

# suitable for apple silicon mac
./build_Apple_Silicon.sh
```
3. Run it as root (Note that you might be asked to give permissions for terminal app to access input device)
```
sudo ./k380 -f on
```

## Troubleshooting

`k380` links against the Homebrew `hidapi` **dylib** at runtime, so `hidapi` must
stay installed after building. Homebrew does not know this hand-built binary
depends on it, so `brew autoremove` / cleanup may remove it as an orphan.

If running `k380` aborts with:

```
dyld[...]: Library not loaded: /opt/homebrew/opt/hidapi/lib/libhidapi.0.dylib
  Referenced from: .../k380
  Reason: tried: '/opt/homebrew/opt/hidapi/lib/libhidapi.0.dylib' (no such file)
```

just reinstall it:

```shell
brew install hidapi
```

To prevent it from being removed again, either pin it (`brew pin hidapi`) or make
the binary self-contained by copying the dylib next to it and rewriting the load
path with `install_name_tool`. See [AGENTS.md](./AGENTS.md) for the full details.

## Based on
https://github.com/jergusg/k380-function-keys-conf
