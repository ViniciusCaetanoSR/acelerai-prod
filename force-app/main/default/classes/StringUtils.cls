public with sharing class StringUtils {
    
    private static List<String> dddsBR = new List<String> {
        '11','12','13','14','15','16','17','18','19','21','22', '24','27','28',
        '31','32','33', '34','35','37','38','41','42','43','44','45','46','47',
        '48','49','51','53','54','55','61','62','63','64','65','66','67','68',
        '69','71','73','74','75','77','79','81','82','83','84','85','86','87',
        '88','89','91','92','93','94','95','96','97','98','99'
    };

    public static String noSpecialChar(String str) {

        if(String.isBlank(str))
            return '';

        return str.replaceAll('[^ a-zA-Z0-9 \\ s +]', '');
    }

    public static String onlyNumbers(String str) {

        if(String.isBlank(str))
            return '';

        return str.replaceAll('[^0-9]','');
    }

    public static String validatePhoneNumber (String phoneNumber, SObject objectToAddError) {

        if (phoneNumber.length() < 10)
            objectToAddError.addError('Número sem DDD');

        String formattedNumber = StringUtils.formatPhoneNumber(phoneNumber);

        if (formattedNumber.startsWith('+55') && !dddsBR.contains(formattedNumber.substring(3, 5)))
            objectToAddError.addError('DDD Inválido');
                                
        if (formattedNumber.length() > 16)
            objectToAddError.addError('Verifique quantidade de digitos do número');

        return formattedNumber;
    }

    private static String formatPhoneNumber(String phoneNumber) {
        phoneNumber = phoneNumber.replaceAll('\\s+', '').replaceAll('[^0-9+]', '');
        phoneNumber = phoneNumber.replaceFirst('^0', '');

        if (phoneNumber.startsWith('55') && (phoneNumber.length() >= 12 || phoneNumber.length() == 13)) 
            return '+' + phoneNumber;

        if (!phoneNumber.startsWith('+55') && (phoneNumber.length() >= 10 || phoneNumber.length() == 11)) 
            return '+55' + phoneNumber;
        
        return phoneNumber;
    }
}