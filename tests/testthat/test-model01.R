library(testthat)
library(nlmixr)

context("NLME01: one-compartment bolus, single-dose")

if (identical(Sys.getenv("NLMIXR_VALIDATION_FULL"), "true")) {
  test_that("Closed-form", {
    datr <- read.csv("Bolus_1CPT.csv",
                     header = TRUE,
                     stringsAsFactors = F)
    datr$EVID <- ifelse(datr$EVID == 1, 101, datr$EVID)
    datr <- datr[datr$EVID != 2, ]
    
    specs1 <-
      list(
        fixed = lCL + lV ~ 1,
        random = pdDiag(lCL + lV ~ 1),
        start = c(lCL = 1.6, lV = 4.5)
      )
    
    runno <- "N001"
    
    dat <- datr[datr$SD == 1, ]
    
    fit <-
      nlme_lin_cmpt(
        dat,
        par_model = specs1,
        ncmt = 1,
        verbose = TRUE,
        oral = FALSE,
        weight = varPower(fixed = c(1))
      )
    
    z <- summary(fit)
    
    expect_equal(signif(as.numeric(fit$logLik), 6),-12119.4)
    expect_equal(signif(AIC(fit), 6), 24248.8)
    expect_equal(signif(BIC(fit), 6), 24277.4)
    
    expect_equal(signif(as.numeric(fit$coefficients$fixed[1]), 3), 1.36)
    expect_equal(signif(as.numeric(fit$coefficients$fixed[2]), 3), 4.20)
    
    expect_equal(as.numeric(signif(exp(attr(z$apVar, "Pars"))[1], 3)), 0.267)
    expect_equal(as.numeric(signif(exp(attr(z$apVar, "Pars"))[2], 3)), 0.303)
    expect_equal(as.numeric(signif(exp(attr(z$apVar, "Pars"))[3], 3)), 0.199)
    
  })
  
  test_that("ODE", {
    datr <- read.csv("Bolus_1CPT.csv",
                     header = TRUE,
                     stringsAsFactors = F)
    datr$EVID <- ifelse(datr$EVID == 1, 101, datr$EVID)
    datr <- datr[datr$EVID != 2, ]
    
    specs1 <-
      list(
        fixed = lCL + lV ~ 1,
        random = pdDiag(lCL + lV ~ 1),
        start = c(lCL = 1.6, lV = 4.5)
      )
    
    runno <- "N001"
    
    dat <- datr[datr$SD == 1, ]
    
    ode1 <- "
    d/dt(centr)  = -(CL/V)*centr;
    "
    
    mypar1 <- function(lCL, lV)
    {
      CL <- exp(lCL)
      V <- exp(lV)
    }
    
    fitODE <-
      nlme_ode(
        dat,
        model = ode1,
        par_model = specs1,
        par_trans = mypar1,
        response = "centr",
        response.scaler = "V",
        verbose = TRUE,
        weight = varPower(fixed = c(1)),
        control = nlmeControl(pnlsTol = .01, msVerbose = TRUE)
      )
    
    z <- summary(fitODE)
    
    expect_equal(signif(as.numeric(fitODE$logLik), 6),-12119.4)
    expect_equal(signif(AIC(fitODE), 6), 24248.7)
    expect_equal(signif(BIC(fitODE), 6), 24277.4)  
    
    expect_equal(signif(as.numeric(fitODE$coefficients$fixed[1]), 3), 1.36)
    expect_equal(signif(as.numeric(fitODE$coefficients$fixed[2]), 3), 4.20)
    
    expect_equal(as.numeric(signif(exp(attr(z$apVar, "Pars"))[1], 3)), 0.267)
    expect_equal(as.numeric(signif(exp(attr(z$apVar, "Pars"))[2], 3)), 0.303)
    expect_equal(as.numeric(signif(exp(attr(z$apVar, "Pars"))[3], 3)), 0.199)
    
  })

}