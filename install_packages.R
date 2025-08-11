# One-shot dependency installer
pkgs <- c(
  "readxl","dplyr","tidyr","lubridate","stringr","janitor",
  "tsibble","feasts","ggplot2","forecast",
  "randomForest","xgboost","e1071","vars","writexl",
  "torch","coro","tibble","readr"
)
new <- pkgs[!(pkgs %in% installed.packages()[,"Package"])]
if (length(new)) install.packages(new, repos = "https://cloud.r-project.org")
message("If using torch for the deep models, run once in R: torch::install_torch()")
