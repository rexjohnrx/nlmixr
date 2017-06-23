library(testthat)
library(nlmixr)
library(data.table)

context("NLME: two-compartment infusion, multiple-dose")

if (identical(Sys.getenv("NLMIXR_VALIDATION_FULL"), "true")) {
  
  test_that("Closed-form", {
    
    datr <-
      read.csv("INFUSION_2CPT.csv",
               header = TRUE,
               stringsAsFactors = F)
    datr$EVID <- ifelse(datr$EVID == 1, 10101, datr$EVID)
    datr <- data.table(datr)
    datr <- datr[EVID != 2]
    datIV <- datr[AMT > 0][, TIME := TIME + AMT / RATE][, AMT := -1 * AMT]
    datr <- rbind(datr, datIV)
    setkey(datr, ID, TIME)
    
    specs6 <-
      list(
        fixed = lCL + lV + lCLD + lVT ~ 1,
        random = pdDiag(lCL + lV + lCLD + lVT ~ 1),
        start = c(
          lCL = 1.36,
          lV = 4.2,
          lCLD = 1.47,
          lVT = 3.9
        )
      )
    
    runno <- "N047"
    
    dat <- datr[SD == 0]
    
    fit <-
      nlme_lin_cmpt(
        dat,
        par_model = specs6,
        ncmt = 2,
        verbose = TRUE,
        oral = FALSE,
        infusion = TRUE,
        weight = varPower(fixed = c(1)),
        control = nlmeControl(
          pnlsTol = .1,
          msVerbose = TRUE,
          maxIter = 200
        )
      )
    
    z <- VarCorr(fit)
    
    expect_equal(signif(as.numeric(fit$logLik),6), -27292.5)
    expect_equal(signif(AIC(fit), 6), 54603.1)
    expect_equal(signif(BIC(fit), 6), 54661.2)  
    
    expect_equal(signif(as.numeric(fit$coefficients$fixed[1]),3), 1.35)
    expect_equal(signif(as.numeric(fit$coefficients$fixed[2]),3), 4.21)
    expect_equal(signif(as.numeric(fit$coefficients$fixed[3]),3), 1.42)
    expect_equal(signif(as.numeric(fit$coefficients$fixed[4]),3), 3.85)
    
    expect_equal(signif(as.numeric(z[1, "StdDev"]), 3), 0.298)
    expect_equal(signif(as.numeric(z[2, "StdDev"]), 3), 0.295)
    expect_equal(signif(as.numeric(z[3, "StdDev"]), 3), 0.345)
    expect_equal(signif(as.numeric(z[4, "StdDev"]), 3), 0.317)
    
    expect_equal(signif(fit$sigma, 3), 0.207)
  })
  
  test_that("ODE", {
    
    datr <-
      read.csv("INFUSION_2CPT.csv",
               header = TRUE,
               stringsAsFactors = F)
    datr$EVID <- ifelse(datr$EVID == 1, 10101, datr$EVID)
    datr <- data.table(datr)
    datr <- datr[EVID != 2]
    datIV <-
      datr[AMT > 0][, TIME := TIME + AMT / RATE][, AMT := -1 * AMT]
    datr <- rbind(datr, datIV)
    setkey(datr, ID, TIME)
    
    ode2 <- "
    d/dt(centr)  = K21*periph-K12*centr-K10*centr;
    d/dt(periph) =-K21*periph+K12*centr;
    "
    
    specs6 <-
      list(
        fixed = lCL + lV + lCLD + lVT ~ 1,
        random = pdDiag(lCL + lV + lCLD + lVT ~ 1),
        start = c(
          lCL = 1.6,
          lV = 4.5,
          lCLD = 1.5,
          lVT = 3.9
        )
      )
    
    mypar6 <- function(lCL, lV, lCLD, lVT)
    {
      CL <- exp(lCL)
      V  <- exp(lV)
      CLD <- exp(lCLD)
      VT <- exp(lVT)
      K10 <- CL / V
      K12 <- CLD / V
      K21 <- CLD / VT
    }
    
    
    runno <- "N047"
    
    dat <- datr[SD == 0]
    
    fitODE <-
      nlme_ode(
        dat,
        model = ode2,
        par_model = specs6,
        par_trans = mypar6,
        response = "centr",
        response.scaler = "V",
        verbose = TRUE,
        weight = varPower(fixed = c(1)),
        control = nlmeControl(pnlsTol = .1, msVerbose = TRUE)
      )
    
    z <- VarCorr(fitODE)
    
    expect_equal(signif(as.numeric(fitODE$logLik),6), -27290.6)
    expect_equal(signif(AIC(fitODE), 6), 54599.2)
    expect_equal(signif(BIC(fitODE), 6), 54657.2)  
    
    expect_equal(signif(as.numeric(fitODE$coefficients$fixed[1]),3), 1.35)
    expect_equal(signif(as.numeric(fitODE$coefficients$fixed[2]),3), 4.21)
    expect_equal(signif(as.numeric(fitODE$coefficients$fixed[3]),3), 1.43)
    expect_equal(signif(as.numeric(fitODE$coefficients$fixed[4]),3), 3.86)
    
    expect_equal(signif(as.numeric(z[1, "StdDev"]), 3), 0.298)
    expect_equal(signif(as.numeric(z[2, "StdDev"]), 3), 0.295)
    expect_equal(signif(as.numeric(z[3, "StdDev"]), 3), 0.333)
    expect_equal(signif(as.numeric(z[4, "StdDev"]), 3), 0.315)
    
    expect_equal(signif(fitODE$sigma, 3), 0.207)
  })
  
}