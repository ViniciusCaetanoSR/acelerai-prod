public with sharing class VirtualTestData {

    private static Map<String, Schema.RecordTypeInfo> opportunityRecordTypesMap = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();


    private static final List<Integer> contactNumbers = new List<Integer> { 
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
        21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40
    };  

    public static Account createAccount(String accountName) {
        return new Account(
            Name = accountName, 
            SocialMedia_website__c = 'Social Media Test', 
            CompanyName__c = 'CTest', 
            Phone = '+5551982347754', 
            TypeIntermediary__c = 'Agência',
            CNPJ__c = '09.877.750/0001-10',
            BillingStreet = 'Street',
            BillingCity = 'City',
            BillingCountry = 'Country',
            BillingState = 'AC',
            BillingPostalCode = '12345',
            Tipodeintermediador__c = 'Agência'
        );
    }

    public static Opportunity createOpportunity(
        String opportunityName, 
        Id accountId, 
        String phone, 
        String accountSegment, 
        String clientType, 
        Date closeDate, 
        String stageName
    ) {
        return createOpportunity(opportunityName, accountId, phone, accountSegment, clientType, closeDate, stageName, null);
    }

    public static Opportunity createOpportunity(
        String opportunityName, 
        Id accountId, 
        String phone, 
        String accountSegment, 
        String clientType, 
        Date closeDate, 
        String stageName, 
        String opportunityRecordTypeName
    ) {

        Integer randomIndex = (Integer) Math.floor(Math.random() * contactNumbers.size());

        Contact allContacts = createContact(
            'All Contact Test ' + contactNumbers[randomIndex], 
            accountId, 
            'email@test.com' + contactNumbers[randomIndex], 
            '+555198178224' + contactNumbers[randomIndex]
        );

        insert allContacts;

        return new Opportunity(
            AccountId = accountId, 
            Agencia__c = accountId,
            ClientsObjectiveWithAcelerai__c = 'Campanha Institucional',
            CloseDate = closeDate, 
            CloseDateEstimated__c = Datetime.now(),
            ContatoComprador__c = allContacts.Id,
            ContatoFinanceiro__c = allContacts.Id,
            ContatoJuridico__c = allContacts.Id,
            ContatosMarketing__c = allContacts.Id,
            HaveCurrentlyAgency__c = 'Não',
            Ja_foi_anunciante__c = 'Não',
            MonthlyInvestmentMedia_Content__c = 'Não Invisto',
            Name = opportunityName, 
            PaymentLink_sendingDate__c = Date.today(),
            Pol_tica_Comercial__c = '1 mês a mais de direito de imagem',
            QuandoPretendeAnunciar__c = 'Imediatamente',
            RecordTypeId = opportunityRecordTypeName != null ? opportunityRecordTypesMap.get(opportunityRecordTypeName).getRecordTypeId() : opportunityRecordTypesMap.get('Varejo').getRecordTypeId(),
            SaleType__c = 'Cliente novo',
            Segmento__c = accountSegment, 
            StageName = stageName,
            StateYourCompany__c = 'AC',
            Telefone__c = phone, 
            Telefone1__c = phone,
            Tipo_de_cliente__c = clientType, 
            Veiculacao__c = 'Mídia On',
            WhatsYourInstagram__c = '@_teste',
            WhatsYourRole__c = 'Gerente'

        );
    }

    public static Quote createQuote(String quoteName, Id opportunityId) {
        return new Quote(Name = quoteName, OpportunityId = opportunityId, CampaignAmount__c = 1234);
    }

    public static Product2 createProduct(String productName, String productType) {
        return new Product2(Name = productName, Tipo__c = productType, IsActive = true);
    }

    public static Pricebook2 createPricebook(String pricebookName) {
        return new Pricebook2(Name = pricebookName, IsActive = true);
    }

    public static PriceBookEntry createPriceBookEntry(Id productId, Id pricebookId, Decimal unitPrice) {
        return new PriceBookEntry(
            Product2Id = productId,
            Pricebook2Id = pricebookId,
            UnitPrice = unitPrice,
            IsActive = true
        );
    }

    public static QuoteLineItem createQuoteLineItem(Quote quote, Id productId, PriceBookEntry pricebook) {
        return createQuoteLineItem(quote, null, pricebook, productId);
    }

    public static QuoteLineItem createQuoteLineItem(Quote quote, Product2 product, PriceBookEntry pricebook, Id productId) {
        return new QuoteLineItem(
            QuoteId = quote.Id,
            Product2Id = product == null ? productId : product.Id,
            PricebookEntryId = pricebook.Id,
            Quantity = 10,
            UnitPrice = 10
        );
    }

    public static OpportunityLineItem createOpportunityLineItem (Opportunity opportunity, Id productId, PriceBookEntry pricebook) {
        return createOpportunityLineItem(opportunity, null, pricebook, productId);
    }

    public static OpportunityLineItem createOpportunityLineItem(Opportunity opportunity, Product2 product, PriceBookEntry pricebook, Id productId) {
        return new OpportunityLineItem(
            OpportunityId = opportunity.Id,
            Product2Id = product == null ? productId : product.Id,
            PricebookEntryId = pricebook.Id,
            Quantity = 10,
            UnitPrice = 10
        );
    }

    public static Lead createLead(String lastName, String leadStatus, String company, String email, String phone) {
        return new Lead(
            LastName = lastName,
            Status = leadStatus,
            Company = company,
            Email = email,
            Phone = phone,
            HasBeenAdvertiser__c = 'Sim, apenas mídia on',
            HasAgencyCurrently__c = 'Sim',
            Media_Monthly_Investment__c = 'Entre 11k - 30k',
            Role_at_company__c = 'Diretor',
            IntendedAnnouncement__c = 'Entre 1 e 3 meses',
            CompanyAge__c = 'Menos de 1 ano',
            EmployeesAmount__c = '50 - 100',
            CompanyUF__c = 'AP',
            CNPJ__c = '09.877.750/0001-10',
            City = 'Cidade Test'
        );  
    }

    public static Contact createContact(String lastName, Id accountId, String email, String phone) {
        return new Contact(
            LastName = lastName,
            AccountId = accountId,
            Email = email,
            Phone = phone
        );
    }

    public static Case createCase(Id accountId, Id OpportunityId, String caseStatus) {
        return new Case(
            AccountId = accountId,
            Id_da_Oportunidade__c = OpportunityId,
            Status = caseStatus,
            Origin = 'Email'
        );
    }
}