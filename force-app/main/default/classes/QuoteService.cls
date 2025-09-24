public without sharing class QuoteService {
    private static Map<String, Schema.RecordTypeInfo> opportunityRecordTypesMap = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();

    public static void syncQuoteWithOpportunity(Map<Id, Quote> newMap, Map<Id, Quote> oldMap) {
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> opportunityIds = populateOppIdsSetWithQuoteOpportunity(newMap.values());

        Map<Id, Opportunity> quoteOppsMap = new Map<Id, Opportunity>([SELECT Id, Name, RecordTypeId FROM Opportunity WHERE Id IN :opportunityIds]);
        opportunityIds = new Set<Id>();

        for (Quote currentQuote : newMap.values()) {

            if (quoteOppsMap.get(currentQuote.OpportunityId).RecordTypeId == opportunityRecordTypesMap.get('MidiasVendas').getRecordTypeId())
                continue;

            Quote oldQuoteValue = oldMap.get(currentQuote.Id);

            Boolean quoteStatusChangedToPaymentDone = (currentQuote.Status.equals('PAGAMENTO_REALIZADO')) && currentQuote.Status != oldQuoteValue.Status;
            Boolean quoteFuturePaymentChangedToTrue = currentQuote.PagamentoFuturo__c != oldQuoteValue.PagamentoFuturo__c && currentQuote.PagamentoFuturo__c;

            if (quoteStatusChangedToPaymentDone && !currentQuote.Sincronizado__c) {
                currentQuote.Status = 'FINALIZADA';
                currentQuote.Sincronizado__c = true;
            }

            Boolean paymentDoneAndFuturePayment = quoteStatusChangedToPaymentDone && oldQuoteValue.PagamentoFuturo__c;
            Boolean paymentDoneAndFutureSale = quoteStatusChangedToPaymentDone && oldQuoteValue.VendaFutura__c;
            Boolean FuturePaymentChangedToTrueAndNotSynced = quoteFuturePaymentChangedToTrue && !oldQuoteValue.Sincronizado__c;
      
            if (quoteStatusChangedToPaymentDone || oldQuoteValue.PagamentoFuturo__c || paymentDoneAndFuturePayment || paymentDoneAndFutureSale || FuturePaymentChangedToTrueAndNotSynced) {

                quoteIds.add(oldQuoteValue.Id);
                opportunityIds.add(oldQuoteValue.OpportunityId);            
            } 
        }

        try {

            OpportunityLineItemService.insertOrUpdateOpportunityLineItemsFromQuote(
                OpportunityLineItemSelector.selectByOpportunityId(opportunityIds),
                QuoteLineItemSelector.selectByQuoteId(quoteIds),
                opportunityIds
            );
        } catch (Exception e){
            System.debug(' Exception no syncQuoteWithOpportunity: ' + e.getMessage());
            Throw e;
        }  
    }

    public static void deleteRemovedLineItemsAndUpdateOpportunityProducts(Map<Id, Quote> newMap, Map<Id, Quote> oldMap) {
        Set<Id> opportunityIds = populateOppIdsSetWithQuoteOpportunity(newMap.values());

        Map<Id, Opportunity> quoteOppsMap = new Map<Id, Opportunity>([SELECT Id, Name, RecordTypeId FROM Opportunity WHERE Id IN :opportunityIds]);

        opportunityIds = new Set<Id>();

        for (Quote currentQuote : newMap.values()) {
            if (quoteOppsMap.get(currentQuote.OpportunityId).RecordTypeId == opportunityRecordTypesMap.get('MidiasVendas').getRecordTypeId())
                continue;

            Quote oldQuoteValue = oldMap.get(currentQuote.Id);

            Boolean quoteDesynchronized = currentQuote.Sincronizado__c != oldMap.get(currentQuote.Id).Sincronizado__c && !currentQuote.Sincronizado__c;

            Boolean quoteFuturePaymentChangedToFalse = currentQuote.PagamentoFuturo__c != oldQuoteValue.PagamentoFuturo__c && !currentQuote.PagamentoFuturo__c;

            if ((quoteDesynchronized && !currentQuote.PagamentoFuturo__c) || (quoteFuturePaymentChangedToFalse && !currentQuote.Sincronizado__c))
                opportunityIds.add(currentQuote.OpportunityId);
        }

        List<OpportunityLineItem> opportunityProductsToDelete = OpportunityLineItemSelector.selectByOpportunityId(opportunityIds);

        if (!opportunityProductsToDelete.isEmpty()) {
            delete opportunityProductsToDelete;
        }

        OpportunityLineItemService.insertOrUpdateOpportunityLineItemsFromQuote(
            new List<OpportunityLineItem>(),
            QuoteLineItemSelector.selectByOpportunityIdAndSynchronizedOrFuturePayment(opportunityIds, true, true),
            opportunityIds
        );
    }

    @InvocableMethod(label='Sincronizar cotação com oportunidade' description='Método criado para sincronizar a cotação com a oportunidade vinculada a ela')
    public static void syncQuoteWithOpportunity(List<Quote> flowQuotes) {
        if (flowQuotes.isEmpty() || flowQuotes.get(0).PagamentoFuturo__c)
            return;

        Set<Id> quoteIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();

        for (Quote currentQuote : flowQuotes) {
            quoteIds.add(currentQuote.Id);
            opportunityIds.add(currentQuote.OpportunityId);
        }

        OpportunityLineItemService.insertOrUpdateOpportunityLineItemsFromQuote(
            OpportunityLineItemSelector.selectByOpportunityId(opportunityIds),
            QuoteLineItemSelector.selectByQuoteId(quoteIds),
            opportunityIds
        );
    }

    private static Set<Id> populateOppIdsSetWithQuoteOpportunity(List<Quote> quotesToProcess) {
        Set<Id> opportunityIds = new Set<Id>();

        for (Quote currentQuote : quotesToProcess) {
            opportunityIds.add(currentQuote.OpportunityId);
        }

        return opportunityIds;
    }

    public static void nullFieldCanceledQuote(Map<Id, Quote> quoteMap) {
        List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
        quoteLineItemList = [SELECT Id, QuoteId, UnitPrice FROM QUOTELINEITEM WHERE QuoteId IN :quoteMap.keySet()];

        List<RelatedListDefinition> quoteLineItemRelatedList = [
            SELECT Id, DurableId, Label, RelatedListName
            FROM RelatedListDefinition
            WHERE ParentEntityDefinitionId = 'Quote' AND RelatedListName = 'QuoteLineItems'
            LIMIT 1
        ];
        //System.debug('O quoteLineItem related list é: ' + quoteLineItemRelatedList);

        for (Quote cot : quoteMap.values()) {
            if (cot.Status == 'Cancelada') {
                cot.Valor_Final__c = null;
                cot.PagamentoFuturo__c = false;
                cot.VendaFutura__c = false;
                cot.DataVendaFutura__c = null;
                cot.DataPagamentoFuturo__c = null;
            }
        }
    }

    public static void syncValorFinalMidia(List<Quote> newQuotes, Map<Id, Quote> oldQuotesMap) {
        try {
            Id opportunityId;

            if (newQuotes != null && !newQuotes.isEmpty()) {
                opportunityId = newQuotes[0].OpportunityId;
            } else if (oldQuotesMap != null && !oldQuotesMap.isEmpty()) {
                opportunityId = oldQuotesMap.values()[0].OpportunityId;
            } else {
                return;
            }

            List<Quote> quotes = [
                SELECT Id, ValorTotalMidia__c, Name
                FROM Quote
                WHERE OpportunityId = :opportunityId AND (PagamentoFuturo__c = TRUE OR Sincronizado__c = TRUE)
            ];

            Decimal valorFinalMidia = 0;
            for (Quote quote : quotes) {
                valorFinalMidia += quote.ValorTotalMidia__c != null ? quote.ValorTotalMidia__c : 0;
                System.debug(quote.name + ': ' + quote.ValorTotalMidia__c);
            }

            Opportunity opportunity = new Opportunity(Id = opportunityId);
            opportunity.ValorFinalMidia__c = valorFinalMidia;
            update opportunity;

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception>> e.getMessage: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Exception>> e.getCause: ' + e.getCause());
            System.debug(LoggingLevel.ERROR, 'Exception>> e.getLineNumber: ' + e.getLineNumber());
            System.debug(LoggingLevel.ERROR, 'Exception>> e.getStackTraceString: ' + e.getStackTraceString());
        }
    }
}