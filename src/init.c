#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* .C calls */
extern void parse_ode(void *, void *, void *, void *);
extern void parse_pars(void *, void *, void *, void *, void *, void *, void *);

/* Internal C calls, should not be called outside of C code. */
typedef void (*S_fp) (double *, double *);
extern void nelder_fn(S_fp func, int n, double *start, double *step,
	       int itmax, double ftol_rel, double rcoef, double ecoef, double ccoef,
	       int *iconv, int *it, int *nfcall, double *ynewlo, double *xmin,
	       int *iprint);

/* .Call calls */
extern SEXP neldermead_wrap(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
/* extern SEXP n1qn1_wrap(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP); */
extern SEXP nlmixr_lin_cmt(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _nlmixr_llik_binomial_c(SEXP, SEXP, SEXP);
extern SEXP slice_wrap(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);

extern SEXP _nlmixr_npde(SEXP, SEXP, SEXP, SEXP, SEXP, 
			 SEXP);

extern SEXP _nlmixr_llik_poisson(SEXP, SEXP);
extern SEXP _nlmixr_llik_normal(SEXP, SEXP);
extern SEXP _nlmixr_llik_betabinomial(SEXP, SEXP, SEXP);
extern SEXP _nlmixr_llik_student_t(SEXP, SEXP);
extern SEXP _nlmixr_llik_beta(SEXP, SEXP);
extern SEXP _nlmixr_lin_cmt_stan(SEXP , SEXP , SEXP , SEXP , SEXP , SEXP , SEXP , SEXP , SEXP);
extern SEXP _nlmixr_llik_neg_binomial(SEXP, SEXP);

// FOCEi
extern SEXP _nlmixr_chkSolvedInf(SEXP, SEXP);
extern SEXP _nlmixr_chkSortIDTime(SEXP _id,SEXP _time, SEXP _evid);
extern SEXP _nlmixr_nlmixrParameters(SEXP, SEXP);
extern SEXP _nlmixr_nlmixrResid(SEXP, SEXP, SEXP, SEXP, SEXP, 
				SEXP, SEXP);
extern SEXP _nlmixr_nlmixrShrink(SEXP, SEXP, SEXP);
extern SEXP _nlmixr_convertEvidRate(SEXP, SEXP);
extern SEXP _nlmixr_convertEvid(SEXP, SEXP);
extern SEXP _nlmixr_allDose(SEXP evid, SEXP ids);

SEXP _nlmixr_foceiInnerLp(SEXP, SEXP);
SEXP _nlmixr_likInner(SEXP, SEXP);
SEXP _nlmixr_cholSE_(SEXP, SEXP);
SEXP _nlmixr_foceiLik(SEXP);
SEXP _nlmixr_foceiOfv(SEXP);
SEXP _nlmixr_foceiEtas();
SEXP _nlmixr_foceiLik(SEXP);
SEXP _nlmixr_foceiOfv(SEXP);
SEXP _nlmixr_foceiEtas();
SEXP _nlmixr_foceiNumericGrad(SEXP);

SEXP _nlmixr_foceiSetup_(SEXP, SEXP, SEXP, SEXP, SEXP,
			 SEXP, SEXP, SEXP, SEXP, SEXP);

SEXP _nlmixr_foceiOuterF(SEXP);
SEXP _nlmixr_foceiOuterG(SEXP);
SEXP _nlmixr_foceiOuter(SEXP);
SEXP _nlmixr_sqrtm(SEXP);
SEXP _nlmixr_foceiCalcCov(SEXP);
SEXP _nlmixr_foceiFitCpp_(SEXP);
SEXP _nlmixr_coxBox_(SEXP, SEXP, SEXP);
SEXP _nlmixr_freeFocei();

static const R_CMethodDef CEntries[] = {
    {"parse_ode",               (DL_FUNC) &parse_ode,                4},
    {"parse_pars",              (DL_FUNC) &parse_pars,               7},
    {NULL, NULL, 0}
};

static const R_CallMethodDef CallEntries[] = {
  {"_nlmixr_freeFocei", (DL_FUNC) &_nlmixr_freeFocei, 0},
  {"_nlmixr_chkSolvedInf",(DL_FUNC) &_nlmixr_chkSolvedInf, 2},
  {"neldermead_wrap",      (DL_FUNC) &neldermead_wrap,      11},
  /* {"n1qn1_wrap",           (DL_FUNC) &n1qn1_wrap,           13}, */
  {"nlmixr_lin_cmt",       (DL_FUNC) &nlmixr_lin_cmt,        9},
  {"_nlmixr_lin_cmt_stan",  (DL_FUNC) &_nlmixr_lin_cmt_stan,   9},
  {"_nlmixr_llik_binomial_c", (DL_FUNC) &_nlmixr_llik_binomial_c,  3},
  {"_nlmixr_llik_poisson",  (DL_FUNC) &_nlmixr_llik_poisson,   2},
  {"_nlmixr_llik_normal",   (DL_FUNC) &_nlmixr_llik_normal,    2},
  {"_nlmixr_llik_betabinomial", (DL_FUNC) &_nlmixr_llik_betabinomial, 3},
  {"_nlmixr_llik_student_t",  (DL_FUNC) &_nlmixr_llik_student_t, 2},
  {"_nlmixr_llik_beta",     (DL_FUNC) &_nlmixr_llik_beta, 2},
  {"_nlmixr_llik_neg_binomial", (DL_FUNC) &_nlmixr_llik_neg_binomial, 2},
  {"_nlmixr_chkSortIDTime",(DL_FUNC) &_nlmixr_chkSortIDTime, 3},
  {"slice_wrap",           (DL_FUNC) &slice_wrap,            7},
  {"_nlmixr_nlmixrParameters", (DL_FUNC) &_nlmixr_nlmixrParameters, 2},
  {"_nlmixr_nlmixrResid", (DL_FUNC) &_nlmixr_nlmixrResid, 7},
  {"_nlmixr_nlmixrShrink", (DL_FUNC) &_nlmixr_nlmixrShrink, 3},
  {"_nlmixr_convertEvid", (DL_FUNC) &_nlmixr_convertEvid, 2},
  {"_nlmixr_convertEvidRate", (DL_FUNC) &_nlmixr_convertEvidRate, 2},
  {"_nlmixr_npde", (DL_FUNC) &_nlmixr_npde, 6},
  {"_nlmixr_allDose", (DL_FUNC) &_nlmixr_allDose, 2},
  // FOCEi
  {"_nlmixr_foceiInnerLp", (DL_FUNC) &_nlmixr_foceiInnerLp, 2},
  {"_nlmixr_cholSE_", (DL_FUNC) &_nlmixr_cholSE_, 2},
  {"_nlmixr_likInner", (DL_FUNC) &_nlmixr_likInner, 2},
  {"_nlmixr_foceiLik", (DL_FUNC) &_nlmixr_foceiLik, 1},
  {"_nlmixr_foceiOfv", (DL_FUNC) &_nlmixr_foceiOfv, 1},
  {"_nlmixr_foceiEtas", (DL_FUNC) &_nlmixr_foceiEtas, 0},
  {"_nlmixr_foceiNumericGrad", (DL_FUNC) &_nlmixr_foceiNumericGrad, 1},
  {"_nlmixr_foceiSetup_", (DL_FUNC) &_nlmixr_foceiSetup_, 10},
  {"_nlmixr_foceiOuterF", (DL_FUNC) &_nlmixr_foceiOuterF, 1},
  {"_nlmixr_foceiOuterG", (DL_FUNC) &_nlmixr_foceiOuterG, 1},
  {"_nlmixr_foceiOuter", (DL_FUNC) &_nlmixr_foceiOuter, 1},
  {"_nlmixr_sqrtm", (DL_FUNC) &_nlmixr_sqrtm, 1},
  {"_nlmixr_foceiCalcCov", (DL_FUNC) &_nlmixr_foceiCalcCov, 1},
  {"_nlmixr_foceiFitCpp_", (DL_FUNC) &_nlmixr_foceiFitCpp_, 1},
  {"_nlmixr_coxBox_", (DL_FUNC) &_nlmixr_coxBox_, 3},
  {NULL, NULL, 0}
};

void R_init_nlmixr(DllInfo *dll)
{
  R_RegisterCCallable("nlmixr","nelder_fn", (DL_FUNC) &nelder_fn);
  R_registerRoutines(dll, CEntries, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, TRUE);
  R_forceSymbols(dll,FALSE);
}
