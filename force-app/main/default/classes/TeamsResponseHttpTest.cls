@IsTest
private class TeamsResponseHttpTest {

    @IsTest
    static void testSuccessSerialization() {
        Map<String, Object> data = new Map<String, Object>{ 'key' => 'value' };
        String json = TeamsResponseHttp.success(data);
        System.assert(json.contains('"success":true'), 'Deve indicar sucesso');
        System.assert(json.contains('"error":false'), 'Não deve indicar erro');
        System.assert(json.contains('"key":"value"'), 'Deve conter os dados serializados');
    }

    @IsTest
    static void testSuccessObject() {
        Map<String, Object> data = new Map<String, Object>{ 'info' => 123 };
        TeamsResponseHttp response = TeamsResponseHttp.successObj(data);
        System.assertEquals(true, response.success);
        System.assertEquals(false, response.error);
        System.assertEquals(123, ((Map<String, Object>)response.dataMap).get('info'));
    }

    @IsTest
    static void testErrorSerialization() {
        List<String> errors = new List<String>{ 'Erro 1', 'Erro 2' };
        String json = TeamsResponseHttp.error(errors);
        System.assert(json.contains('"success":false'), 'Deve indicar falha');
        System.assert(json.contains('"error":true'), 'Deve indicar erro');
        System.assert(json.contains('Erro 1'), 'Deve conter mensagem de erro');
    }

    @IsTest
    static void testErrorObject() {
        List<String> errors = new List<String>{ 'Falha' };
        TeamsResponseHttp response = TeamsResponseHttp.errorObj(errors);
        System.assertEquals(false, response.success);
        System.assertEquals(true, response.error);
        System.assertEquals('Falha', response.errorList[0]);
    }

    @IsTest
    static void testErrorWithDataSerialization() {
        List<String> errors = new List<String>{ 'Problema' };
        Map<String, Object> data = new Map<String, Object>{ 'extra' => 'info' };
        String json = TeamsResponseHttp.error(errors, data);
        System.assert(json.contains('"success":false'));
        System.assert(json.contains('"error":true'));
        System.assert(json.contains('"extra":"info"'));
    }

    @IsTest
    static void testErrorWithDataObject() {
        List<String> errors = new List<String>{ 'Detalhe' };
        Map<String, Object> data = new Map<String, Object>{ 'code' => 500 };
        TeamsResponseHttp response = TeamsResponseHttp.errorObj(errors, data);
        System.assertEquals(false, response.success);
        System.assertEquals(true, response.error);
        System.assertEquals(500, ((Map<String, Object>)response.dataMap).get('code'));
        System.assertEquals('Detalhe', response.errorList[0]);
    }
}