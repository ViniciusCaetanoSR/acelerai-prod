public without sharing class TeamsHelper {
    public static Teams_API_Settings__mdt getApiMetadata(String apiName) {
        System.debug('[TEAMS Start] TeamsHelper');
        try{
            if(apiName != null){
                Teams_API_Settings__mdt apiSettings = [SELECT DeveloperName, Client_Id__c, Redirect_URI__c, Scope__c, Tenant_Id__c, OAuthURL__c, ClientSecret__c 
                    FROM Teams_API_Settings__mdt
                    WHERE DeveloperName = :apiName 
                    LIMIT 1
                ];
                System.debug('apiSettings: ' + apiSettings);

                return apiSettings;
            }
            return null;
        
        } catch(Exception e){
            System.debug('getApiMetadata: ' + e.getMessage());
            return new Teams_API_Settings__mdt();
        }
    }
}