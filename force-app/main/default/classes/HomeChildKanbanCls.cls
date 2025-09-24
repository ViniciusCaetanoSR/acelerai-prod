public with sharing class HomeChildKanbanCls {
    @AuraEnabled
    public static string saveConfig(KanbanConfiguration__c obj) {
        try {
            if (obj.Kanban_For__c == 'Child') {
            } else if (obj.Kanban_For__c == 'Home') {
                obj.Name_Field__c = HomeChildKanbanUtil.getNameField(obj.For_Object__c);
            }
            upsert obj;
            return 'true';
        } catch (exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static Map<string, List<HomeChildKanbanObjUtil>> getObjs() {
        Map<string, List<HomeChildKanbanObjUtil>> objmap = new Map<string, List<HomeChildKanbanObjUtil>>();

        List<Schema.SObjectType> objs = Schema.getGlobalDescribe().values();

        List<HomeChildKanbanObjUtil> sList = new List<HomeChildKanbanObjUtil>();
        List<HomeChildKanbanObjUtil> cList = new List<HomeChildKanbanObjUtil>();

        for (Schema.SObjectType s : objs) {
            Schema.DescribeSObjectResult ds = s.getDescribe();
            if (ds.isAccessible() && ds.isQueryable()) {
                HomeChildKanbanObjUtil hcu = new HomeChildKanbanObjUtil(ds.getName(), ds.getLabel());
                if (ds.isCustom()) {
                    cList.add(hcu);
                } else {
                    sList.add(hcu);
                }
            }
        }
        objmap.put('standard', sList);
        objmap.put('custom', cList);

        return objmap;
    }

    @AuraEnabled
    public static Map<string, List<HomeChildKanbanCObjUtil>> getObjChilds(string objName) {
        Map<string, List<HomeChildKanbanCObjUtil>> objmap = new Map<string, List<HomeChildKanbanCObjUtil>>();
        List<HomeChildKanbanCObjUtil> sList = new List<HomeChildKanbanCObjUtil>();
        List<HomeChildKanbanCObjUtil> cList = new List<HomeChildKanbanCObjUtil>();
        List<Schema.ChildRelationship> cObjs = Schema.getGlobalDescribe().get(objName).getDescribe().getChildRelationships();
        for (Schema.ChildRelationship s : cObjs) {
            Schema.DescribeSObjectResult sObj = s.getChildSObject().getDescribe();
            Schema.DescribeFieldResult sFld = s.getField().getDescribe();
            if (
                sObj.isDeprecatedAndHidden() != true &&
                sObj.isAccessible() &&
                sObj.isCreateable() &&
                sObj.isUpdateable() &&
                sObj.isQueryable() &&
                sFld.isFilterable() &&
                sFld.isAccessible()
            ) {
                HomeChildKanbanCObjUtil hcu = new HomeChildKanbanCObjUtil(
                    sObj.getName() + '~;' + sFld.getName(),
                    sObj.getLabel() + ' (' + sFld.getName() + ')',
                    sFld.getName()
                );
                if (sObj.isCustom()) {
                    cList.add(hcu);
                } else {
                    sList.add(hcu);
                }
            }
        }
        objmap.put('standard', sList);
        objmap.put('custom', cList);
        return objmap;
    }

    @AuraEnabled
    public static Map<string, List<HomeChildKanbanObjUtil>> getObjFlds(string objName) {
        Map<string, List<HomeChildKanbanObjUtil>> objFldmap = new Map<string, List<HomeChildKanbanObjUtil>>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();

        List<HomeChildKanbanObjUtil> aList = new List<HomeChildKanbanObjUtil>();
        List<HomeChildKanbanObjUtil> gList = new List<HomeChildKanbanObjUtil>();
        List<HomeChildKanbanObjUtil> sList = new List<HomeChildKanbanObjUtil>();

        for (Schema.SObjectField sfield : fieldMap.Values()) {
            schema.describefieldresult dfield = sfield.getDescribe();
            if (dfield.isAccessible() && dfield.isDeprecatedAndHidden() != true) {
                string fldType = string.valueOf(dfield.getType());
                HomeChildKanbanObjUtil hcu = new HomeChildKanbanObjUtil(dfield.getName(), dfield.getLabel());
                aList.add(hcu);
                if (dfield.isGroupable() && dfield.isUpdateable() && fldType == 'PICKLIST') {
                    gList.add(hcu);
                }
                if (fldType == 'Double' || fldType == 'Integer' || fldType == 'Currency') {
                    sList.add(hcu);
                }
            }
        }
        objFldmap.put('all', aList);
        objFldmap.put('groupBy', gList);
        objFldmap.put('sumBy', sList);
        return objFldmap;
    }

    @AuraEnabled
    public static List<HomeChildKanbanObjUtil> getPickVals(String FldName, String objName) {
        List<HomeChildKanbanObjUtil> plist = new List<HomeChildKanbanObjUtil>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(FldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            plist.add(new HomeChildKanbanObjUtil(f.getLabel(), f.getValue()));
        }
        return plist;
    }

    @AuraEnabled
    public static HomeChildKanbanUtil getKanban(
        String objName,
        List<String> objFields,
        String kabnanField,
        String ParentRecId,
        String relField,
        List<string> ExcVal,
        String summField,
        String KbObjNameField,
        String recordTypes,
        String filter_Field_1,
        String filterFieldValue1,
        String filter_Field_2,
        String filterFieldValue2,
        String filter_Field_3,
        String filterFieldValue3,
        String filter_Field_4,
        String filterFieldValue4
    ) {
        try {
            Decimal startTime = System.now().getTime() / 1000.0;

            if (summField != null) {
                objFields.add(summField);
            }
            if (filter_Field_2 != null) {
                objFields.add(filter_Field_2);
            }
            if (filter_Field_3 != null) {
                objFields.add(filter_Field_3);
            }
            if (filter_Field_4 != null) {
                objFields.add(filter_Field_4);
            }

            if (KbObjNameField != null && KbObjNameField != 'false') {
                if (Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(KbObjNameField) != null) {
                    objFields.add(KbObjNameField);
                }
            }
            objFields.add(kabnanField);
            Set<string> obFields = new Set<string>(objFields);
            obFields.remove('Id');

            /*Checks if all the requested fields are accessible*/
            if (HomeChildKanbanUtil.checkAccessibleFLS(obFields, objName)) {
                Set<string> kfldCheck = new Set<string>();
                kfldCheck.add(kabnanField);

                /*Checks if the Group By Field is Updatable*/
                if (HomeChildKanbanUtil.checkAccessibleFLS(kfldCheck, objName)) {
                    boolean ispdatable = HomeChildKanbanUtil.checkUpdateableFLS(kfldCheck, objName);

                    Schema.DescribeSObjectResult actdsc = Schema.getGlobalDescribe().get(objName).getDescribe();
                    Map<String, Schema.SObjectField> allFieldMap = actdsc.fields.getMap();
                    string agrFldName = null;
                    string sFldIsCurrency = null;
                    Map<string, decimal> aggQMap;
                    List<AggregateResult> sumQuery;

                    if (summField != null) {
                        Schema.DescribeFieldResult ads = allFieldMap.get(summField).getDescribe();
                        string aftype = string.valueOf(ads.getType());

                        if (aftype == 'Double' || aftype == 'Integer' || aftype == 'Currency') {
                            agrFldName = ads.getLabel();
                            sFldIsCurrency = aftype;
                            aggQMap = new Map<string, decimal>();
                        } else {
                            return new HomeChildKanbanUtil( null, null, false, 'The field ' + summField + ' cannot be summarized.', null, null, null,  null, null, null,  null, null, null);
                        }
                    }
                    try {
                        if (filter_Field_1 != null && filterFieldValue1 != '') {
                            if (Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(filter_Field_1) != null) {
                                objFields.add(filter_Field_1);
                            }
                        }

                        if (filter_Field_2 != null && filterFieldValue2 != '') {
                            if (Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(filter_Field_2) != null) {
                                objFields.add(filter_Field_2);
                            }
                        }

                        if (filter_Field_3 != null && filterFieldValue3 != '') {
                            if (Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(filter_Field_3) != null) {
                                objFields.add(filter_Field_3);
                            }
                        }

                        if (filter_Field_4 != null && filterFieldValue4 != '') {
                            if (Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(filter_Field_4) != null) {
                                objFields.add(filter_Field_4);
                            }
                        }
                    } catch (Exception e) {
                        System.debug(LoggingLevel.ERROR, 'Exception>> e.getMessage: ' + e.getMessage());
                        System.debug(LoggingLevel.ERROR, 'Exception>> e.getCause: ' + e.getCause());
                        System.debug(LoggingLevel.ERROR, 'Exception>> e.getLineNumber: ' + e.getLineNumber());
                        System.debug(LoggingLevel.ERROR, 'Exception>> e.getStackTraceString: ' + e.getStackTraceString());
                        return new HomeChildKanbanUtil( null,  null, false, 'O campo ' + filter_Field_1 + ' e/ou o seu valor ' + filterFieldValue1 + ' não existe no objeto: ' + objName + '.', null, null,null, null, null,null, null, null, null);
                    }

                    List<string> Pickvalslst = new List<String>();
                    Set<string> ExcVals = new Set<string>(ExcVal);
                    Map<string, list<sobject>> recMaps = new Map<string, list<sobject>>();

                    for (Schema.PicklistEntry s : allFieldMap.get(kabnanField).getDescribe().getpicklistValues()) {
                        if (!ExcVals.contains(s.getValue()) && s.isActive()) {
                            Pickvalslst.add(s.getValue());
                            recMaps.put(s.getValue(), new List<sobject>());
                            if (summField != null) {
                                aggQMap.put(s.getValue(), 0);
                            }
                        }
                    }

                    string cObName = actdsc.getLabel();
                    Schema.DescribeFieldResult utilResult = allFieldMap.get(kabnanField).getDescribe();
                    string gFldName = utilResult.getLabel();
                    boolean gFldEditable = utilResult.isUpdateable();
                    boolean isObjDeletable = actdsc.isDeletable();
                    boolean isObjectCreateable = actdsc.isCreateable();

                    //For Getting a Map of field name and its type
                    Map<String, Map<String, String>> fieldTypeMap = new Map<String, Map<String, String>>();

                    String qry = 'Select Id, ';

                    for (String s : obFields) {
                        Schema.DescribeFieldResult currentFieldResult = allFieldMap.get(s).getDescribe();
                        string currentFieldType = string.valueOf(currentFieldResult.getType());
                        Map<String, String> currentMap = new Map<String, String>();
                        currentMap.put('type', currentFieldType);
                        if (currentFieldType == 'REFERENCE') {
                            string currentRelationName = currentFieldResult.getRelationshipName();
                            string refObjName;
                            if (currentFieldResult.isNamePointing()) {
                                for (Schema.SObjectType reference : currentFieldResult.getReferenceTo()) {
                                    Schema.DescribeSObjectResult dsr = reference.getDescribe();
                                    if (dsr.isAccessible()) {
                                        refObjName = dsr.getName();
                                        break;
                                    }
                                }
                                if (refObjName == null) {
                                    return new HomeChildKanbanUtil(null, null, false, 'You do not have access to relational object. Please contact your administrator.', null,  null,null, null, null, null,  null, null, null);
                                }
                            } else {
                                refObjName = currentFieldResult.getReferenceTo()[0].getDescribe().getName();
                            }
                            string fName = HomeChildKanbanUtil.getNameField(refObjName);
                            if (fName != 'false') {
                                qry += currentRelationName + '.' + fName + ' ,';
                            } else {
                                return new HomeChildKanbanUtil( null, null, false,'You do not have access to relation object ' + refObjName + '. Please contact your administrator.', null, null, null, null, null, null, null, null, null);
                            }
                            currentMap.put('relationName', currentRelationName + '~*!' + fName);
                        }
                        qry += s + ' ,';
                        fieldTypeMap.put(s, currentMap);
                    }
                    qry = qry.removeEnd(',');

                    qry += ' From ' + objName + ' where ' + kabnanField + ' in :Pickvalslst';

                    if (ParentRecId != '' && ParentRecId != null && relField != '' && relField != null) {
                        qry += ' and ' + relField + '=\'' + ParentRecId + '\'';
                    }

                    if (recordTypes != null) {
                        if (recordTypes.contains(';')) {
                            List<String> recordTypeParts = recordTypes.split(';');
                            qry += ' AND RecordType.DeveloperName IN :recordTypeParts';
                        } else {
                            qry += ' AND RecordType.DeveloperName = :recordTypes';
                        }
                    }

                    List<String> fieldNames = new List<String>{ filter_Field_1, filter_Field_2, filter_Field_3, filter_Field_4 };
                    Map<String, Schema.DisplayType> fieldTypes = getFieldTypes(objName, fieldNames);

                    Schema.DisplayType fieldType1 = fieldTypes.get(filter_Field_1);
                    Map<String, Object> queryData1 = buildQueryWithFilters(fieldType1, filter_Field_1, filterFieldValue1, '1');
                    qry += queryData1.get('queryFilter');

                    Schema.DisplayType fieldType2 = fieldTypes.get(filter_Field_2);
                    Map<String, Object> queryData2 = buildQueryWithFilters(fieldType2, filter_Field_2, filterFieldValue2, '2');
                    qry += queryData2.get('queryFilter');

                    Schema.DisplayType fieldType3 = fieldTypes.get(filter_Field_3);
                    Map<String, Object> queryData3 = buildQueryWithFilters(fieldType3, filter_Field_3, filterFieldValue3, '3');
                    qry += queryData3.get('queryFilter');

                    Schema.DisplayType fieldType4 = fieldTypes.get(filter_Field_4);
                    Map<String, Object> queryData4 = buildQueryWithFilters(fieldType4, filter_Field_4, filterFieldValue4, '4');
                    qry += queryData4.get('queryFilter');

                    Map<String, Object> queryValues = new Map<String, Object>();
                    queryValues.putAll((Map<String, Object>) queryData1.get('queryValues'));
                    queryValues.putAll((Map<String, Object>) queryData2.get('queryValues'));
                    queryValues.putAll((Map<String, Object>) queryData3.get('queryValues'));
                    queryValues.putAll((Map<String, Object>) queryData4.get('queryValues'));

                    String finalQuery = qry;
                    printFinalQueryWithValues(qry, Pickvalslst, recordTypes, queryValues);

                    //TODO: criar um método. O Código abaixo, serve para formatar a data
                        for (String key : queryValues.keySet()) {
                            Object value = queryValues.get(key);
                            if (value instanceof String) {
                                String regexPattern = '^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{3}\\+0000$';

                                if (Pattern.matches(regexPattern, String.valueOf(value))) {
                                    finalQuery = finalQuery.replace(':' + key, String.valueOf(value));
                                } else {
                                    finalQuery = finalQuery.replace(':' + key, '\'' + String.escapeSingleQuotes((String) value) + '\'');
                                }
                            } else if (String.valueOf(value).endsWith('00:00:00')) {
                                finalQuery = finalQuery.replace(':' + key, String.valueOf(value).substring(0, 10));
                            } else if (value instanceof Date) {
                                finalQuery = finalQuery.replace(':' + key, String.valueOf((Date) value));
                            } else if (value instanceof DateTime) {
                                finalQuery = finalQuery.replace(':' + key, ((DateTime) value).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
                            } else if (value instanceof Double) {
                                finalQuery = finalQuery.replace(':' + key, String.valueOf(value));
                            } else {
                                //Boolea
                                finalQuery = finalQuery.replace(':' + key, String.valueOf(value));
                            }
                        }
                    //
                    finalQuery += ' LIMIT 5000';
                    System.debug('FINAL QUERY 2: ' + finalQuery);
                    List<SObject> results = Database.query(finalQuery);
                    if (!results.isEmpty()) {
                        System.debug('Quantidade de registros encontrados para o Kanban: ' + results.size());

                        for (sobject s : results) {
                            recMaps.get(string.valueOf(s.get(kabnanField))).add(s);

                            if (summField != null) {
                                decimal sVal = (Decimal) s.get(summField);
                                if (sVal != null) {
                                    aggQMap.put(
                                        string.valueOf(s.get(kabnanField)),
                                        (Decimal) s.get(summField) + (Decimal) aggQMap.get(string.valueOf(s.get(kabnanField)))
                                    );
                                }
                            }
                        }
                    } else {
                        System.debug('Não foram encontrados registros: ' + results.size());
                    }
                    Decimal endTime = System.now().getTime() / 1000.0;
                    Decimal executionTimeSeconds = endTime - startTime;
                    System.debug('Apex Execution Time (seconds): ' + executionTimeSeconds);

                    return new HomeChildKanbanUtil(
                        recMaps,
                        Pickvalslst,
                        true,
                        null,
                        gFldName,
                        cObName,
                        agrFldName,
                        sFldIsCurrency,
                        aggQMap,
                        gFldEditable,
                        isObjDeletable,
                        fieldTypeMap,
                        isObjectCreateable
                    );
                } else {
                    return new HomeChildKanbanUtil( null, null, false, 'You do not have access to the specified Group By field. Please contact your administrator.', null, null, null, null, null, null, null, null, null);
                }
            } else {
                return new HomeChildKanbanUtil( null, null, false, 'You do not have access to the requested fields. Please contact your administrator.', null, null, null, null, null, null, null, null, null);
            }
        } catch (exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception>> e.getMessage: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Exception>> e.getCause: ' + e.getCause());
            System.debug(LoggingLevel.ERROR, 'Exception>> e.getLineNumber: ' + e.getLineNumber());
            System.debug(LoggingLevel.ERROR, 'Exception>> e.getStackTraceString: ' + e.getStackTraceString());
            return new HomeChildKanbanUtil(null, null, false, e.getMessage(), null, null, null, null, null, null, null, null, null);
        }
    }

    private static void printFinalQueryWithValues(String query, List<String> Pickvalslst, String recordTypes, Map<String, Object> queryValues) {
        String debugQuery = query;

        if (!Pickvalslst.isEmpty()) {
            String picklistValues = '\'' + String.join(Pickvalslst, '\',\'') + '\'';
            debugQuery = debugQuery.replace(':Pickvalslst', '(' + picklistValues + ')');
        } else {
            debugQuery = debugQuery.replace(':Pickvalslst', '()');
        }

        if (recordTypes != null) {
            if (recordTypes.contains(';')) {
                List<String> recordTypeParts = recordTypes.split(';');
                String recordTypeValues = '\'' + String.join(recordTypeParts, '\',\'') + '\'';
                debugQuery = debugQuery.replace(':recordTypeParts', '(' + recordTypeValues + ')');
            } else {
                debugQuery = debugQuery.replace(':recordTypes', '\'' + recordTypes + '\'');
            }
        }

        if (queryValues != null) {
            for (String key : queryValues.keySet()) {
                Object value = queryValues.get(key);

                if (value instanceof String) {
                    String regexPattern = '^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{3}\\+0000$';

                    if (Pattern.matches(regexPattern, String.valueOf(value))) {
                        debugQuery = debugQuery.replace(':' + key, String.valueOf(value));
                    } else {
                        debugQuery = debugQuery.replace(':' + key, '\'' + String.escapeSingleQuotes((String) value) + '\'');
                    }
                } else if (String.valueOf(value).endsWith('00:00:00')) {
                    String dateStr = String.valueOf(value).substring(0, 10);
                    debugQuery = debugQuery.replace(':' + key, dateStr);
                } else if (value instanceof Date) {
                    String dateStr = String.valueOf((Date) value);
                    debugQuery = debugQuery.replace(':' + key, dateStr);
                } else if (value instanceof DateTime) {
                    String dateTimeStr = ((DateTime) value).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                    debugQuery = debugQuery.replace(':' + key, dateTimeStr);
                } else {
                    String valStr = String.valueOf(value);
                    debugQuery = debugQuery.replace(':' + key, valStr);
                }
            }
        }

        System.debug('FINAL QUERY 1: ' + debugQuery);
    }

    @AuraEnabled
    public static Map<String, Schema.DisplayType> getFieldTypes(String objName, List<String> fieldNames) {
        Map<String, Schema.DisplayType> fieldTypes = new Map<String, Schema.DisplayType>();

        try {
            Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(objName).getDescribe();
            Map<String, Schema.SObjectField> fieldsMap = objDescribe.fields.getMap();

            for (String fieldName : fieldNames) {
                if (fieldsMap.containsKey(fieldName)) {
                    Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
                    fieldTypes.put(fieldName, fieldDescribe.getType());
                } else {
                    fieldTypes.put(fieldName, null);
                }
            }
        } catch (Exception ex) {
            System.debug('Erro ao obter tipos dos campos: ' + ex.getMessage());
        }

        return fieldTypes;
    }

    @AuraEnabled
    public static string updateRec(string recId, string recField, string recVal) {
        try {
            Schema.DescribeSObjectResult sObjRes = Id.valueOf(recId).getSObjectType().getDescribe();
            Schema.DescribeFieldResult fldRes = sObjRes.fields.getMap().get(recField).getDescribe();
            if (sObjRes.isAccessible() && sObjRes.isUpdateable() && fldRes.isUpdateable()) {
                String sObjName = sObjRes.getName();
                sObject s = Schema.getGlobalDescribe().get(sObjName).newSObject();
                s.Id = recId;
                s.put(recField, recVal);
                update s;
                return 'true';
            } else {
                return 'You do not have update access to object. Please contact your administrator.';
            }
        } catch (exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static string deleteRec(sobject obj) {
        Schema.DescribeSObjectResult sObjRes = Id.valueOf(obj.Id).getSObjectType().getDescribe();
        if (sObjRes.isDeletable()) {
            try {
                delete obj;
                return 'true';
            } catch (exception e) {
                return e.getMessage();
            }
        } else {
            return 'You do not have permissions to delete the record. Please contact your administrator.';
        }
    }

    @AuraEnabled
    public static Map<String, List<HomeChildKanbanObjUtil>> getObjRecordTypes(String objName) {
        Map<String, List<HomeChildKanbanObjUtil>> recordTypeMap = new Map<String, List<HomeChildKanbanObjUtil>>();
        List<HomeChildKanbanObjUtil> rtList = new List<HomeChildKanbanObjUtil>();

        try {
            List<RecordType> recordTypes = [
                SELECT Id, Name, DeveloperName
                FROM RecordType
                WHERE SObjectType = :objName AND IsActive = TRUE
                ORDER BY Name
            ];

            rtList.add(new HomeChildKanbanObjUtil('--None--', ''));

            for (RecordType rt : recordTypes) {
                rtList.add(new HomeChildKanbanObjUtil(rt.DeveloperName, rt.Name));
            }

            recordTypeMap.put('recordTypes', rtList);
            return recordTypeMap;
        } catch (Exception e) {
            throw new AuraHandledException('Error AO Carregar Record Types: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, List<Map<String, String>>> getfilterFieldValue(
        String objectName,
        String filter_Field_1,
        String filterFieldValue1,
        String filter_Field_2,
        String filterFieldValue2,
        String filter_Field_3,
        String filterFieldValue3,
        String filter_Field_4,
        String filterFieldValue4
    ) {
        Map<String, List<Map<String, String>>> resultMap = new Map<String, List<Map<String, String>>>();

        try {
            String query = 'SELECT Id FROM ' + objectName + ' WHERE ' + filter_Field_1 + ' = :filterFieldValue1';

            if (filter_Field_2 != null && filterFieldValue2 != null) {
                query += ' AND ' + filter_Field_2 + ' = :filterFieldValue2';
            }
            if (filter_Field_3 != null && filterFieldValue3 != null) {
                query += ' AND ' + filter_Field_3 + ' = :filterFieldValue3';
            }
            if (filter_Field_4 != null && filterFieldValue4 != null) {
                query += ' AND ' + filter_Field_4 + ' = :filterFieldValue4';
            }
            List<SObject> records = Database.query(query);

            List<Map<String, String>> kanbanObjList = new List<Map<String, String>>();

            for (SObject r : records) {
                Map<String, String> objUtil = new Map<String, String>();
                objUtil.put('Id', (String) r.get('Id'));

                kanbanObjList.add(objUtil);
            }

            resultMap.put(objectName, kanbanObjList);

            return resultMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Map<String, String> extractOperatorAndDate(String filterValue) {
        Map<String, String> result = new Map<String, String>();
        System.debug('Input filterValue: ' + filterValue);

        // Extrair e validar a parte da data primeiro
        String datePart = filterValue.replaceAll('[^0-9/]', '').trim();
        System.debug('Extracted datePart: ' + datePart);
        if (!Pattern.matches('\\d{2}/\\d{2}/\\d{4}', datePart)) {
            System.debug('Throwing exception for invalid date format');
            throw new AuraHandledException('O valor precisa estar no formato DD/MM/AAAA');
        }

        // Extrair e validar o operador
        String operator = filterValue.replaceAll('\\d{2}/\\d{2}/\\d{4}', '').trim();
        System.debug('Extracted operator: ' + operator);
        if (operator == '') {
            operator = '=';
        }

        if (!Pattern.matches('^[<>]=?$|^=$|^!=$', operator)) {
            System.debug('Throwing exception for invalid operator');
            throw new AuraHandledException('Operador inválido. Use "<", ">", "<=", ">=", "!=" ou "="');
        }

        List<String> dateParts = datePart.split('/');
        String soqlDate = dateParts[0] + '/' + dateParts[1] + '/' + dateParts[2];

        result.put('operator', operator);
        result.put('date', soqlDate);

        return result;
    }

    public static Map<String, String> extractOperator(String filterValue) {
        Map<String, String> result = new Map<String, String>();

        Pattern pattern = Pattern.compile('^(<=|>=|!=|<|>|=)?(.*)$');
        Matcher matcher = pattern.matcher(filterValue.trim());

        if (matcher.matches()) {
            String operator = matcher.group(1);
            String value = matcher.group(2).trim(); // O restante é o valor

            if (String.isEmpty(operator)) {
                operator = '=';
            }

            if (!System.Pattern.matches('^[<>]=?$|^=$|^!=$', operator)) {
                throw new AuraHandledException('Operador inválido. Use "<", ">", "<=", ">=", "!=" ou "="');
            }

            result.put('operator', operator);
            result.put('value', value);
        } else {
            throw new AuraHandledException('Formato inválido.');
        }

        return result;
    }

    public static Map<String, Object> buildQueryWithFilters(Schema.DisplayType fieldType, String filter_Field, String filterFieldValue, String suffix) {
        Map<String, Object> queryData = new Map<String, Object>();

        if (fieldType == null || filter_Field == null || filterFieldValue == null) {
            queryData.put('queryFilter', '');
            queryData.put('queryValues', new Map<String, Object>());
            return queryData;
        }

        String queryFilter = '';
        Map<String, Object> queryValues = new Map<String, Object>();

        boolean isNotEqual = filterFieldValue.startsWith('!=');
        String operator = isNotEqual ? '!=' : '=';
        String value = isNotEqual ? filterFieldValue.substring(2).trim() : filterFieldValue.trim();

        System.debug('fieldType: ' + fieldType);
        System.debug('filter_Field: '+ filter_Field);
        System.debug('filterFieldValue: ' + filterFieldValue);

        if(filterFieldValue == 'null' || filterFieldValue == 'Null'){

            queryFilter = ' AND ' + filter_Field + ' ' + operator + ' null';
            System.debug('queryFilter: ' + queryFilter);
        }else{

            if (fieldType == Schema.DisplayType.DATE) {
                Map<String, String> parsedDate = extractOperatorAndDate(filterFieldValue);
                String dateValueString = parsedDate.get('date').substring(0, 10);
                Date dateValue = Date.valueOf(dateValueString);
                queryFilter = ' AND ' + filter_Field + ' ' + parsedDate.get('operator') + ' :dateValue' + suffix;
                queryValues.put('dateValue' + suffix, dateValue);
            } else if (fieldType == Schema.DisplayType.DATETIME) {
                Map<String, String> parsedDate = extractOperatorAndDate(filterFieldValue);
                String dateString = parsedDate.get('date');
                String dateTimeValue = convertDateToDateTimeFormat(dateString);
                queryFilter = ' AND ' + filter_Field + ' ' + parsedDate.get('operator') + ' :dateTimeValue' + suffix;
                queryValues.put('dateTimeValue' + suffix, dateTimeValue);
            } else if (fieldType == Schema.DisplayType.BOOLEAN) {
                Boolean boolValue = Boolean.valueOf(value);
                queryFilter = ' AND ' + filter_Field + ' ' + operator + ' :boolValue' + suffix;
                queryValues.put('boolValue' + suffix, boolValue);
            } else if (fieldType == Schema.DisplayType.DOUBLE) {
                Map<String, String> parsedData = extractOperator(filterFieldValue);
                String valueString = parsedData.get('value');
                Double doubleValue = Double.valueOf(valueString);
                queryFilter = ' AND ' + filter_Field + ' ' + parsedData.get('operator') + ' :doubleValue' + suffix;
                queryValues.put('doubleValue' + suffix, doubleValue);
            } else if (filterFieldValue.contains(';')) {
                List<String> fieldValues = filterFieldValue.split(';');
                queryFilter = ' AND ' + filter_Field + ' IN :fieldValues' + suffix;
                queryValues.put('fieldValues' + suffix, fieldValues);
            } else {
             
                queryFilter = ' AND ' + filter_Field + ' ' + operator + ' :filterFieldValue' + suffix;
                System.debug('queryFilter: ' + queryFilter);
                queryValues.put('filterFieldValue' + suffix, value);
            }
        }

        queryData.put('queryFilter', queryFilter);
        queryData.put('queryValues', queryValues);
        return queryData;
    }

    public static String convertDateToDateTimeFormat(String dateString) {
        try {
            System.debug('dateString: ' + dateString);
            if (String.isBlank(dateString) || !Pattern.matches('\\d{2}/\\d{2}/\\d{4}', dateString)) {
                throw new IllegalArgumentException('Invalid date format. Please use DD/MM/YYYY (e.g., 01/01/2025)');
            }

            List<String> dateParts = dateString.split('/');
            Integer day = Integer.valueOf(dateParts[0]);
            Integer month = Integer.valueOf(dateParts[1]);
            Integer year = Integer.valueOf(dateParts[2]);

            Date inputDate = Date.newInstance(year, month, day);

            DateTime dateTimeValue = DateTime.newInstanceGmt(inputDate, Time.newInstance(0, 0, 0, 0));

            String formattedDateTime = dateTimeValue.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS+0000');
            return formattedDateTime;
        } catch (Exception e) {
            System.debug('Error converting date: ' + e.getMessage());
            return null;
        }
    }
}