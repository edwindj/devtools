# @param arg a vector of command arguments.
# @param env a named character vector.  Will be quoted
system_check <- function(cmd, args = character(), env = character()) {
  old_env <- Sys.getenv(names(env), names = TRUE)
  do.call(Sys.setenv, as.list(env))
  on.exit(do.call(Sys.setenv, as.list(old_env)))

  res <- system2(cmd, args = args)
  if (res != 0) {
    stop("Command failed (", res, ")", call. = FALSE)
  }    
  
  invisible(TRUE)
}

R <- function(options, path = tempdir()) {
  r_path <- file.path(R.home("bin"), "R")
  
  env <- c(
    "R_ENVIRON_USER" = tempfile(),
    "LC_ALL" = "C", 
    "R_LIBS" = paste(.libPaths(), collapse = .Platform$path.sep))
   
  in_dir(path, system_check(r_path, options, env))
}

# Internal override of system.file to ensure that code in the package depending on system.file works 
system.file <- function(..., pkg=NULL, package = "base", lib.loc = NULL, mustWork = FALSE){
  pkg <- as.package(pkg)
  if (package == pkg$package){
    file.path(normalizePath(pkg$path, winslash="/"), "inst", ...)
  } else {
    base::system.file(..., package=package, lib.loc=lib.loc, mustWork=mustWork)
  }
}
