trigger CaseAureaTrigger on Case (after update, after insert, Before insert, Before update) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            List<Id> caseIds = new List<Id>();

            for (Case caso : Trigger.new) {
                caseIds.add(caso.Id);
            }
            if(!caseIds.isEmpty()){
                IntegrationAureaService.buscarEnviarDados(caseIds);
            }
        }
    }
}