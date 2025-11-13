public with sharing class TeamsOAuth_Helper {

        public static Boolean isTokenExpired(User user) {
        if (String.isBlank(user.TeamsTokenExpiresAt__c)) {
            System.debug('~~ O campo TeamsTokenExpiresAt__c está nulo');
            return true;
        }
        try {
            Datetime expiration = Datetime.valueOfGmt(user.TeamsTokenExpiresAt__c);
            return expiration < System.now();
        } catch (Exception e) {
            System.debug('~~ Erro ao converter TeamsTokenExpiresAt__c: ' + e.getMessage());
            return true;
        }
    }

    public static Boolean handleTokenExpiration(User owner){ //true: valid-token; false: invalid
        if (Test.isRunningTest()) {
            return true;
        }

        if(owner == null){
            System.debug('~~ O handleTokenExpiration nao recebeu o ownerId/user');
            return false;
        }

        Boolean isExpired = isTokenExpired(owner);
        if (!isExpired){
            return true; //--TOKEN VÁLIDO--

        } else {
        /** --RENOVAÇÃO DO TOKEN-- */
            System.debug('~~ Token expirado para o usuario: ' + owner.Name + '. Renovando o token...');

            try{
                Map<String, Object> responseMap = TeamsOAuth_Provider.refreshToken(owner);

                if (responseMap == null || !responseMap.containsKey('access_token')) {
                    System.debug('Falha ao renovar token para usuário: ' + owner.Id);
                    return false;
                }

                String newAccessToken = (String) responseMap.get('access_token');
                String newRefreshToken = (String) responseMap.get('refresh_token');
                Integer expiresIn = (Integer) responseMap.get('expires_in');
                Datetime expiresAt = System.now().addSeconds(expiresIn);


                owner.TeamsAccessToken__c = newAccessToken;
                owner.TeamsRefreshToken__c = newRefreshToken;
                owner.TeamsTokenExpiresAt__c = expiresAt.formatGmt('yyyy-MM-dd HH:mm:ss');
                update owner;

                System.debug('Token renovado para usuário: ' + owner.Id + '. Nova expiração: ' + owner.TeamsTokenExpiresAt__c);
                return true;
            } catch (Exception e){
                System.debug('Erro ao tentar renovar token: ' + e.getMessage());
                return false;
            }
        }
    }   
}