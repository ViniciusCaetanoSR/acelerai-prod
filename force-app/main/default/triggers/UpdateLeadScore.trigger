trigger UpdateLeadScore on Lead (Before insert, Before update, after insert, after update) {
    
    if (Trigger.isBefore && Trigger.isInsert) {
        // Chamar o método futuro para atribuir leads usando regras de atribuição
        UpdateLeadScoreHandler.handleLeadScoreUpdate(Trigger.new, Trigger.oldMap);
    }
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        // Chamar o método futuro para atribuir leads usando regras de atribuição
        UpdateLeadScoreHandler.handleLeadScoreUpdate(Trigger.new, Trigger.oldMap);
    }
    
}