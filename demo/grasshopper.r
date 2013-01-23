#!/usr/bin/Rscript --vanilla
#
# Grasshopper trading system
# copyright (c) 2009-2013, Algorithm Alpha, LLC

############################### REQUIRE ####################################

require(quantstrat)

############################# GET DATA ######################################

data(GSPC)

############################# DEFINE VARIABLES ##############################

port          = 'grasshopperPort'
acct          = 'grasshopperAcct'
initEq        = 100000
initDate      = '1969-12-31'
fast          = 30
slow          = 300

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
                     name      = 'rollapply.skew', 
                     arguments = list(x = quote(Cl(mktdata)), 
                                      n = slow) 

# grasshopper <- add.indicator(
#                      strategy  = grasshopper, 
#                      name      = 'SMA', 
#                      arguments = list(x=quote(Cl(mktdata)), 
#                                       n=fast),
#                      label     = 'fast' )
# 
# ############################# SIGNALS #######################################
# 
# grasshopper <- add.signal(
#                   strategy  = grasshopper,
#                   name      = 'sigCrossover',
#                   arguments = list(columns=c('fast','dn'), 
#                                    relationship='lt'),
#                   label     = 'fast.lt.dn')
# 
# grasshopper <- add.signal(
#                   strategy  = grasshopper,
#                   name      = 'sigCrossover',
#                   arguments = list(columns=c('fast','up'),
#                                    relationship='gt'),
#                   label     = 'fast.gt.up')
# 
# ############################# RULES #########################################
# 
# grasshopper <- add.rule(
#                 strategy  = grasshopper,
#                 name      = 'ruleSignal',
#                 arguments = list(sigcol    = 'fast.gt.up',
#                                  sigval    = TRUE,
#                                  orderqty  = 100,
#                                  ordertype = 'market',
#                                  orderside = 'long',
#                                  osFUN     = 'osMaxPos'),
# 
#                 type      = 'enter',
#                 label     = 'EnterLONG')
# 
# grasshopper <- add.rule(
#                 strategy  = grasshopper,
#                 name      = 'ruleSignal',
#                 arguments = list(sigcol    = 'fast.lt.dn',
#                                  sigval    = TRUE,
#                                  orderqty  = 'all',
#                                  ordertype = 'market',
#                                  orderside = 'long'),
#                 type      = 'exit',
#                 label     = 'ExitLONG')
# 
# grasshopper <- add.rule(
#                 strategy  = grasshopper,
#                 name      = 'ruleSignal',
#                 arguments = list(sigcol     = 'fast.lt.dn',
#                                   sigval    = TRUE,
#                                   orderqty  =  -100,
#                                   ordertype = 'market',
#                                   orderside = 'short',
#                                   osFUN     = 'osMaxPos'),
#                 type      = 'enter',
#                 label     = 'EnterSHORT')
# 
# grasshopper <- add.rule(
#                 strategy  = grasshopper,
#                 name      = 'ruleSignal',
#                 arguments = list(sigcol     = 'fast.gt.up',
#                                  sigval     = TRUE,
#                                  orderqty   = 'all',
#                                  ordertype  = 'market',
#                                  orderside  = 'short'),
#                 type      = 'exit',
#                 label     = 'ExitSHORT')
# 
############################# APPLY STRATEGY ################################

applyStrategy(grasshopper, port, prefer='Open', verbose=FALSE)

############################# UPDATE ########################################

updatePortf(port, 'GSPC', Date=paste('::',as.Date(Sys.time()),sep=''))
updateAcct(acct)

##################### CONTAINERS CALLED IN TESTING #####################
rets  = PortfReturns(acct)                                     #########
book  = getOrderBook(port)                                     #########
stats = tradeStats(port)                                       #########
txns  = getTxns(port, sym)                                     #########
########################################################################
