public class IntegrationSGCScoreService {

    public static void getScoreData(List<sgcRequest> requests) {
        // Para cada request no Flow, prepara os dados. Considera apenas o primeiro elemento, já que o Flow chama isso por registro.
        // 
        if(requests != null){
            
            sgcRequest request = requests[0]; // Flows normalmente passam uma lista de registros, mas aqui simplificamos para um único registro por vez.

            // Serializa o objeto request diretamente para JSON
            String requestBody = JSON.serialize(request);
    
            // Chama o método @future para fazer a integração de forma assíncrona
            getScoreDataToExternalAPI(requestBody);
            
        }
        
    }

    @future(callout=true)
    public static void getScoreDataToExternalAPI(String requestBody) {
        IntegrationSGC__c rec = IntegrationSGC__c.getValues('SGC_Score');
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(rec.Endpoint__c);
        
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-access-token', rec.Token__c);

        // Define o corpo da requisição com o JSON serializado recebido
        req.setBody(requestBody);

        // Envia a requisição
        Http http = new Http();
        System.debug('Sucess, requestBody: ' + JSON.serializePretty(requestBody));
        HttpResponse res = http.send(req);

        // Verifica a resposta
        if (res.getStatusCode() != 200) {
            System.debug('Failed to send data: ' + res.getBody());
            // Considerar lançar uma exceção ou outra forma de tratamento de erro adequado
        }
        else{
            System.debug('Sucess, return data: ' + res);
        }
    }

    // Define a classe interna que representa o formato de dados esperado pelo método invocável
    public class sgcRequest {
        @InvocableVariable
        public String type;
        @InvocableVariable
        public String document;
    }
    
}