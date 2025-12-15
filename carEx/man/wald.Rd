\name{wald}
\alias{wald}
\alias{as.data.frame.wald}
\alias{print.wald}

\title{Wald Test of a General Linear Hypothesis for the 'Fixed' Portion of a Model}
\usage{
wald(fit, Llist = "", clevel = 0.95, pred = NULL, data = NULL,
  debug = FALSE, maxrows = 25, full = FALSE, fixed = FALSE,
  invert = FALSE, method = "svd", df = NULL, pars = NULL, ...)
  
\method{as.data.frame}{wald}(x, row.names=NULL, optional, se=2, digits=3, sep = "", which=1, ...)

\method{print}{wald}(x, round=6, ...) 
}


\arguments{

\item{fit}{a model for which a \code{getFix} method exists.}

\item{Llist}{a hypothesis matrix or a pattern to be matched or a list of
these.}

\item{clevel}{level for confidence intervals. No confidence intervals if \code{clevel} is \code{NULL}.}

\item{pred}{(default \code{NULL}) a data frame to use to create a model matrix. 
This is an alternative to `full` when the model matrix needs to
be based on a data frame other than the data frame used for 
fitting the model.}

\item{data}{data frame used as \code{"data"} attribute fot list elements returned only if
the corresponding element of \code{Llist} has a \code{NULL} data attribute}

\item{debug}{(default \code{FALSE}) produce verbose information}

\item{maxrows}{maximum number of rows of hypothesis matrix for which a full
variance-covariance matrix is returned}

\item{full}{if \code{TRUE}, the hypothesis matrix is the model matrix for
 \code{fit} such that the estimated coefficients are the predicted values for
the fixed portion of the model. This is designed to allow the calculation of
standard errors for models for which the \code{predict} method does not
provide them.}

\item{fixed}{normally if \code{Llist} is a character string, it's treated as a regular expression;
if \code{fixed} is \code{TRUE}, \code{Llist} is interpreted literally, i.e.,
characters that have a special meaning in regular expressions are
interpreted literally.}

\item{invert}{if \code{Llist} is a character string to be used as a regular
expression, \code{invert == TRUE} causes the matches to be inverted so that
coefficients that do \emph{not} match will be selected.}

\item{method}{\code{"svd"} (current default) or \code{"qr"} is the method used to find the
full rank version of the hypothesis matrix.  (\code{"svd"} has correctly identified
the rank of a large hypothesis matrix where \code{"qr"} has failed.)}

\item{pars}{passed to \code{\link[rstan]{extract}} for \code{"stanfit"} objects.}

\item{x}{a \code{"wald"} object.}

\item{df}{denominator degrees of freedom (overrides usual value).}

\item{se}{multiplier (default 2) for standard errors in computing confidence limits.}

\item{digits, round}{number of digits to the right of the decimal.}

\item{sep}{separator character, for creating names, default is \code{""} (no separator).}

\item{which}{which element(s) of a \code{"wald"} object to convert to a data frame.}

\item{row.names}{optional row names for the resulting data frame.}

\item{..., optional}{to match generic, ignored.}

}

\value{
An object of class \code{wald}.
}
\description{
General Linear Hypothesis with Wald test for, e.g., \code{lm}, \code{glm}, \code{lme}, \code{nlme}  and 
\code{lmer} objects.  Can be extended to other classes by writing an appropriate \code{\link{getFix}} method.
}

\details{
Tests a general linear hypothesis for the linear fixed portion of a model.
The hypothesis can be specified in a variety of ways such as a hypothesis
matrix or a pattern that is used as a regular expression to be matched with
the names of coefficients of the model. A number of tools are available to
facilitate the generation of hypothesis matrices.

Usage:

\code{wald(fit, L)} where \code{L} is a hypothesis matrix

\code{wald(fit, "pat")} where \code{"pat"} is a regular expression (see \code{\link{regex}}) used to
match names of coefficients of fixed effects.  e.g. \code{wald( fit, ":.*:")} tests
all second and higher order interactions.

\code{wald(fit, c(2, 5, 6))} to test 2nd, 5th and 6th coefficients.

\code{wald(fit, list(hyp1 = c(2, 5, 6), H2 = "pat"))} for more than one hypothesis
matrix.

%There are number of functions to help construct hypothesis matrices. See in
%particular \code{\link{Lfx}}.

To extend the \code{wald} function to a new class of objects, one needs to
write a \code{\link{getFix}} method to extract estimated coefficients, their estimated
covariance matrix, and the denominator degrees of freedom for each
estimated coefficient.
}

\examples{

if (require(nlme)){
###
### Using wald to create and plot a data frame with predicted values
###
MathAchieve$Sector <- MathAchSchool[as.character(MathAchieve$School), "Sector"]
fit <- lme(MathAch ~ (SES+I(SES^2)) * Sex * Sector, MathAchieve, random = ~ 1|School)
S(fit)
pred <- expand.grid( SES = seq(-2,2,.1), Sex = levels(MathAchieve$Sex), 
Sector = levels(MathAchieve$Sector))
pred
w <- wald(fit, getX(fit,data=pred)) # attaches data to wald.object 
                                    # so it can be included in data frame
w <- wald(fit, pred = pred)
w <- as.data.frame(w)
head(w)
if(require("latticeExtra")){
     xyplot(coef ~ SES | Sector, w, groups = Sex,
            auto.key = TRUE, type = 'l',
            fit = w$coef,
            upper = with(w,coef+2*se),
            lower = with(w,coef-2*se),
            subscript = TRUE) +
         glayer(panel.fit(...))
}

wald( fit, 'Sex')  # sig. overall effect of Sex
wald( fit, ':Sex') # but no evidence of interaction with ses
wald( fit, '\\\\^2') # nor of curvature

# but we continue for the sake of illustration

L <- Lform( fit, list( 0, 1, 2*SES, 0, Sex == 'Male', (Sex == 'Male')*2*SES), MathAchieve)
head(L)
(ww <- wald ( fit, L ))
wald.dd <- as.data.frame(ww, se = 2)
head( wald.dd )

if (require("lattice")){
  xyplot(coef + U2 + L2 ~ SES | Sex, wald.dd,
         main= 'Increase in predicted mathach per unit increase in ses')
}
}

}

\seealso{
To extend to new models see \code{\link{getFix}}. To generate hypothesis matrices for general
splines see \code{\link{gspline}}.
}

\author{
Georges Monette
}