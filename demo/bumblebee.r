#!/usr/bin/Rscript --vanilla
#
# Bumblebumblebee trading system
# copyright (c) 2009-2013, Algorithm Alpha, LLC
# Licensed GPL-2

############################### REQUIRE ####################################

require(quantstrat)

############################# GET DATA ######################################

data(spx)

############################# DEFINE VARIABLES ##############################

port          = 'bumblebeePort'
acct          = 'bumblebeeAcct'
initEq        = 100000
initDate      = '1969-12-31'
fast          = 10
slow          = 30
sd            = 0.5

############################# INITIALIZE ####################################

currency('USD')
stock('spx',currency='USD', multiplier=1)
initPortf(port, 'spx', initDate=initDate)
initAcct(acct, port, initEq=initEq, initDate=initDate)
initOrders(port, initDate=initDate )
bumblebumblebee = strategy(port)

############################# MAX POSITION LOGIC ############################

addPosLimit(
            portfolio=port,
            symbol='spx', 
            timestamp=initDate,  
            maxpos=100)


############################# INDICATORS ####################################

bumblebee <- add.indicator( 
                     strategy  = bumblebee, 
                     name      = 'BBands', 
                     arguments = list(HLC=quote(HLC(mktdata)), 
                                      n=slow, 
                                      sd=sd))

bumblebee <- add.indicator(
                     strategy  = bumblebee, 
                     name      = 'SMA', 
                     arguments = list(x=quote(Cl(mktdata)), 
                                      n=fast),
                     label     = 'fast' )

############################# SIGNALS #######################################

bumblebee <- add.signal(
                  strategy  = bumblebee,
                  name      = 'sigCrossover',
                  arguments = list(columns=c('fast','dn'), 
                                   relationship='lt'),
                  label     = 'fast.lt.dn')

bumblebee <- add.signal(
                  strategy  = bumblebee,
                  name      = 'sigCrossover',
                  arguments = list(columns=c('fast','up'),
                                   relationship='gt'),
                  label     = 'fast.gt.up')

############################# RULES #########################################

bumblebee <- add.rule(
                strategy  = bumblebee,
                name      = 'ruleSignal',
                arguments = list(sigcol    = 'fast.gt.up',
                                 sigval    = TRUE,
                                 orderqty  = 100,
                                 ordertype = 'market',
                                 orderside = 'long',
                                 osFUN     = 'osMaxPos'),

                type      = 'enter',
                label     = 'EnterLONG')

bumblebee <- add.rule(
                strategy  = bumblebee,
                name      = 'ruleSignal',
                arguments = list(sigcol    = 'fast.lt.dn',
                                 sigval    = TRUE,
                                 orderqty  = 'all',
                                 ordertype = 'market',
                                 orderside = 'long'),
                type      = 'exit',
                label     = 'ExitLONG')

bumblebee <- add.rule(
                strategy  = bumblebee,
                name      = 'ruleSignal',
                arguments = list(sigcol     = 'fast.lt.dn',
                                  sigval    = TRUE,
                                  orderqty  =  -100,
                                  ordertype = 'market',
                                  orderside = 'short',
                                  osFUN     = 'osMaxPos'),
                type      = 'enter',
                label     = 'EnterSHORT')

bumblebee <- add.rule(
                strategy  = bumblebee,
                name      = 'ruleSignal',
                arguments = list(sigcol     = 'fast.gt.up',
                                 sigval     = TRUE,
                                 orderqty   = 'all',
                                 ordertype  = 'market',
                                 orderside  = 'short'),
                type      = 'exit',
                label     = 'ExitSHORT')

############################# APPLY STRATEGY ################################

applyStrategy(bumblebee, port, prefer='Open', verbose=FALSE)

############################# UPDATE ########################################

updatePortf(port, 'spx', Date=paste('::',as.Date(Sys.time()),sep=''))
updateAcct(acct)

##################### CONTAINERS CALLED IN TESTING #####################
                                                               #########
rets  = PortfReturns(acct)                                     #########
book  = getOrderBook(port)                                     #########
stats = tradeStats(port)                                       #########
                                                               #########
########################################################################
