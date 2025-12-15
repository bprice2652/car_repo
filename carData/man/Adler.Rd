\name{Adler}
\alias{Adler}
\docType{data}

\title{Experimenter Expectations} 

\description{
The \code{Adler} data frame has 108 rows and 3 columns.  
                                                        
The ``experimenters'' were the actual subjects of the study. 
They collected ratings of the apparent success of
people in pictures who were pre-selected for their
average appearance of success. The experimenters were told prior to collecting 
data that particular subjects were either high or low in their tendency to rate 
appearance of success, and were instructed to get good data, 
scientific data, or were given no such instruction. Each 
experimenter collected ratings from 18 randomly assigned
subjects. This version of the Adler data is taken from Erickson and Nosanchuk (1977).
The data described in the original source, Adler (1973), have a more complex structure.
}

\format{
  This data frame contains the following columns:
  \describe{
    \item{instruction}{
     a factor with levels:
     \code{good}, good data;
     \code{none}, no stress;
     \code{scientific}, scientific data.
     }
    \item{expectation}{
     a factor with levels:
     \code{high}, expect high ratings;
     \code{low}, expect low ratings.
     }
    \item{rating}{
     The average rating obtained.  
     }
   }
 }

\source{
  Erickson, B. H., and Nosanchuk, T. A. (1977)
  \emph{Understanding Data.} McGraw-Hill Ryerson.
}

\references{
Adler, N. E. (1973)
 Impact of prior sets given experimenters and subjects on the experimenter
 expectancy effect.
 \emph{Sociometry} \bold{36}, 113--126.
}

\usage{
Adler
}

\keyword{datasets}
