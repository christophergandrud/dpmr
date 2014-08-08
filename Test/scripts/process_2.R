##############
# FRT Index Stan Test
# Christopher Gandrud
# 10 July 2014
# MIT License
##############

# Load packages
library(WDI)
library(DataCombine)
library(reshape2)
library(dplyr)
library(rstan)

# --------------------------------------------------- #
#### Create Indicator Data Set ####
# Download GFDD data from the World Bank
Indicators <- c('GFDD.DI.01', 'GFDD.DI.03', 'GFDD.DI.04',
                'GFDD.DI.05', 'GFDD.DI.06', 'GFDD.DI.07', 'GFDD.DI.08',
                'GFDD.DI.11', 'GFDD.DI.13', 'GFDD.DI.14',
                'GFDD.EI.02', 'GFDD.EI.08', 'GFDD.OI.02', 'GFDD.OI.07',
                'GFDD.SI.02', 'GFDD.SI.03', 'GFDD.SI.04', 'GFDD.SI.05',
                'GFDD.SI.07')

# Download indicators
# Unable to download 'GFDD.DM.011', 'GFDD.OI.14'
Base <- WDI(indicator = Indicators, start = 1998, end = 2011, extra = TRUE)

# Keep countries with 'High income' (OECD and non-OECD classification)
BaseSub <- grepl.sub(data = Base, Var = 'income', pattern = 'High income')
Droppers <- c("iso3c", "region",  "capital", "longitude", "latitude",
              "income", "lending")
BaseSub <- BaseSub[, !(names(BaseSub) %in% Droppers)]

#### Create missingness indicators ####
KeeperLength <- length(Indicators)
IndSub <- Indicators[1:KeeperLength]
VarVec <- vector()

for (i in IndSub){
  BaseSub[, paste0('Rep_', i)] <- 1
  BaseSub[, paste0('Rep_', i)][is.na(BaseSub[, i])] <- 0

  temp <- paste0('Rep_', i)
  VarVec <- append(VarVec, temp)
}

#### Data description ####
# Create country/year numbers
BaseSub$countrynum <- as.numeric(as.factor(BaseSub$iso2c))
BaseSub$yearnum <- as.numeric(as.factor(BaseSub$year))

#### Clean up ####
# Keep only complete variables
BaseStanReady <- BaseSub[, c('countrynum', 'yearnum', VarVec)]

# Data descriptions
NCountry <- max(BaseStanReady$countrynum)
NItems <- length(VarVec)
NYear <- max(BaseStanReady$yearnum)

### !!!!!!!!!!!!!!! Test with no time
BaseStanReady <- subset(BaseStanReady, yearnum == 10) # !!! This is for the test
BaseStanReady <- BaseStanReady[, -2] # !!! This is also for the test

# Melt data so that it is easy to enter into Stan data list
MoltenStanReady <- melt(BaseStanReady, id.vars = 'countrynum')

# Convert item names to numeric
MoltenStanReady$variable <- as.numeric(as.factor(MoltenStanReady$variable))

# Order data
MoltenStanReady <- arrange(MoltenStanReady, countrynum, variable)

# --------------------------------------------------- #
#### Specify Model ####

frt_code <- '
    data {
        int<lower=1> J;                // number of countries
        int<lower=1> K;                // number of items
        int<lower=1> N;                // number of obvservations
        int<lower=1,upper=J> jj[N];    // country for observation n
        int<lower=1,upper=K> kk[N];    // question for observation n
        int<lower=0,upper=1> y[N];     // correctness for observation n
    }

    parameters {
        real delta;                    // mean transparency
        real alpha[J];                 // transparency for j - mean
        real beta[K];                  // difficulty of item k
        real log_gamma[K];             // discrimination of k
        real<lower=0> sigma_alpha;     // scale of abilities
        real<lower=0> sigma_beta;      // scale of difficulties
        real<lower=0> sigma_gamma;     // scale of log discrimiation
    }

model {
    alpha ~ normal(0,sigma_alpha);
    beta ~ normal(0,sigma_beta);
    log_gamma ~ normal(0,sigma_gamma);
    delta ~ cauchy(0,5);
    sigma_alpha ~ cauchy(0,5);
    sigma_beta ~ cauchy(0,5);
    sigma_gamma ~ cauchy(0,5);
    for (n in 1:N)
        y[n] ~ bernoulli_logit( exp(log_gamma[kk[n]])
                            * (alpha[jj[n]] - beta[kk[n]] + delta) );
}
'

# Create data for Stan
frt_data <- list(
    J = NCountry,
    K = NItems,
    N = nrow(MoltenStanReady),
    jj = MoltenStanReady$countrynum,
    kk = MoltenStanReady$variable,
    y = MoltenStanReady$value
)

# Run model
fit1 <- stan(model_code = frt_code, data = frt_data,
            iter = 10000, chains = 4)

fit# Examine results
print(fit1)
