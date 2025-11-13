public without sharing class TeamsEventQueueable implements Queueable, Database.AllowsCallouts{
    private Id eventId;

    public TeamsEventQueueable(Id eventId) { 
        this.eventId = eventId; 
    }

    public void execute(QueueableContext qc){
        Event ev = [SELECT Id, Subject, StartDateTime, EndDateTime, OwnerId, TeamsEventId__c, TeamsJoinURL__c, TeamsOnlineMeetingId__c, TeamsMeetingId__c, ProcessedByTeams__c FROM Event             
            WHERE Id = :eventId LIMIT 1
        ];
        User owner = [SELECT Id, Name, TeamsAccessToken__c, TeamsConsentCode__c, TeamsRefreshToken__c, HasTeamsConsent__c , TeamsTokenExpiresAt__c 
        FROM User
            WHERE Id = :ev.OwnerId LIMIT 1
        ];

        if(owner.HasTeamsConsent__c){
            Boolean validAccessToken = TeamsOAuth_Helper.handleTokenExpiration(owner);
            
            if (validAccessToken) {
                if (String.isBlank(ev.TeamsEventId__c) && ev.ProcessedByTeams__c == false) { 
                    if (!Test.isRunningTest()) {
                        System.enqueueJob(new TeamsCreateEventQueueable(ev.Id, owner.TeamsAccessToken__c));
                        System.debug('Enfilou job para CRIAR evento no Teams: ' + ev.Subject);
                    }
                } else {
                    if (!Test.isRunningTest()) {
                        System.enqueueJob(new TeamsUpdateEventQueueable(ev.Id, owner.TeamsAccessToken__c));
                        System.debug('Enfilou o job para ATUALIZAR evento no Teams: ' + ev.Subject);
                    }
                } 
            } else {
                System.debug('Token inválido para o usuário: ' + owner.Id);
            }
        } else {
            System.debug('Usuário sem consentimento: ' + owner.Id);
        }        
    }
}