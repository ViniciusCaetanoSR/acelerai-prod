public without sharing class TeamsGetUserConsentController {
    public static Teams_API_Settings__mdt metadataOverride; //usado para permitir os unit tests

    @AuraEnabled
    public static String buildUserConsentUrl() { 

        try {
            Teams_API_Settings__mdt teamsApiFound = metadataOverride != null
                ? metadataOverride
                : TeamsHelper.getApiMetadata('TeamsAPIMetadata');
            String url = 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize';
            url += '?client_id=' + EncodingUtil.urlEncode(teamsApiFound.Client_Id__c, 'UTF-8');
            url += '&response_type=code';
            url += '&redirect_uri=' + EncodingUtil.urlEncode(teamsApiFound.Redirect_URI__c, 'UTF-8'); //depois: por redirect chumbado
            url += '&response_mode=form_post';
            url += '&scope=' + teamsApiFound.Scope__c;
            url += '&state=' + UserInfo.getUserId();
            
            System.debug('buildUserconsent: ' + TeamsResponseHttp.success(new Map<String, String>{
                'url' => url
            }));
            
            System.debug('url: ' + url);
            return TeamsResponseHttp.success(new Map<String, String>{
                'url' => url
            });
        } catch (Exception e) {
            System.debug('buildUserconsent [error]: ' + TeamsResponseHttp.error(new List<String>{e.getMessage()}));
            return TeamsResponseHttp.error(new List<String>{e.getMessage()});
        }
    }
}