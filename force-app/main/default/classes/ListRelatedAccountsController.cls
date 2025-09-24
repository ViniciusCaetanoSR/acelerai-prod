public with sharing class ListRelatedAccountsController {
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getRelatedAccounts(Id accountId) {
        if (accountId == null) {
            return new List<Account>();
        }

        List<Account> relatedAccounts = new List<Account>();

        Account childAccount = [
            SELECT Id, Name, ParentId 
            FROM Account 
            WHERE Id = :accountId 
            LIMIT 1
        ];

        if (childAccount.ParentId != null) {
            Account parentAccount = [
                SELECT Id, Name, OwnerId, Owner.Name, Phone, CNPJ__c 
                FROM Account 
                WHERE Id = :childAccount.ParentId 
                LIMIT 1
            ];
            relatedAccounts.add(parentAccount);
        } else {
            List<Account> childAccounts = [
                SELECT Id, Name, OwnerId, Owner.Name, Phone, CNPJ__c 
                FROM Account 
                WHERE ParentId = :accountId
            ];
            relatedAccounts.addAll(childAccounts);
        }

        return relatedAccounts;
    }
}