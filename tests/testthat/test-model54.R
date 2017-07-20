library(testthat)
library(nlmixr)

context("NLME54: two-compartment infusion Michaelis-Menten, single-dose")

if (identical(Sys.getenv("NLMIXR_VALIDATION_FULL"), "true")) {
  
  test_that("ODE", {

    datr <-
      read.csv("Infusion_2CPTMM.csv",
               header = TRUE,
               stringsAsFactors = F)
    datr$EVID <- ifelse(datr$EVID == 1, 10101, datr$EVID)

    datr <- datr[datr$EVID != 2,]
    datIV <- datr[datr$AMT > 0,]
    datIV$TIME <- datIV$TIME + (datIV$AMT/datIV$RATE)
    datIV$AMT <- -1*datIV$AMT
    datr <- rbind(datr, datIV)
    datr <- datr[order(datr$ID, datr$TIME),]
    
    runno <- "N054"
    
    dat <- datr[datr$SD == 1,]
    
    ode2MM <- "
    d/dt(centr)  = K21*periph-K12*centr-(VM*centr/V)/(KM+centr/V);
    d/dt(periph) =-K21*periph+K12*centr;
    "
    
    mypar7 <- function(lVM, lKM, lV, lCLD, lVT)
    {
      VM <- exp(lVM)
      KM <- exp(lKM)
      V <- exp(lV)
      CLD  <- exp(lCLD)
      VT <- exp(lVT)
      K12 <- CLD / V
      K21 <- CLD / VT
    }
    specs7 <-
      list(
        fixed = lVM + lKM + lV + lCLD + lVT ~ 1,
        random = pdDiag(lVM + lKM + lV + lCLD + lVT ~ 1),
        start = c(
          lVM = 7,
          lKM = 6,
          lV = 4,
          lCLD = 1.5,
          lVT = 4
        )
      )
    
    runno <- "N054"
    
    fit <-
      nlme_ode(
        dat,
        model = ode2MM,
        par_model = specs7,
        par_trans = mypar7,
        response = "centr",
        response.scaler = "V",
        verbose = TRUE,
        weight = varPower(fixed = c(1)),
        control = nlmeControl(pnlsTol = .1, msVerbose = TRUE)
      )
    
    z <- VarCorr(fit)
    
    expect_equal(signif(as.numeric(fit$logLik), 6),-12618)
    expect_equal(signif(AIC(fit), 6), 25258.1)
    expect_equal(signif(BIC(fit), 6), 25321.1)
    
    expect_equal(signif(as.numeric(fit$coefficients$fixed[1]), 3), 6.91)
    expect_equal(signif(as.numeric(fit$coefficients$fixed[2]), 3), 5.41)
    expect_equal(signif(as.numeric(fit$coefficients$fixed[3]), 3), 4.25)
    expect_equal(signif(as.numeric(fit$coefficients$fixed[4]), 3), 1.4)
    expect_equal(signif(as.numeric(fit$coefficients$fixed[5]), 3), 3.89)
    
    expect_equal(signif(as.numeric(z[1, "StdDev"]), 3), 0.37)
    expect_equal(signif(as.numeric(z[2, "StdDev"]), 3), 6.6e-20)
    expect_equal(signif(as.numeric(z[3, "StdDev"]), 3), 0.294)
    expect_equal(signif(as.numeric(z[4, "StdDev"]), 3), 0.258)
    expect_equal(signif(as.numeric(z[5, "StdDev"]), 3), 0.280)
    
    expect_equal(signif(fit$sigma, 3), 0.202)
  })
  
}