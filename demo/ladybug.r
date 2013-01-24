#!/usr/bin/Rscript --vanilla
#
# ladybug trading system
# copyright (c) 2009-2013, Algorithm Alpha, LLC

############################# REQUIRE ######################################

require(quantstrat)
require(PortfolioAnalytics)

############################# GET DATA ######################################

data(spx)

############################# DEFINE VARIABLES ##############################

port          = 'ladybugPort'
acct          = 'ladybugAcct'
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
ladybug = strategy(port)

############################# INDICATORS ####################################

ladybug <- add.indicator( 
                     strategy  = ladybug, 
                     name      = 'rolling_skew', 
                     arguments = list(x = quote(Cl(mktdata)), 
                                      n = slow),
                     label     = 'slow' )

ladybug <- add.indicator( 
                     strategy  = ladybug, 
                     name      = 'rolling_skew', 
                     arguments = list(x = quote(Lo(mktdata)), 
                                      n = fast), 
                     label     = 'fast' )
 
############################# SIGNALS #######################################
#
#ladybug <- add.signal(
#                  strategy  = ladybug,
#                  name      = 'sigCrossover',
#                  arguments = list(columns = c(paste("sk", fast, sep = "."), 
#                                               paste("sk", slow, sep = ".")),
#                                   relationship='lt'),
#                  label     = 'fast.lt.slow')
#
#ladybug <- add.signal(
#                  strategy  = ladybug,
#                  name      = 'sigCrossover',
#                  arguments = list(columns = c(paste("sk", fast, sep = "."), 
#                                               paste("sk", slow, sep = ".")),  
#                                   relationship='gt'),
#                  label     = 'fast.gt.slow')
#
############################ RULES #########################################
#
#ladybug <- add.rule(
#                strategy  = ladybug,
#                name      = 'ruleSignal',
#                arguments = list(sigcol    = 'fast.gt.slow',
#                                 sigval    = TRUE,
#                                 orderqty  = 100,
#                                 ordertype = 'market',
#                                 orderside = 'long'),
#                  #               osFUN     = 'osMaxPos'),
#
#                type      = 'enter',
#                label     = 'EnterLONG')
#
#ladybug <- add.rule(
#                strategy  = ladybug,
#                name      = 'ruleSignal',
#                arguments = list(sigcol    = 'fast.lt.slow',
#                                 sigval    = TRUE,
#                                 orderqty  = 'all',
#                                 ordertype = 'market',
#                                 orderside = 'long'),
#                type      = 'exit',
#                label     = 'ExitLONG')
#
#ladybug <- add.rule(
#                strategy  = ladybug,
#                name      = 'ruleSignal',
#                arguments = list(sigcol     = 'fast.lt.slow',
#                                  sigval    = TRUE,
#                                  orderqty  =  -100,
#                                  ordertype = 'market',
#                                  orderside = 'short'),
##                                  osFUN     = 'osMaxPos'),
#                type      = 'enter',
#                label     = 'EnterSHORT')
#
#ladybug <- add.rule(
#                strategy  = ladybug,
#                name      = 'ruleSignal',
#                arguments = list(sigcol     = 'fast.gt.slow',
#                                 sigval     = TRUE,
#                                 orderqty   = 'all',
#                                 ordertype  = 'market',
#                                 orderside  = 'short'),
#                type      = 'exit',
#                label     = 'ExitSHORT')
#
########################### APPLY STRATEGY ################################

applyStrategy(ladybug, port, prefer='Open', verbose=FALSE)

############################# UPDATE ########################################

updatePortf(port, 'spx', Date=paste('::',as.Date(Sys.time()),sep=''))
updateAcct(acct)

##################### CONTAINERS CALLED IN TESTING #####################
rets  = PortfReturns(acct)                                     #########
book  = getOrderBook(port)                                     #########
stats = tradeStats(port)                                       #########
txns  = getTxns(port, 'spx')                                   #########
########################################################################
