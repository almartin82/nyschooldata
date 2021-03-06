% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/proficiency_hist.R
\name{p_proficiency_hist}
\alias{p_proficiency_hist}
\title{p_proficiency_hist}
\usage{
p_proficiency_hist(assess_db_all, bedscodes, subjects, grades,
  subgroup_codes = "01")
}
\arguments{
\item{assess_db_all}{data.frame, multiple years of assessment history}

\item{bedscodes}{character vector, one or more bedscode(s)}

\item{subjects}{character vector, one or more of c('ELA', 'Math')}

\item{grades}{vector, one or more grades, inclusive of 'All'.  c('All', 3, 4)}

\item{subgroup_codes}{vector, one or more subgroup codes}
}
\value{
ggplot
}
\description{
workhorse ggplot function that groups by
school/grade/subject and plots.  internal.  output needs to be
cleaned up by other functions.
}

