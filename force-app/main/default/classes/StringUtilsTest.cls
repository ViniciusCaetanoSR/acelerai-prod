@isTest
public with sharing class StringUtilsTest {

    @isTest
    private static void shouldReturnNoSpecialChars () {
        String result = '';

        Test.startTest();
            result = StringUtils.noSpecialChar('Teste Car!ct*res Especiais');
        Test.stopTest();

        Assert.areEqual('Teste Carctres Especiais', result, 'Os caractéres especias não foram removidos');
    }

    @isTest
    private static void shoulReturnOnlyNumbers () {
        String result = '';

        Test.startTest();
            result = StringUtils.onlyNumbers('59.031.004/0001-80');
        Test.stopTest();

        Assert.areEqual('59031004000180', result, 'Não foram retornados apenas os números da String');
    }

    @isTest
    private static void shouldReturnEmptyStringForNoSpecialChar () {
        String result = 'kasljglkasjglkaj';

        Test.startTest();
            result = StringUtils.noSpecialChar('');
        Test.stopTest();

        Assert.areEqual('', result, 'A String não retornou vazia como deveria');   
    }

    @isTest
    private static void shouldReturnEmptyStringForOnlyNumbers () {
        String result = 'kasljglkasjglkaj';

        Test.startTest();
            result = StringUtils.onlyNumbers('');
        Test.stopTest();

        Assert.areEqual('', result, 'A String não retornou vazia como deveria'); 
    }
}