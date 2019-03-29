

// This is a test file that uses edprem.dta data to plot a chart
// using Urban graphics scheme.

// File scheme-urban.scheme needs to be in your personal ado path.
// The default ado folder is usually c:\ado\personal. If you want to
// add another one, execute:
// adopath + d:\Ado\Personal

// Set Urban scheme
set scheme urban                         


use edprem
scatter exp_clphsg_dc exp_clphsg_all exp_gap_clp_quad_dc exp_gap_clp_quad year, ///
  c(l l l l) msymbol (o d s t) ///
  xlabel(#9) ylab(35(10)105) ///
  subtitle("College Premium(Percent)") ///
  ti("Actual and Predicted College Premium, 1963 - 2012") ///
  note("Source: CPS 1963-2012.")

