public class QuoteLineItemTriggerHandler {
    public void beforeInsert(List<QuoteLineItem> newItems) {
    }

    public void beforeUpdate(List<QuoteLineItem> newItems, Map<Id, QuoteLineItem> oldItemsMap) {
    }

    public void afterInsert(List<QuoteLineItem> newItems) {
        syncValorTotalMidia(newItems, null);
    }

    public void afterUpdate(List<QuoteLineItem> newItems, Map<Id, QuoteLineItem> oldItemsMap) {
        syncValorTotalMidia(newItems, oldItemsMap);
    }

    public void afterDelete(Map<Id, QuoteLineItem> oldItemsMap) {
        syncValorTotalMidia(null, oldItemsMap);
    }

public void syncValorTotalMidia(List<QuoteLineItem> newItems, Map<Id, QuoteLineItem> oldItemsMap) {
    try {
        Id quoteId;
        
        // Identificar o QuoteId a partir de newItems ou oldItemsMap
        if (newItems != null && !newItems.isEmpty()) {
            quoteId = newItems[0].QuoteId;  // Usamos o primeiro item da lista para pegar o QuoteId
        } else if (oldItemsMap != null && !oldItemsMap.isEmpty()) {
            quoteId = oldItemsMap.values()[0].QuoteId;  // Usamos um dos itens deletados para pegar o QuoteId
        } else {
            return; // Se ambos forem nulos ou vazios, não há nada a fazer
        }

        // Buscar todos os QuoteLineItem dessa quote com ProductType__c == 'Mídia'
        List<QuoteLineItem> mediaItems = [
            SELECT TotalPrice
            FROM QuoteLineItem
            WHERE QuoteId = :quoteId AND ProductType__c = 'Mídia'
        ];

        // Calcular o total de 'Mídia'
        Decimal totalMidia = 0;
        for (QuoteLineItem item : mediaItems) {
            totalMidia += item.TotalPrice;
        }

        // Atualizar o campo ValorTotalMidia__c na Quote
        Quote quoteToUpdate = new Quote(Id = quoteId);
        quoteToUpdate.ValorTotalMidia__c = totalMidia;
        update quoteToUpdate;

        System.debug('Total de mídia recalculado: ' + totalMidia);

    } catch (Exception e) {
        // Tratamento de erros
        System.debug(LoggingLevel.ERROR, 'Exception>> e.getMessage: ' + e.getMessage());
        System.debug(LoggingLevel.ERROR, 'Exception>> e.getCause: ' + e.getCause());
        System.debug(LoggingLevel.ERROR, 'Exception>> e.getLineNumber: ' + e.getLineNumber());
        System.debug(LoggingLevel.ERROR, 'Exception>> e.getStackTraceString: ' + e.getStackTraceString());
    }
}

}