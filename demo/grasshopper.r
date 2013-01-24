#!/usr/bin/Rscript --vanilla
#
# Grasshopper trading system
# copyright (c) 2009-2013, Algorithm Alpha, LLC

############################# REQUIRE ######################################

require(quantstrat)
require(PortfolioAnalytics)


############################# LOCAL FUNCTION ######################################

rolling_skew <- function(x, n) {
  foo = rollapply(x, FUN=skewness, width=n)
  bar = cbind(foo, index(x))
  colnames(bar) = paste("sk", n, sep=".")
  bar
}


############################# GET DATA ######################################

data(GSPC)

############################# DEFINE VARIABLES ##############################

port          = 'grasshopperPort'
acct          = 'grasshopperAcct'
initEq        = 100000
initDate      = '1949-12-31'
fast          = 10
slow          = 30

############################# INITIALIZE ####################################

currency('USD')
stock('GSPC',currency='USD', multiplier=1)
initPortf(port, 'GSPC', initDate=initDate)
initAcct(acct, port, initEq=initEq, initDate=initDate)
initOrders(port, initDate=initDate )
grasshopper = strategy(port)

############################# MAX POSITION LOGIC ############################

addPosLimit(
            portfolio=port,
            symbol='GSPC', 
            timestamp=initDate,  
            maxpos=100)


############################# INDICATORS ####################################

grasshopper <- add.indicator( 
                     strategy  = grasshopper, 
                     name      = 'rolling_skew', 
                     arguments = list(x = quote(Cl(mktdata)), 
                                      n = slow),
                     label     = 'slow' )

grasshopper <- add.indicator( 
                     strategy  = grasshopper, 
                     name      = 'rolling_skew', 
                     arguments = list(x = quote(Lo(mktdata)), 
                                      n = fast), 
                     label     = 'fast' )
 
############################# SIGNALS #######################################

grasshopper <- add.signal(
                  strategy  = grasshopper,
                  name      = 'sigCrossover',
                  arguments = list(columns=c('sk.10','sk.30'), 
                                   relationship='lt'),
                  label     = 'fast.lt.slow')

grasshopper <- add.signal(
                  strategy  = grasshopper,
                  name      = 'sigCrossover',
                  arguments = list(columns=c('sk.10','sk.30'),
                                   relationship='gt'),
                  label     = 'fast.gt.slow')

########################### RULES #########################################

grasshopper <- add.rule(
                strategy  = grasshopper,
                name      = 'ruleSignal',
                arguments = list(sigcol    = 'fast.gt.slow',
                                 sigval    = TRUE,
                                 orderqty  = 100,
                                 ordertype = 'market',
                                 orderside = 'long'),
                  #               osFUN     = 'osMaxPos'),

                type      = 'enter',
                label     = 'EnterLONG')

grasshopper <- add.rule(
                strategy  = grasshopper,
                name      = 'ruleSignal',
                arguments = list(sigcol    = 'fast.lt.slow',
                                 sigval    = TRUE,
                                 orderqty  = 'all',
                                 ordertype = 'market',
                                 orderside = 'long'),
                type      = 'exit',
                label     = 'ExitLONG')

grasshopper <- add.rule(
                strategy  = grasshopper,
                name      = 'ruleSignal',
                arguments = list(sigcol     = 'fast.lt.slow',
                                  sigval    = TRUE,
                                  orderqty  =  -100,
                                  ordertype = 'market',
                                  orderside = 'short'),
#                                  osFUN     = 'osMaxPos'),
                type      = 'enter',
                label     = 'EnterSHORT')

grasshopper <- add.rule(
                strategy  = grasshopper,
                name      = 'ruleSignal',
                arguments = list(sigcol     = 'fast.gt.slow',
                                 sigval     = TRUE,
                                 orderqty   = 'all',
                                 ordertype  = 'market',
                                 orderside  = 'short'),
                type      = 'exit',
                label     = 'ExitSHORT')

########################### APPLY STRATEGY ################################

applyStrategy(grasshopper, port, prefer='Open', verbose=FALSE)

############################# UPDATE ########################################

updatePortf(port, 'GSPC', Date=paste('::',as.Date(Sys.time()),sep=''))
updateAcct(acct)

##################### CONTAINERS CALLED IN TESTING #####################
rets  = PortfReturns(acct)                                     #########
book  = getOrderBook(port)                                     #########
stats = tradeStats(port)                                       #########
txns  = getTxns(port, 'GSPC')                                     #########
########################################################################
