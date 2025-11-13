public without sharing class TeamsOAuth_Provider {
    public TeamsOAuth_Response getAccessTokenByUser(Id userId){
        List<User> usersFound = [SELECT Id, TeamsConsentCode__c FROM User WHERE Id = :userId];

        if (usersFound.size() == 0) {
            System.debug('getAcessTokenByUser: Usuário não encontrado');
            return new TeamsOAuth_Response();
        }
        if (usersFound.get(0)?.TeamsConsentCode__c == null) {
            System.debug('Usuário não possui o código de consentimento');
            return new TeamsOAuth_Response();
        }
        
        return TeamsOAuth_Provider.getAccessTokenByCode(usersFound.get(0).TeamsConsentCode__c);
    }

    public static TeamsOAuth_Response getAccessTokenByCode(String code){
        System.debug('code: ' + code);
        //return new TeamsOAuth_Response();

        //constroi a url:
        Teams_API_Settings__mdt teamsApiFound = TeamsHelper.getApiMetadata('TeamsAPIMetadata');
        String url = teamsApiFound.OAuthURL__c + '/token';

        System.debug('getAccessTokenByCode url: ' + url);

        //monta a requisiçao para trocar o authorization-code pelo access-token, usando a url montada
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Length', 'application/x-www-form-urlencoded');

        //montar o corpo da requisição, c os parametros
        String body = 'client_id=' +  EncodingUtil.urlEncode(teamsApiFound.Client_Id__c, 'UTF-8');
        body += '&client_secret=' + EncodingUtil.urlEncode(teamsApiFound.ClientSecret__c, 'UTF-8');
        body += '&code=' + EncodingUtil.urlEncode(code, 'UTF-8');
        body += '&grant_type=authorization_code';
        body += '&redirect_uri=' + teamsApiFound.Redirect_URI__c;
        req.setBody(body);

        Http http = new Http();
        // return new TeamsOAuth_Response();
        if (!Test.isRunningTest()) {
            try{
                HTTPResponse res = http.send(req);
                System.debug('getAccessTokenByCode res.getBody(): ' + res.getBody());
                
                return TeamsOAuth_Response.parse(res.getBody());
            } catch(Exception e){
                System.debug('getAccessTokenByCode EXCEPTION message: ' + e.getMessage());
                //CRIAR registro de erro no obj log__c com a resposta                  
                LoggerUtility.createLogException(e, '', 'Método: getAccessTokenByCode');
                return new TeamsOAuth_Response();
            }
        } else {
            return new TeamsOAuth_Response();
        }
    }

    public static Map<String, Object> refreshToken(User user) {
        if (String.isBlank(user.TeamsRefreshToken__c)) {
            System.debug('~~ Usuário sem refresh-token.');
            user.addError('Não foi possível sincronizar com o Teams: usuário sem refresh token. Dê o consentimento ao Teams.');
        }

        try{
            Teams_API_Settings__mdt settings = [
                SELECT Client_Id__c, ClientSecret__c, Redirect_Uri__c, Tenant_Id__c
                FROM Teams_API_Settings__mdt
                WHERE DeveloperName = 'TeamsAPIMetadata' 
                LIMIT 1
            ];

            Map<String, String> bodyParams = new Map<String, String>{
                'client_id' => settings.Client_Id__c,
                'client_secret' => settings.ClientSecret__c,
                'grant_type' => 'refresh_token',
                'refresh_token' => user.TeamsRefreshToken__c,
                'redirect_uri' => settings.Redirect_Uri__c
            };

            String body = '';
            for (String key : bodyParams.keySet()) {
                body += key + '=' + EncodingUtil.urlEncode(bodyParams.get(key), 'UTF-8') + '&';
            }
            body = body.removeEnd('&');

            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://login.microsoftonline.com/' + settings.Tenant_Id__c + '/oauth2/v2.0/token');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody(body);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() != 200) {
                System.debug('Erro ao renovar token: ' + res.getBody());
                throw new AuraHandledException('Falha ao renovar token do Teams');
            }
            
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return responseMap;
        } catch (Exception e) {
            System.debug('Erro ao renovar token: ' + e.getMessage());
            LoggerUtility.createLogException(e, '', 'Método: refreshToken');
            return null;
        }
    }
}