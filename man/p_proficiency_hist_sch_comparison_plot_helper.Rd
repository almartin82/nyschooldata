% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/proficiency_hist.R
\name{p_proficiency_hist_sch_comparison_plot_helper}
\alias{p_proficiency_hist_sch_comparison_plot_helper}
\title{internal helper function for comparison plots. D.R.Y!}
\usage{
p_proficiency_hist_sch_comparison_plot_helper(assess_db_all, bedscodes,
  subjects, grades, subgroup_codes)
}
\arguments{
\item{assess_db_all}{data.frame, multiple years of assessment history}

\item{bedscodes}{character vector, one or more bedscode(s)}

\item{subjects}{character vector, one or more of c('ELA', 'Math')}

\item{grades}{vector, one or more grades, inclusive of 'All'.  c('All', 3, 4)}

\item{subgroup_codes}{vector, one or more subgroup codes}
}
\value{
list
}
\description{
internal helper function for comparison plots. D.R.Y!
}

