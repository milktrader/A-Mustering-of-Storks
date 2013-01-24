#!/usr/bin/Rscript --vanilla
#
# scorpion trading system
# copyright (c) 2009-2013, Algorithm Alpha, LLC

############################# REQUIRE ######################################

require(quantstrat)
require(PortfolioAnalytics)

############################# GET DATA ######################################

data(spx)

############################# DEFINE VARIABLES ##############################

port          = 'scorpionPort'
acct          = 'scorpionAcct'
initEq        = 100000
initDate      = '1949-12-31'
fast          = 10
slow          = 30

############################# INITIALIZE ####################################

currency('USD')
stock('spx',currency='USD', multiplier=1)
initPortf(port, 'spx', initDate=initDate)
initAcct(acct, port, initEq=initEq, initDate=initDate)
initOrders(port, initDate=initDate )
scorpion = strategy(port)

############################# INDICATORS ####################################

scorpion <- add.indicator( 
                     strategy  = scorpion, 
                     name      = 'rolling_kurt', 
                     arguments = list(x = quote(Cl(mktdata)), 
                                      n = slow),
                     label     = 'slow' )

scorpion <- add.indicator( 
                     strategy  = scorpion, 
                     name      = 'rolling_kurt', 
                     arguments = list(x = quote(Lo(mktdata)), 
                                      n = fast), 
                     label     = 'fast' )
 
############################# SIGNALS #######################################

scorpion <- add.signal(
                  strategy  = scorpion,
                  name      = 'sigCrossover',
                  arguments = list(columns = c(paste("kurt", fast, sep = "."), 
                                               paste("kurt", slow, sep = ".")),
                                   relationship='lt'),
                  label     = 'fast.lt.slow')

scorpion <- add.signal(
                  strategy  = scorpion,
                  name      = 'sigCrossover',
                  arguments = list(columns = c(paste("kurt", fast, sep = "."), 
                                               paste("sk", slow, sep = ".")),  
                                   relationship='gt'),
                  label     = 'fast.gt.slow')

########################### RULES #########################################

scorpion <- add.rule(
                strategy  = scorpion,
                name      = 'ruleSignal',
                arguments = list(sigcol    = 'fast.gt.slow',
                                 sigval    = TRUE,
                                 orderqty  = 100,
                                 ordertype = 'market',
                                 orderside = 'long'),

                type      = 'enter',
                label     = 'EnterLONG')

scorpion <- add.rule(
                strategy  = scorpion,
                name      = 'ruleSignal',
                arguments = list(sigcol    = 'fast.lt.slow',
                                 sigval    = TRUE,
                                 orderqty  = 'all',
                                 ordertype = 'market',
                                 orderside = 'long'),
                type      = 'exit',
                label     = 'ExitLONG')

scorpion <- add.rule(
                strategy  = scorpion,
                name      = 'ruleSignal',
                arguments = list(sigcol     = 'fast.lt.slow',
                                  sigval    = TRUE,
                                  orderqty  =  -100,
                                  ordertype = 'market',
                                  orderside = 'short'),
                type      = 'enter',
                label     = 'EnterSHORT')

scorpion <- add.rule(
                strategy  = scorpion,
                name      = 'ruleSignal',
                arguments = list(sigcol     = 'fast.gt.slow',
                                 sigval     = TRUE,
                                 orderqty   = 'all',
                                 ordertype  = 'market',
                                 orderside  = 'short'),
                type      = 'exit',
                label     = 'ExitSHORT')

########################### APPLY STRATEGY ################################

applyStrategy(scorpion, port, prefer='Open', verbose=FALSE)

############################# UPDATE ########################################

updatePortf(port, 'spx', Date=paste('::',as.Date(Sys.time()),sep=''))
updateAcct(acct)

##################### CONTAINERS CALLED IN TESTING #####################
rets  = PortfReturns(acct)                                     #########
book  = getOrderBook(port)                                     #########
stats = tradeStats(port)                                       #########
txns  = getTxns(port, 'spx')                                   #########
########################################################################
