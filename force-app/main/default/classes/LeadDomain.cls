public with sharing class LeadDomain {

    public static Boolean checkCNPJValidity(String cnpj) {
        if (String.isBlank(cnpj)) return false;

        cnpj = cnpj.replaceAll('[^0-9]', '');
        if (cnpj.length() != 14) return false;

        Boolean allDigitsSame = true;
        for (Integer i = 1; i < cnpj.length(); i++) {
            if (cnpj.charAt(i) != cnpj.charAt(0)) {
                allDigitsSame = false;
                break;
            }
        }
        if (allDigitsSame) return false;

        Integer[] weights1 = new Integer[]{5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2};
        Integer[] weights2 = new Integer[]{6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2};

        Integer firstDigit = computeCheckDigit(cnpj.substring(0, 12), weights1);
        Integer secondDigit = computeCheckDigit(cnpj.substring(0, 12) + String.valueOf(firstDigit), weights2);

        return (String.valueOf(firstDigit) + String.valueOf(secondDigit)).equals(cnpj.substring(12));
    }

    public static String maskCNPJ(String cnpj) {
        cnpj = cnpj.replaceAll('[^0-9]', '');
        return cnpj.substring(0, 2) + '.' + cnpj.substring(2, 5) + '.' + cnpj.substring(5, 8) + '/' + cnpj.substring(8, 12) + '-' + cnpj.substring(12, 14);
    }

    public static Decimal increaseByOne(Decimal count) {
        return count == null ? 1 : count + 1;
    }

    public static Boolean hasAnyUTMData(Lead lead) {
        return lead.UTM_Campaign__c != null ||
               lead.UTM_Content__c != null ||
               lead.UTM_Medium__c != null ||
               lead.UTM_Source__c != null ||
               lead.UTM_Term__c != null ||
               lead.Website__c != null;
    }

    private static Integer computeCheckDigit(String input, Integer[] weights) {
        Integer sum = 0;
        for (Integer i = 0; i < weights.size(); i++) {
            sum += Integer.valueOf(input.substring(i, i + 1)) * weights[i];
        }
        Integer mod = Math.mod(sum, 11);
        return (mod < 2) ? 0 : 11 - mod;
    }
}