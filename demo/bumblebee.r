#!/usr/bin/Rscript --vanilla
#
# Bumblebee trading system
# copyright (c) 2009-2013, Algorithm Alpha, LLC

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
bumblebee = strategy(port)

############################# MAX POSITION LOGIC ############################

addPosLimit(
            portfolio=port,
            symbol='spx', 
            timestamp=initDate,  
            maxpos=100)


############################# INDICATORS ####################################

add.indicator(bumblebee, name='BBands', arguments = list(HLC=quote(HLC(mktdata)), n=slow, sd=sd))

add.indicator(bumblebee, name='SMA', label='fast', arguments = list(x=quote(Cl(mktdata)), n=fast))

############################# SIGNALS #######################################

add.signal(bumblebee, name='sigCrossover', label= 'fast.lt.dn', arguments = list(columns=c('fast','dn'), relationship='lt'))

add.signal(bumblebee, name='sigCrossover', label='fast.gt.up', arguments = list(columns=c('fast','up'), relationship='gt'))

############################# RULES #########################################

add.rule(bumblebee, 
         name='ruleSignal', 
         type='enter', 
         label='EnterLONG',
         arguments=list(sigcol= 'fast.gt.up', sigval= TRUE, orderqty=100, ordertype = 'market', orderside='long', osFUN= 'osMaxPos')


add.rule(bumblebee, 
         name='ruleSignal', 
         type='exit', 
         label='ExitLONG', 
         arguments=list(sigcol='fast.lt.dn', sigval=TRUE, orderqty ='all', ordertype='market', orderside='long'))

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
rets  = PortfReturns(acct)                                     #########
book  = getOrderBook(port)                                     #########
stats = tradeStats(port)                                       #########
########################################################################
