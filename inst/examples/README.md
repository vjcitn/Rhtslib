# Rhtslib Examples

This directory contains example files demonstrating how to use Rhtslib in your R package.

## Makevars.example

This file shows two methods for linking your package to Rhtslib:

### Method 1: Using standard pkg-config (Recommended)

This is the recommended method as it follows the standard pkg-config protocol:

```makefile
RHTSLIB_PKGCONFIG_DIR=$(shell "${R_HOME}/bin${R_ARCH_BIN}/Rscript" -e \
    'cat(system.file("lib/pkgconfig", package="Rhtslib"))')

PKG_CPPFLAGS=$(shell PKG_CONFIG_PATH="${RHTSLIB_PKGCONFIG_DIR}" \
    pkg-config --cflags rhtslib)
PKG_LIBS=$(shell PKG_CONFIG_PATH="${RHTSLIB_PKGCONFIG_DIR}" \
    pkg-config --libs rhtslib)
```

### Method 2: Using traditional Rhtslib::pkgconfig()

This method is still supported for backwards compatibility:

```makefile
RHTSLIB_LIBS=$(shell "${R_HOME}/bin${R_ARCH_BIN}/Rscript" -e \
    'Rhtslib::pkgconfig("PKG_LIBS")')
RHTSLIB_CPPFLAGS=$(shell "${R_HOME}/bin${R_ARCH_BIN}/Rscript" -e \
    'Rhtslib::pkgconfig("PKG_CPPFLAGS")')

PKG_LIBS=$(RHTSLIB_LIBS)
PKG_CPPFLAGS=$(RHTSLIB_CPPFLAGS)
```

## Requirements

Both methods require:
- `GNU make` (add to `SystemRequirements` field in DESCRIPTION)
- `Rhtslib` in the `LinkingTo` field of DESCRIPTION

## Testing pkg-config from command line

You can test the pkg-config support from the command line:

```bash
# Get the pkg-config directory
PKGCONFIG_DIR=$(Rscript -e 'cat(system.file("lib/pkgconfig", package="Rhtslib"))')

# Test cflags
PKG_CONFIG_PATH="$PKGCONFIG_DIR" pkg-config --cflags rhtslib

# Test libs
PKG_CONFIG_PATH="$PKGCONFIG_DIR" pkg-config --libs rhtslib

# Get version
PKG_CONFIG_PATH="$PKGCONFIG_DIR" pkg-config --modversion rhtslib
```

## Platform Support

The pkg-config support works on:
- Linux (all distributions)
- macOS
- Windows (with Rtools)
