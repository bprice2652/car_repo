\name{Blackmore}
\alias{Blackmore}
\docType{data}
\title{Exercise Histories of Eating-Disordered and Control Subjects}
\usage{Blackmore}
\description{
The \code{Blackmore} data frame has 945 rows and 4 columns.
Blackmore and Davis's data on exercise histories of 138 teenaged
girls hospitalized for eating disorders and 98 control subjects.
}
\format{
  This data frame contains the following columns:
  \describe{
    \item{subject}{a factor with subject id codes.  There are several observations for each subject, but because the girls were hospitalized at different ages, the number of cases and the age at the last case vary.}
    \item{age}{subject's  age  in  years  at  the  time  of  observation;  all  but  the  last observation for each subject were collected retrospectively at intervals of two years, starting at age 8.}
    \item{exercise}{the amount of exercise in which the subject engaged, expressed as estimated hours per week.}
    \item{group}{a factor with levels:
        \code{control}, Control subjects;
        \code{patient}, Eating-disordered patients.
    }
  }
}

\source{
 Personal communication from Elizabeth Blackmore and Caroline Davis,
 York University.
}

\keyword{datasets}
