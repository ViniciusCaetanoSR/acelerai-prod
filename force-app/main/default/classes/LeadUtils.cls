public class LeadUtils {

    /*
    LeadUtils.removeTodayTestRecords();
    LeadUtils.generateLeads(1);
    LeadUtils.generateMarketingLeads(1);
    LeadUtils.generateMarketingLeadsWebsiteUrl();
    */

    /**
     * Gera e insere um número especificado de registros de Lead com dados aleatórios.
     * Os leads gerados possuem informações básicas como nome, email, telefone e endereço.
     * @param numberOfRecords O número de registros de Lead a serem gerados e inseridos.
     */
    public static void generateLeads(Integer numberOfRecords) {

        List<Lead> leads = new List<Lead>();

        leads = createLead(numberOfRecords);

        insert leads;
    }

    public static void generateMarketingLeads(Integer numberOfRecords) {
        
        List<Lead> leads = new List<Lead>();

        leads = createLead(numberOfRecords);

        for(Lead lead : leads){
            lead.Funil__c = 'Mídias Vendas';
            lead.WebSite__c = 'www.sbtacelerai.com.br/';
        }

        insert leads;
    }

    public static void generateMarketingLeadsWebsiteUrl(Integer numberOfRecords) {
        
        List<Lead> leads = new List<Lead>();

        leads = createLead(numberOfRecords);

        for(Lead lead : leads){
            lead.WebSite__c = 'lp.acelerai.com.br/salesforce';
        }

        insert leads;
    }

    public static void generateInactiveBaseLeads(Integer numberOfRecords) {
        
        List<Lead> leads = new List<Lead>();

        leads = createLead(numberOfRecords);

        for(Lead lead : leads){
            lead.referencia_base_antiga_lead__c = 'Base Inativa';
        }
        
        insert leads;
    }

    public static List<Lead> createLead(Integer numberOfRecords) {

        List<Lead> leads = new List<Lead>();
        List<String> streets = new List<String>{'Rua das Flores', 'Avenida Paulista', 'Rua dos Alfeneiros', 'Avenida Atlântica', 'Rua Augusta'};
        List<String> cities = new List<String>{'São Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Curitiba', 'Porto Alegre'};
        List<String> states = new List<String>{'SP', 'RJ', 'MG', 'PR', 'RS'};
        List<String> neighborhoods = new List<String>{'Centro', 'Bela Vista', 'Copacabana', 'Savassi', 'Jardim Botânico'};

        for (Integer i=0; i < numberOfRecords; i++){
            
            String baseCNPJ = createRandomCNPJ();
            String phone = createRandomPhone();
            String uniqueId = String.valueOf(Math.abs(Crypto.getRandomLong()));
            String postalCode = String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 100000));
            String street = streets[Math.mod(Math.abs(Crypto.getRandomInteger()), streets.size())];
            String city = cities[Math.mod(Math.abs(Crypto.getRandomInteger()), cities.size())];
            String state = states[Math.mod(Math.abs(Crypto.getRandomInteger()), states.size())];
            String neighborhood = neighborhoods[Math.mod(Math.abs(Crypto.getRandomInteger()), neighborhoods.size())];
            String numberr = String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 1000));

            postalCode = '30' + ('00000' + postalCode).substring(postalCode.length());
            
            Lead lead = new Lead (
                LastName = '**Test** '+ uniqueId +' - '+datetime.now(),
                Email = uniqueId+ '@test.com',
                Segmento__c = 'Financeiro',
                WhatsYourInstagram__c = '@'+uniqueId,
                State = state,
                City = city,
                Phone = '+55319'+phone
            );
            
            leads.add(lead);
        }
        return leads;
    }

    public static void removeTodayTestRecords() {

        Date today = Date.today();
        
        List<Account> accountsToDelete = [SELECT Id FROM Account WHERE CreatedDate = TODAY AND Name like '%<<Teste>>%'];
        
        List<Contact> contactsToDelete = [SELECT Id FROM Contact WHERE CreatedDate = TODAY AND Name like '%<<Teste>>%'];
        
        List<Opportunity> opportunitiesToDelete = [SELECT Id FROM Opportunity WHERE CreatedDate = TODAY AND Name like '%<<Teste>>%'];
        
        List<Lead> leadsToDelete = [SELECT Id FROM Lead WHERE CreatedDate = TODAY AND Name like '%<<Teste>>%'];

        if (!opportunitiesToDelete.isEmpty()) {
            delete opportunitiesToDelete;
        }

        if (!contactsToDelete.isEmpty()) {
            delete contactsToDelete;
        } 

        if (!accountsToDelete.isEmpty()) {
            delete accountsToDelete;
        }

        if (!leadsToDelete.isEmpty()) {
            delete leadsToDelete;
        } 
    }

    public static String createRandomCNPJ() {
        String baseCNPJ = '';
        for (Integer i = 0; i < 12; i++) {
            baseCNPJ += String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 10));
        }
        Integer[] weights1 = new Integer[] {5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2};
            Integer[] weights2 = new Integer[] {6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2};
                
                Integer sum1 = 0;
        for (Integer i = 0; i < weights1.size(); i++) {
            sum1 += Integer.valueOf(baseCNPJ.substring(i, i + 1)) * weights1[i];
        }
        
        Integer mod1 = Math.mod(sum1, 11);
        Integer firstDigit = (mod1 < 2) ? 0 : 11 - mod1;
        baseCNPJ += String.valueOf(firstDigit);
        
        Integer sum2 = 0;
        for (Integer i = 0; i < weights2.size(); i++) {
            sum2 += Integer.valueOf(baseCNPJ.substring(i, i + 1)) * weights2[i];
        }
        
        Integer mod2 = Math.mod(sum2, 11);
        Integer secondDigit = (mod2 < 2) ? 0 : 11 - mod2;
        return baseCNPJ + String.valueOf(secondDigit);
    }
    
    public static String createRandomPhone() {
        String phone = '';
        for (Integer u = 0; u < 8; u++) {
            Integer randomDigit = Math.mod(Math.abs(Crypto.getRandomInteger()), 10);
            phone += randomDigit;
        }
        return phone;
    }
}