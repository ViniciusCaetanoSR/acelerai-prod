@isTest
private class AutoConvertLeadsTest {
    
    @TestSetup
    static void makeData() {
        insert insertLead();      
    }
    
    @isTest
    static void testAssignLeads() {
        
        String cnpj = createRandomCNPJ();
        
        Test.startTest();
        
        Lead lead1 = [SELECT Id, FirstName, LastName, Email, Phone, Cnpj__c, CnpjNumeros__c, OwnerId, LetraScoreFinal__c FROM Lead LIMIT 1];
        AutoConvertLeads.convertLeads(new List<Lead>{lead1});
        Test.stopTest();
    }
    
    @isTest
    static void testConvertLeadsWithEmptyList() {
        Test.startTest();
        AutoConvertLeads.convertLeads(new List<Lead>());
        Test.stopTest();
        
    }
    
    @isTest
    static void testLogConversionError() {
    }
    
    static Lead insertLead() {
        
        String baseCNPJ = createRandomCNPJ();
        String phone = createRandomPhone();
        String uniqueId = String.valueOf(Math.abs(Crypto.getRandomLong()));
        String postalCode = String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 100000));
        postalCode = '30' + ('00000' + postalCode).substring(postalCode.length());
        
        List<String> streets = new List<String>{'Rua das Flores', 'Avenida Paulista', 'Rua dos Alfeneiros', 'Avenida Atlântica', 'Rua Augusta'};
            List<String> cities = new List<String>{'São Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Curitiba', 'Porto Alegre'};
                List<String> states = new List<String>{'SP', 'RJ', 'MG', 'PR', 'RS'};
                    List<String> neighborhoods = new List<String>{'Centro', 'Bela Vista', 'Copacabana', 'Savassi', 'Jardim Botânico'};
                        
                        String street = streets[Math.mod(Math.abs(Crypto.getRandomInteger()), streets.size())];
        String city = cities[Math.mod(Math.abs(Crypto.getRandomInteger()), cities.size())];
        String state = states[Math.mod(Math.abs(Crypto.getRandomInteger()), states.size())];
        String neighborhood = neighborhoods[Math.mod(Math.abs(Crypto.getRandomInteger()), neighborhoods.size())];
        String numberr = String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 1000));
        
        RecordType midiasRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Midias' AND SObjectType = 'Lead' LIMIT 1];
        
        Lead lead = new Lead (
            LastName = '<<Teste>> '+datetime.now(),
            Email = uniqueId+ '@test.com',
            Company = '<<Teste>> '+datetime.now(),
            Segmento__c = 'Financeiro',
            Phone = '+55319'+phone,
            City = city,
            Status = 'Pré Cadastro',
            HasBeenAdvertiser__c = 'Sim, os dois',
            Media_Monthly_Investment__c = 'Mais de 30k',
            IntendedAnnouncement__c = 'Mais de 3 meses',
            EmployeesAmount__c = 'Mais de 100',
            HasAgencyCurrently__c = 'Sim',
            Role_at_company__c = 'Fundador/Sócio',
            CompanyAge__c = 'Mais de 5 anos',
            CompanyUF__c = 'SP',
            WhatsYourInstagram__c = '@'+uniqueId,
            CNPJ__c = baseCNPJ,
            UTM_Campaign__c = 'salesforce',
            UTM_Content__c = 'test',
            UTM_Medium__c = 'cpc',
            UTM_Source__c = 'facebook',
            UTM_Term__c = 'stories',
            Street = street,
            PostalCode = postalCode,
            State = state,
            RecordTypeId = midiasRecordType.Id,
            Funil__c = 'Mídias Vendas'
        );
        
        return lead;
    }
    
    static String createRandomCNPJ() {
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
    
    static String createRandomPhone() {
        String phone = '';
        for (Integer u = 0; u < 8; u++) {
            Integer randomDigit = Math.mod(Math.abs(Crypto.getRandomInteger()), 10);
            phone += randomDigit;
        }
        return phone;
    }
}