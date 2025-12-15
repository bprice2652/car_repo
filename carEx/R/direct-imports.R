# last modified 2018-09-01

coef.merMod <- lme4::fixef
coef.lme <- nlme::fixef

# these unexported functions are copied from the car package

ConjComp <- car:::ConjComp
assignVector <- car:::assignVector
relatives <- car:::relatives
term.names <- car:::term.names
term.names.default <- car:::term.names.default
responseName <- car:::responseName
responseName.default <- car:::responseName.default
has.intercept <- car:::has.intercept
has.intercept.default <- car:::has.intercept.default
has.intercept.matrix <- car:::has.intercept.matrix
has.intercept.mer <- car:::has.intercept.mer
has.intercept.merMod <- car:::has.intercept.merMod
has.intercept.mlm <- car:::has.intercept.mlm
has.intercept.multinom <- car:::has.intercept.multinom
has.intercept.vlm <- car:::has.intercept.vlm
