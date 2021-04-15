get_rsquared <- function(m){
  cat("R-Squared, Proportion of Variance Explained = ",
      scales::percent((1 - (summary(m)$deviance/summary(m)$null.deviance)),accuracy = .01)
      , "\n")
}
get_model_fit <- function(m){
  cat("MODEL FIT",
      "\nChi-Square = ", with(m, null.deviance - deviance),
      "\ndf = ", with(m, df.null - df.residual),
      "\np-value = ", with(m, pchisq(null.deviance - deviance, df.null - df.residual, lower.tail = FALSE)),"\n"
  )
}
