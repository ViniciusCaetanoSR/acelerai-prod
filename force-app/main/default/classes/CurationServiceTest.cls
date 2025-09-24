@isTest
public class CurationServiceTest {
    @isTest
    static void testCreateCuration(){
        Account accountTest = VirtualTestData.createAccount('accountName');
        insert accountTest;

        Contact contactTest = VirtualTestData.createContact('lastName', accountTest.Id, 'test@example.com', '77673267632763');
        insert contactTest;

        Opportunity opportunity = VirtualTestData.createOpportunity(
            'opportunityName',
            accountTest.Id,
            '674867536768',
            'Financeiro',
            'clientType',
            Date.today().addDays(7),
            'Em Negociação'

        );

        opportunity.MonthlyInvestmentMedia_Content__c = 'Não Invisto';
        opportunity.Tipo_de_Cliente__C = 'Cliente final';
        opportunity.Ja_foi_anunciante__c = 'Não';
        opportunity.Veiculacao__c = 'Mídia On';
        opportunity.ClientsObjectiveWithAcelerai__c = 'Campanha de Lançamento';
        opportunity.WhatsYourRole__c = 'Analista';
        opportunity.QuandoPretendeAnunciar__c = 'Imediatamente';
        opportunity.CNPJ__c = '16534005000134';
        opportunity.ClientsObjectiveWithAcelerai__c = 'Campanha de Lançamento';
        opportunity.HaveCurrentlyAgency__c = 'Sim';
        opportunity.ContatoComprador__c = contactTest.Id;
        opportunity.ContatoFinanceiro__c = contactTest.Id;
        opportunity.ContatoJuridico__c = contactTest.Id;
        opportunity.ContatosMarketing__c = contactTest.Id;
        opportunity.Pol_tica_Comercial__c = 'Preço normal';
        opportunity.SaleType__c = 'Upsell';

        insert opportunity;

        Quote quote = VirtualTestData.createQuote(
            'QuoteName',
            opportunity.Id
        );

        quote.VendaFutura__c = true;
        quote.Sincronizado__c = true;
        quote.PagamentoFuturo__c = false;
        quote.DataVendaFutura__c = Date.today().addDays(-7);

        insert quote;

        Test.startTest();
        opportunity.StageName = 'Venda Futura';
        update opportunity;

        opportunity.StageName = 'Em Negociação';
        update opportunity;

        opportunity.StageName = 'Venda Futura';
        update opportunity;
        Test.stopTest();
    }

    @isTest
    static void testUpdateCuration(){
        Account accountTest = VirtualTestData.createAccount('accountName');
        insert accountTest;

        Contact contactTest = VirtualTestData.createContact('lastName', accountTest.Id, 'test@example.com', '77673267632763');
        insert contactTest;

        Opportunity opportunity = VirtualTestData.createOpportunity(
            'opportunityName',
            accountTest.Id,
            '674867536768',
            'Financeiro',
            'clientType',
            Date.today().addDays(7),
            'Em Negociação'

        );

        opportunity.MonthlyInvestmentMedia_Content__c = 'Não Invisto';
        opportunity.Tipo_de_Cliente__C = 'Cliente final';
        opportunity.Ja_foi_anunciante__c = 'Não';
        opportunity.Veiculacao__c = 'Mídia On';
        opportunity.ClientsObjectiveWithAcelerai__c = 'Campanha de Lançamento';
        opportunity.WhatsYourRole__c = 'Analista';
        opportunity.QuandoPretendeAnunciar__c = 'Imediatamente';
        opportunity.CNPJ__c = '16534005000134';
        opportunity.ClientsObjectiveWithAcelerai__c = 'Campanha de Lançamento';
        opportunity.HaveCurrentlyAgency__c = 'Sim';
        opportunity.ContatoComprador__c = contactTest.Id;
        opportunity.ContatoFinanceiro__c = contactTest.Id;
        opportunity.ContatoJuridico__c = contactTest.Id;
        opportunity.ContatosMarketing__c = contactTest.Id;
        opportunity.Pol_tica_Comercial__c = 'Preço normal';
        opportunity.SaleType__c = 'Upsell';

        insert opportunity;

        Quote quote = VirtualTestData.createQuote(
            'QuoteName',
            opportunity.Id
        );

        quote.VendaFutura__c = true;
        quote.Sincronizado__c = true;
        quote.PagamentoFuturo__c = false;
        quote.DataVendaFutura__c = Date.today().addDays(-7);

        insert quote;

        opportunity.StageName = 'Venda Futura';
        update opportunity;

        Test.startTest();
        opportunity.StageName = 'Perdido';
        update opportunity;
        Test.stopTest();
    }
}