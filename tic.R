# installs dependencies, runs R CMD check, runs covr::codecov()
do_package_checks(error_on="never", repos=c(CRAN=unname(repo_default()), remotes::bioc_install_repos(bioc_ver="3.13")))

if (ci_on_ghactions() && ci_has_env("BUILD_PKGDOWN")) {
  # creates pkgdown site and pushes to gh-pages branch
  # only for the runner with the "BUILD_PKGDOWN" env var set
  do_pkgdown()
}
