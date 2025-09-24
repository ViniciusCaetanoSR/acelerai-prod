public with sharing class LeadSelector {
  public static List<lead> selectLeadMetaIntegration(List<Id> leadIds) {
    return [
        SELECT Id, 
        Email, 
        Phone, 
        Status, 
        fbclid__c, 
        Metalead_id__c, 
        FirstName, 
        LastName, 
        Address, 
        City, 
        CnpjNumeros__c, 
        Cnpj__c, 
        Company, 
        CompanyAge__c, 
        CompanyUF__c, 
        ConvertedAccountId,
        ConvertedContactId, 
        ConvertedOpportunityId, 
        ConvertedDate, 
        Country, 
        CreatedDate, 
        EmployeesAmount__c, 
        EntryAttempts__c, 
        HasAgencyCurrently__c, 
        HasBeenAdvertiser__c, 
        IntendedAnnouncement__c, 
        LeadId__c,
        Media_Monthly_Investment__c, 
        Motivo_da_Perda__c, 
        Name, 
        NumberOfEmployees, 
        Role_at_company__c, 
        Segmento__c, 
        Utm_campaign__c,
        Utm_source__c,
        Utm_medium__c, 
        Utm_term__c,
        Utm_content__c,
        website__c,
        WhatsYourInstagram__c
        FROM Lead 
        WHERE Id IN :leadIds
            
    ];
    
  }
}