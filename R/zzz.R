pkgconfig <- function(opt=c("PKG_LIBS", "PKG_CPPFLAGS"))
{
    opt <- match.arg(opt)
    if (opt == "PKG_LIBS") {
        usrlib_dir <- Sys.getenv(
            "RHTSLIB_RPATH",
            system.file("usrlib", package="Rhtslib", mustWork=TRUE)
        )
        platform <- Sys.info()[["sysname"]]
        if (platform == "Windows") {
            r_arch <- .Platform[["r_arch"]]
            usrlib_dir <- file.path(usrlib_dir, r_arch)
        }
        usrlib_path <- sprintf("'%s'", file.path(usrlib_dir, "libhts.a"))
        if (platform == "Windows") {
            ## See how PKG_LIBS is defined in Rhtslib/src/Makevars.win
            ## and make sure to produce the same value here.
            libs <- c("m", "bz2", "lzma", "curl")
            R_TOOLS_SOFT <- tools::Rcmd("config R_TOOLS_SOFT", stdout=TRUE)
            syslibs <- paste0(R_TOOLS_SOFT, "/lib/")
            if (dir.exists(syslibs)) {
                if (file.exists(paste0(syslibs, "libnghttp2.a")))
                    libs <- append(libs, "nghttp2")
                if (file.exists(paste0(syslibs, "libpsl.a")))
                    libs <- append(libs, "psl")
                if (file.exists(paste0(syslibs, "libbrotlidec.a")))
                    libs <- append(libs, c("brotlidec", "brotlicommon"))
            }
            libs <- append(libs, c("secur32", "bcrypt", "idn2", "unistring",
                           "iconv", "ssl", "crypto", "z", "crypt32", "wsock32",
                           "wldap32", "ssh2", "gcrypt", "gpg-error", "ws2_32",
                           "zstd", "regex"))
            libs <- paste(sprintf("-l%s", libs), collapse=" ")
        } else {
            ## See how PKG_LIBS is defined in Rhtslib/src/Makevars
            ## and make sure to produce the same value here.
            libs <- "-lcurl -lbz2 -llzma -lz"
        }
        config <- paste(usrlib_path, libs)
    } else {
        ## See how PKG_CPPFLAGS is defined in Rhtslib/src/Makevars.common
        ## and make sure to produce the same value here.
        config <- "-D_FILE_OFFSET_BITS=64"
        ## Packages that link to Rhtslib should have Rhtslib in their
        ## LinkingTo field so the preprocessor option below will automatically
        ## be added. There is no need to add it again here.
        #include_dir <- system.file("include", package="Rhtslib")
        #config <- paste(config, sprintf("-I'%s'", include_dir))
    }
    cat(config)
}

htsVersion <- function()
{
    vers <- .Call("Rhtslib_htslib_version", PACKAGE="Rhtslib")
    message(vers)
}

.onAttach <- function(...)
{
    vers <- .Call("Rhtslib_htslib_version", PACKAGE="Rhtslib")
    packageStartupMessage("Rhtslib htslib version ", vers)
}

.onLoad <- function(libname, pkgname)
{
    ## Update the pkg-config file with the correct architecture-specific paths
    ## This ensures the pkg-config file works correctly on all platforms
    update_pkgconfig_file()
}

#' @keywords internal
update_pkgconfig_file <- function()
{
    ## Get the package installation directory
    pkg_dir <- system.file(package="Rhtslib")
    if (pkg_dir == "") return(invisible(NULL))
    
    ## Get the pkg-config file path
    pc_file <- file.path(pkg_dir, "lib", "pkgconfig", "rhtslib.pc")
    if (!file.exists(pc_file)) return(invisible(NULL))
    
    ## Determine the correct usrlib directory
    platform <- Sys.info()[["sysname"]]
    if (platform == "Windows") {
        r_arch <- .Platform[["r_arch"]]
        usrlib_subdir <- file.path("usrlib", r_arch)
    } else {
        usrlib_subdir <- "usrlib"
    }
    
    ## Read the template
    pc_content <- readLines(pc_file)
    
    ## Update the libdir line to include the architecture-specific path
    libdir_pattern <- "^libdir=.*"
    libdir_idx <- grep(libdir_pattern, pc_content)
    if (length(libdir_idx) > 0) {
        pc_content[libdir_idx] <- sprintf("libdir=${prefix}/%s", usrlib_subdir)
        
        ## Write the updated content back
        tryCatch({
            writeLines(pc_content, pc_file)
        }, error=function(e) {
            ## If we can't write (e.g., permissions issue), just continue silently
            invisible(NULL)
        })
    }
    
    invisible(NULL)
}

