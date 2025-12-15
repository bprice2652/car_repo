\name{panel.fit}
\alias{panel.fit}
\title{Panel function for predicted values and SE bands}
\description{
Panel function to display predicted values and SE bands using 
\code{\link[lattice]{xyplot}} in in \pkg{lattice} and
\code{\link[latticeExtra]{layer}} or \code{\link[latticeExtra]{glayer}} 
in \pkg{latticeExtra}
}
\usage{
panel.fit(x, y, fit, lower, upper, subscripts, ..., type, group.number,
  alpha, col, col.line, col.symbol, border = F, font, fontface)
}
\arguments{
\item{x, y}{these are place holders for the arguments that are automatically passed to 
panel functions from \code{\link[lattice]{xyplot}} through 
\code{\link[latticeExtra]{layer}} or \code{\link[latticeExtra]{glayer}}.
Their values are not used by \code{panel.fit}}

\item{fit}{fitted values defined as an argument named \code{fit}
in the call to \code{\link[lattice]{xyplot}} and usually passed to \code{panel.fit}
through \code{\link[latticeExtra]{layer}} or 
\code{\link[latticeExtra]{glayer}}}

\item{lower, upper}{lower and upper limits of error bands, passed in the same way as \code{fit}}

\item{subscripts}{logical, passed \code{\link[lattice]{xyplot}}}

\item{...}{specify any additional arguments to prevent them from being silently passed from 
\code{\link[lattice]{xyplot}} to \code{panel.fit}}

\item{group.number}{passed silently from \code{\link[lattice]{xyplot}}}

\item{alpha}{transparency of the bands, in the interval [0,1]. Provide a value or it will be passed silently from \code{\link[lattice]{xyplot}}}

\item{col}{color, may be specified, otherwise passed from \code{\link[lattice]{xyplot}}}

\item{col.line}{line color, if \code{group.number} isn't specified.}

\item{col.symbol}{color when using groups,may be specified, otherwise passed from \code{\link[lattice]{xyplot}}}

\item{border}{if TRUE draw borders on bands. Default is FALSE}

\item{font}{may be specified, otherwise passed from \code{\link[lattice]{xyplot}}}

\item{fontface}{may be specified, otherwise passed from \code{\link[lattice]{xyplot}}}

\item{type}{currently not used.}
}
\value{
The \code{panel.fit},is invoked for its graphical effect.
}

\details{
With \code{\link[latticeExtra]{layer}} and \code{\link[latticeExtra]{glayer}} 
in \pkg{latticeExtra}, 
\code{panel.fit} can be used to generate fitted values and
confidence or prediction bands that have render correctly
whether a plot uses \var{groups} or not.

If a data frame, \code{data}, is used to fit a model and
contains variables for fitted values and standard error for estimation
or prediction, a typical use of \code{panel.fit} has the following form:
\verb{

   library(latticeExtra)
   xyplot( y ~ x, data, groups = g, fit = data$yhat,
       lower = with(data, yhat - 2*se), upper = with(data, yhat + 2*se),
       subscripts = T) +
   glayer(panel.fit(...))
}
}

\examples{
\dontrun{
  
  ###
  ### Exploring possible discontinuity in value of post-secondary education
  ###
 	 
}
\dontrun{
trellis.focus()
panel.identify(labels = rownames(data),rot=-15,col = col.symbol, etc.)
trellis.unfocus()
}
}
\author{
Georges Monette <georges@yorku.ca>
}
