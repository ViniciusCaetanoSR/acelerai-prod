public with sharing class ContactService {
    public static Contact createContact(String firstName, String lastName , Id accountId, String email, String phone) {
        Contact newContact = new Contact(
            FirstName = firstName,
            LastName = lastName, 
            AccountId = accountId, 
            Email = email, 
            Phone = phone
        );
        return newContact;
    }
}