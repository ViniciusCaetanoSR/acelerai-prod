@isTest
public without sharing class HomeChildKanbanCls_Test {
    
    @testSetup
    static void setupTestData() {

        LeadUtils.generateLeads(3);
        
        KanbanConfiguration__c config = new KanbanConfiguration__c(
            Name = 'Lead',
            For_Object__c = 'Lead',
            Group_By__c = 'Status',
            Exclude_From_Group_By__c = 'Histórico;Lead Score;Perdido',
            Filter_Field_1__c = 'Contato_BotSGC__c',
            FilterFieldValue1__c = 'false',
            Filter_Field_2__c = 'Status',
            FilterFieldValue2__c = 'Pré Cadastro',
            Filter_Field_3__c = 'CreatedDate',
            FilterFieldValue3__c = '>01/01/2025',
            Filter_Field_4__c = 'ValueScoreFinal__c',
            FilterFieldValue4__c = '>10.12',
            Kanban_For__c = 'Home',
            Child_Object__c = 'Lead',
            Fields_To_Show__c = 'Name;Email;Phone',
            Name_Field__c = 'Name',
            Record_Type__c = 'Varejo'
        );
        insert config;
        
        Account acc = new Account(
            Name = 'Test Account',
            CNPJ__c = '42113212000125',
            BillingStreet = 'Rua das Flores, 123',
            BillingCity = 'São Paulo',
            BillingState = 'SP',
            BillingPostalCode = '01001-000',
            BillingCountry = 'Brasil',
            CompanyName__c = 'Test Account 1');
        insert acc;
    }
    
    @isTest
    static void testKanban() {
        
        List<Lead> leads = [SELECT Id, Contato_BotSGC__c, Status, CreatedDate, ValueScoreFinal__c FROM Lead];
        
        Lead lead = leads[0];
        lead.Contato_BotSGC__c = false;
        lead.ValueScoreFinal__c = 12;
        update lead;
        
        List<String> objFields = new List<String>{'Name', 'Email', 'Phone'};
            List<String> excVal = new List<String>{'Histórico', 'Lead Score', 'Perdido'};
                
                Test.startTest();
        HomeChildKanbanUtil kanbanResult = HomeChildKanbanCls.getKanban(
            'Lead',
            objFields,
            'Status',
            null,
            null,
            excVal,
            'ValueScoreFinal__c',
            'Name',
            'Varejo',
            'Contato_BotSGC__c',
            'false',
            'Status',
            'Pré Cadastro',
            'CreatedDate',
            '>01/01/2025',
            'ValueScoreFinal__c',
            '>10.12'
        );
        Test.stopTest();
        
        System.assertNotEquals(null, kanbanResult, 'O resultado do Kanban não deveria ser nulo.');
        System.assertEquals(true, kanbanResult.isSuccess, 'O Kanban deveria ser gerado com sucesso.');
    }
    
    @isTest
    static void testSaveConfig() {
        KanbanConfiguration__c config = new KanbanConfiguration__c(
            For_Object__c = 'Account',
            Kanban_For__c = 'Home'
        );
        Test.startTest();
        String result = HomeChildKanbanCls.saveConfig(config);
        Test.stopTest();
        System.assertEquals('true', result, 'A configuração deveria ser salva com sucesso.');
    }
    
    @isTest
    static void testGetObjs() {
        Test.startTest();
        Map<String, List<HomeChildKanbanObjUtil>> objMap = HomeChildKanbanCls.getObjs();
        Test.stopTest();
        System.assertNotEquals(null, objMap, 'O mapa de objetos não deveria ser nulo.');
        System.assert(objMap.containsKey('standard'), 'Deveria conter objetos padrão.');
        System.assert(objMap.containsKey('custom'), 'Deveria conter objetos personalizados.');
    }
    
    @isTest
    static void testGetObjChilds() {
        Test.startTest();
        Map<String, List<HomeChildKanbanCObjUtil>> objChildMap = HomeChildKanbanCls.getObjChilds('Account');
        Test.stopTest();
        System.assertNotEquals(null, objChildMap, 'O mapa de filhos não deveria ser nulo.');
        System.assert(objChildMap.containsKey('standard'), 'Deveria conter filhos padrão.');
        System.assert(objChildMap.containsKey('custom'), 'Deveria conter filhos personalizados.');
    }
    
    @isTest
    static void testGetObjFlds() {
        Test.startTest();
        Map<String, List<HomeChildKanbanObjUtil>> objFldMap = HomeChildKanbanCls.getObjFlds('Account');
        Test.stopTest();
        System.assertNotEquals(null, objFldMap, 'O mapa de campos não deveria ser nulo.');
        System.assert(objFldMap.containsKey('all'), 'Deveria conter todos os campos.');
        System.assert(objFldMap.containsKey('groupBy'), 'Deveria conter campos agrupáveis.');
        System.assert(objFldMap.containsKey('sumBy'), 'Deveria conter campos somáveis.');
    }
    
    @isTest
    static void testGetPickVals() {
        Test.startTest();
        List<HomeChildKanbanObjUtil> pickVals = HomeChildKanbanCls.getPickVals('Industry', 'Account');
        Test.stopTest();
        System.assertNotEquals(null, pickVals, 'Os valores de picklist não deveriam ser nulos.');
        System.assert(pickVals.size() > 0, 'Deveria retornar valores de picklist.');
    }
    
    @isTest
    static void testUpdateRec() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        String result = HomeChildKanbanCls.updateRec(acc.Id, 'Name', 'Updated Account');
        Test.stopTest();
        System.assertEquals('true', result, 'O registro deveria ser atualizado com sucesso.');
        Account updatedAcc = [SELECT Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Updated Account', updatedAcc.Name, 'O campo Name deveria ter sido atualizado.');
    }
    
    @isTest
    static void testDeleteRec() {
        Account acc = new Account(
            Name = 'Test Account',
            CNPJ__c = '42113212000125',
            BillingStreet = 'Rua das Flores, 123',
            BillingCity = 'São Paulo',
            BillingState = 'SP',
            BillingPostalCode = '01001-000',
            BillingCountry = 'Brasil',
            CompanyName__c = 'Test Account 1');
        insert acc;
        Test.startTest();
        String result = HomeChildKanbanCls.deleteRec(acc);
        Test.stopTest();
        System.assertEquals('true', result, 'O registro deveria ser deletado com sucesso.');
        List<Account> deletedAcc = [SELECT Id FROM Account WHERE Id = :acc.Id];
        System.assertEquals(0, deletedAcc.size(), 'O registro deveria ter sido removido.');
    }
    
    @isTest
    static void testGetObjRecordTypes() {
        Test.startTest();
        Map<String, List<HomeChildKanbanObjUtil>> recordTypes = HomeChildKanbanCls.getObjRecordTypes('Account');
        Test.stopTest();
        System.assertNotEquals(null, recordTypes, 'O mapa de record types não deveria ser nulo.');
        System.assert(recordTypes.containsKey('recordTypes'), 'Deveria conter a chave recordTypes.');
        System.assert(recordTypes.get('recordTypes').size() > 0, 'Deveria retornar record types.');
    }
    
    @isTest
    static void testGetFilterFieldValue() {
        Test.startTest();
        Map<String, List<Map<String, String>>> result = HomeChildKanbanCls.getfilterFieldValue(
            'Account',
            'Name',
            'Test Account',
            null, null, null, null, null, null
        );
        Test.stopTest();
        System.assertNotEquals(null, result, 'O resultado do filtro não deveria ser nulo.');
        System.assert(result.containsKey('Account'), 'Deveria conter a chave Account.');
        System.assertEquals(1, result.get('Account').size(), 'Deveria retornar 1 registro.');
    }
}