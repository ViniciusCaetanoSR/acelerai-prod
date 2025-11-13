global without sharing class TeamsUserConsentHandlerController {
    global Boolean hasError {get; set;}
    public static TeamsOAuth_Response oauthOverride;

    global TeamsUserConsentHandlerController(ApexPages.StandardController controller){
    }

    global void contructorWithDML(){
        try {
        //captura os parametros a partir da url
            String teamsCode = ApexPages.currentPage().getParameters().get('code');
            System.debug('teamsCode: ' + teamsCode);
            String userId = ApexPages.currentPage().getParameters().get('state');
            System.debug('UserId: ' + userId);

            if (teamsCode == null || userId == null) {
                hasError = true;
            } else {
            //processa o retorno do processo de autenticação (isto é, troca o authorization-code pelo access-token)
                TeamsOAuth_Response teamsOAuthResponse = oauthOverride != null
                ? oauthOverride
                : TeamsOAuth_Provider.getAccessTokenByCode(teamsCode);
            //isso tudo resulta em um objeto com access_token, expires_in, refresh_token etc.
                System.debug('teamsOAuthResponse: ' + teamsOAuthResponse);
                
            //cria registro no obj log__c com a resposta
                // HttpRequestLog__c log = new HttpRequestLog__c();
                // log.Name = 'teamsOAuthResponse';                
                //String JsonMsg = JSON.serialize(teamsOAuthResponse);
                // log.ResponseBody__c = 'Body:  ' + JsonMsg;                
                //String codeAndUserId = 'code: ' + teamsCode + ' userId: ' + userId;
                // log.RequestBody__c = codeAndUserId;
                //insert log;

            // atualiza um usuario com os seus authorization-code e access-token               
                User userToUpdate = new User(
                    Id = userId,
                    TeamsConsentCode__c = teamsCode,
                    TeamsAccessToken__c = teamsOAuthResponse.access_token,
                    HasTeamsConsent__c = true,
                    TeamsTokenExpiresAt__c = teamsOAuthResponse.expires_in,
                    TeamsRefreshToken__c = teamsOAuthResponse.refresh_token
                );
                
                // if (teamsOAuthResponse.refresh_token != null) userToUpdate.teamsRefreshToken__c = teamsOAuthResponse.refresh_token;
                System.debug('teamsOAuthResponse refresh_token: ' + teamsOAuthResponse.refresh_token);
                System.debug('teamsOAuthResponse expires_in: ' + teamsOAuthResponse.expires_in);

                // if (teamsOAuthResponse.expires_in != null && teamsOAuthResponse.access_token != null) userToUpdate.teamsAccessTokenValid__c = System.now().addSeconds(teamsOAuthResponse.expires_in);
                // else userToUpdate.teamsAccessTokenValid__c = null;

                Database.SaveResult userResult = Database.update(userToUpdate);
                hasError = false;
            }
        } catch (Exception e) {
            System.debug('ERROR ON contructorWithDML: ' + e.getMessage());
            this.hasError = true;
        }
    }
}