public class UpdateLeadScoreHandler {
    
    public static void handleLeadScoreUpdate(List<Lead> newLeads, Map<Id, Lead> oldLeadMap) {
        List<Lead> workLeads = new List<Lead>();
        List<Lead> listCallScore = new List<Lead>();

        Set<Id> leadIds = new Set<Id>();
        for (Lead newLead : newLeads) {
            if(Trigger.isInsert) {
                workLeads.add(newLead);
                if(newLead.CNPJ__c != null){
                    listCallScore.add(newLead);
                }
            } else {
                Lead oldLead = oldLeadMap.get(newLead.Id);
                if (oldLead.CompanyAge__c != newLead.CompanyAge__c ||
                    oldLead.Role_at_company__c != newLead.Role_at_company__c ||
                    oldLead.EmployeesAmount__c != newLead.EmployeesAmount__c ||
                    oldLead.IntendedAnnouncement__c != newLead.IntendedAnnouncement__c ||
                    oldLead.HasBeenAdvertiser__c != newLead.HasBeenAdvertiser__c ||
                    oldLead.Media_Monthly_Investment__c != newLead.Media_Monthly_Investment__c ||
                    oldLead.ScoreFinanceiro__c != newLead.ScoreFinanceiro__c) {
                    workLeads.add(newLead);
                }
                
                if (!newLead.byPassGetScoreFin__c && (oldLead.CNPJ__c  != newLead.CNPJ__c) ){
                    String cnpj = newLead.CNPJ__c;
                    //newLead.CNPJ__c = cnpj.replace('.','').replace('/','').replace('-','');
                    listCallScore.add(newLead);
                }
                
                if (newLead.byPassGetScoreFin__c) {
                    newLead.byPassGetScoreFin__c = false;
                }
                
            }
        }

        Map<String, Decimal> scoreMap = new Map<String, Decimal>();
        for (Score__mdt score : [SELECT Score__c, Respostas__c FROM Score__mdt]) {
            scoreMap.put(score.Respostas__c, score.Score__c);
        }

        for (Lead lead : workLeads) {
            Double scoreTotal = 0;

            if(lead.CompanyAge__c != null && scoreMap.containsKey(lead.CompanyAge__c)) {
                scoreTotal += scoreMap.get(lead.CompanyAge__c);
            }
            if(lead.Role_at_company__c != null && scoreMap.containsKey(lead.Role_at_company__c)) {
                scoreTotal += scoreMap.get(lead.Role_at_company__c);
            }
            if(lead.EmployeesAmount__c != null && scoreMap.containsKey(lead.EmployeesAmount__c)) {
                scoreTotal += scoreMap.get(lead.EmployeesAmount__c);
            }
            if(lead.IntendedAnnouncement__c != null && scoreMap.containsKey(lead.IntendedAnnouncement__c)) {
                scoreTotal += scoreMap.get(lead.IntendedAnnouncement__c);
            }
            if(lead.HasBeenAdvertiser__c != null && scoreMap.containsKey(lead.HasBeenAdvertiser__c)) {
                scoreTotal += scoreMap.get(lead.HasBeenAdvertiser__c);
            }
            if(lead.Media_Monthly_Investment__c != null && scoreMap.containsKey(lead.Media_Monthly_Investment__c)) {
                scoreTotal += scoreMap.get(lead.Media_Monthly_Investment__c);
            }
            lead.Score__c = scoreTotal;
        }

        List<AtribuicaoLeads__mdt> atribuicaoLeadsList = [
            SELECT 
                IdFila__c, 
                MaxScore__c, 
                MaxScoreFinanceiro__c,
                MaxScoreFinal__c, 
                MinScore__c, 
                MinScoreFinanceiro__c,
                MinScoreFinal__c, 
                Letter__c, 
                Value__c, 
                ValueScoreFin__c  
            FROM AtribuicaoLeads__mdt ORDER BY MinScoreFinal__c ASC
        ];
    
        List<RoletaCargos__mdt> roletaCargosList = [
            SELECT 
                Cargos__c, 
                Score__c,
	            UsuarioPadrao__c
            FROM RoletaCargos__mdt
        ];
        
        Map<String, String> defaultUserByScoreMap = new Map<String, String>();
        
        for (RoletaCargos__mdt currentRoleta : roletaCargosList) {
            if (!defaultUserByScoreMap.containsKey(currentRoleta.Score__c))
                defaultUserByScoreMap.put(currentRoleta.Score__c, currentRoleta.UsuarioPadrao__c);
        }

        Set<String> setDeveloperNameCargos = LeadService.populateRolesMap(roletaCargosList);
        
        List<User> userList = [
            SELECT 
                Id, 
                Name, 
                UserRole.DeveloperName 
            FROM User 
            WHERE UserRole.DeveloperName =: setDeveloperNameCargos AND IsActive = true
        ];

        Set<Id> userIds = new Set<Id>();  

        Map<String, List<User>> mapScoreByUser = LeadService.populateUsersByScoreMap(roletaCargosList, userList, userIds);
        Map<Id, Integer> oppsByUserMap = LeadService.populateUserOppsMap(userIds, userList);

        handleLeadQueereUpdate(workLeads, atribuicaoLeadsList, mapScoreByUser, oppsByUserMap, defaultUserByScoreMap);
    
        
        if(!listCallScore.isEmpty()) {
            handleGetLeadScoreInSGC(listCallScore);
        }
    }
    
    public static void handleLeadQueereUpdate(
        List<Lead> workLeads, 
        List<AtribuicaoLeads__mdt> atribuicaoLeadsList, 
        Map<String, List<User>> mapScoreByUser, 
        Map<Id, Integer> oppsByUserMap,
    	Map<String, String> defaultUserByScoreMap
    ) {
        for (Lead lead : workLeads) {
            Double scoreTotal = 0;
            for(AtribuicaoLeads__mdt atribuicao : atribuicaoLeadsList){
                
                if(lead.Score__c != null && lead.Score__c > 0) {
                    
                    if(atribuicao.MaxScore__c >= lead.Score__c && atribuicao.MinScore__c <= lead.Score__c ){
                        lead.LetraScore__c = atribuicao.Letter__c;
                        lead.ValueScore__c = atribuicao.Value__c ;
                        lead.ValueScoreFinal__c = atribuicao.Value__c;
                        lead.LetraScoreFinal__c = atribuicao.Letter__c;
                        lead.Status = 'Aplicação';
                        if(lead.ConversaoMktCloud__c){
                            //lead.OwnerId = getUserRoleta(lead, mapScoreByUser, oppsByUserMap, defaultUserByScoreMap);
                        }
                     }
                }

                /*
                if(lead.ScoreFinanceiro__c  != null && lead.ScoreFinanceiro__c  > 0) {
                    if(atribuicao.MaxScoreFinanceiro__c  >= lead.ScoreFinanceiro__c && atribuicao.MinScoreFinanceiro__c  <= lead.ScoreFinanceiro__c ){
                        lead.LetraScoreFinanceiro__c  = atribuicao.Letter__c;
                        lead.ValueScoreFinanceiro__c  = atribuicao.ValueScoreFin__c;
                    }
                }
                
                if((lead.ValueScore__c != null && lead.ValueScoreFinanceiro__c != null) && (lead.ValueScore__c  > 0 && lead.ValueScoreFinanceiro__c > 0)) {
                    lead.ValueScoreFinal__c = ((lead.ValueScore__c + lead.ValueScoreFinanceiro__c) / 2);
                    
                    if(lead.ValueScoreFinal__c != null && lead.ValueScoreFinal__c  > 0) {                                                
                        if(atribuicao.MaxScoreFinal__c >= lead.ValueScoreFinal__c && atribuicao.MinScoreFinal__c <= lead.ValueScoreFinal__c){
                            lead.LetraScoreFinal__c = atribuicao.Letter__c;
                        }
                    }
                    
                }*/

            }
        }
    }

    public static String getUserRoleta(
        Lead lead, 
        Map<String, List<User>> mapScoreByUser, 
        Map<Id, Integer> oppsByUserMap, 
        Map<String, String> defaultUserByScoreMap
   	) {
        
        List<User> usersForScore = mapScoreByUser.get(lead.LetraScoreFinal__c);
        
        String userIdToReturn;
        
        if (usersForScore == null || usersForScore.isEmpty()) {
            userIdToReturn = defaultUserByScoreMap.get(lead.LetraScoreFinal__c);
            return userIdToReturn;
        }

        Integer randomIndex = (Integer) Math.floor(Math.random() * usersForScore.size());
        userIdToReturn = usersForScore[randomIndex].Id;
        
		Boolean shouldLoadBalance = false;
        
        if (shouldLoadBalance) {
            Integer mainOpportunityCount = oppsByUserMap.get(usersForScore.get(0).Id);
        
            for (User currentUser : usersForScore) {
                Integer oppQuantityForUser = oppsByUserMap.get(currentUser.Id);
    
                if (oppQuantityForUser <= mainOpportunityCount) {
                    mainOpportunityCount = oppQuantityForUser;
                    userIdToReturn = currentUser.Id;
                }        
            }
        }
        
        return userIdToReturn;
    }
    
    public static void handleGetLeadScoreInSGC(List<Lead> workLeads) {
        
        List<IntegrationSGCScoreService.sgcRequest> requests = new List<IntegrationSGCScoreService.sgcRequest>();
        for(Lead lead : workLeads){
            IntegrationSGCScoreService.sgcRequest request = new IntegrationSGCScoreService.sgcRequest();
            request.type = 'CNPJ';
            request.document = lead.CNPJ__c;
            
            requests.add(request);
        }
        // Envia os dados para o SGC
        //IntegrationSGCScoreService.getScoreData(requests);
        
    }

}