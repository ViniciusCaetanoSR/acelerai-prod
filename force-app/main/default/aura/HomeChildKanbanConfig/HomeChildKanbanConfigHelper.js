/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

({
    spinnerHelper : function(component, tf){
        var spinner = component.find('spinner');
        if(tf){
            $A.util.removeClass(spinner,'slds-hide');
        }else{
            $A.util.addClass(spinner,'slds-hide');
        }
    },
    validateForm : function(component, helper){
        var ObjectName = component.get('v.ObjectName');
        var cardFields = component.get('v.cardFields');
        var grpFldName = component.get('v.grpFldName');
        var sumFldName = component.get('v.sumFldName');
        var pickExclVals = component.get('v.pickExclVals');
        var configName = component.get('v.configName');
        var childObjectName = component.get('v.childObjectName');

    /**Adicionei*/
        var recordTypes = component.get('v.recordTypes');
        var apiFieldName = component.get('v.apiFieldName');
        var apiFieldNameValue = component.get('v.apiFieldNameValue');

        console.clear();
        var isFormValid = true;

    /**Adicionei*/
        if(helper.iUorN(recordTypes)){
            helper.errorHelper(component, 'recordTypes', 'Please select a Record Type', true);
            isFormValid = false;
            console.log('o isFormValid é válido depois da verificação do recordTypes?' + isFormValid);
        } else {
            helper.errorHelper(component, 'recordTypes', null, false);
        }
    
    /**Adicionei em 6.11*/
        if(helper.iUorN(apiFieldName)){
            helper.errorHelper(component, 'apiFieldName', 'Por favor, digite um nome de API de campo', true);
            isFormValid = false;
            console.log('o isFormValid é válido depois da verificação do apiFieldName' + isFormValid);
        } else {
            helper.errorHelper(component, 'apiFieldName', null, false);
        }
        if(helper.iUorN(apiFieldNameValue)){
            helper.errorHelper(component, 'apiFieldNameValue', 'Por favor, digite um valor para campo', true);
            isFormValid = false;
            console.log('o isFormValid é válido depois da verificação do apiFieldNameValue' + isFormValid);
        } else {
            helper.errorHelper(component, 'apiFieldNameValue', null, false);
        }

        if(helper.iUorN(ObjectName)){
            helper.errorHelper(component, 'ObjectName', 'Please Select An Object', true);
            isFormValid = false;
        }else{
            helper.errorHelper(component, 'ObjectName', null, false);
        }
        if(helper.iUorN(cardFields)){
            helper.errorHelper(component, 'cardFields', 'Please select atleast one field to show on the kanban tile', true);
        	isFormValid = false;
        }else{
            helper.errorHelper(component, 'cardFields', null, false);
        }
        // if(helper.iUorN(grpFldName)){
        //     helper.errorHelper(component, 'grpFldName', 'Please Select A Field To Group By', true);
        //     isFormValid = false;
        // }else{
        //     helper.errorHelper(component, 'grpFldName', null, false);
        // }

        // if(helper.iUorN(childObjectName) && component.get('v.kanbanFor') == 'Child'){
        //     helper.errorHelper(component, 'childObjectName', 'Please Select A Field To Group By', true);
        //     isFormValid = false;
        // }else{
        //     helper.errorHelper(component, 'childObjectName', null, false);
        // }
        if(helper.iUorN(configName)){
          	component.find('configName').showHelpMessageIfInvalid();
            //isFormValid = false;
        }else{
            //something
        }
        console.log('5 '+ isFormValid);
        //alert(isFormValid);
        if(isFormValid){

            var kf = component.get('v.kanbanFor');
            var sObj = {};
            var recId = component.get('v.recordId');
            if(recId){
                sObj.Id = recId;
            }
            sObj.sobjectType = 'KanbanConfiguration__c';
            sObj.Name = configName;
            sObj.For_Object__c = ObjectName;        

            if(kf != 'Home'){
                sObj.Child_Object__c = childObjectName.split('~;')[0];
                sObj.Relation_Field__c = childObjectName.split('~;')[1];
            }else{
                sObj.Child_Object__c = ObjectName;
            }
            sObj.Kanban_For__c = kf;
            sObj.Summarize_By__c = sumFldName;
            sObj.Group_By__c = grpFldName;
            sObj.Fields_To_Show__c = cardFields;
            sObj.Exclude_From_Group_By__c = pickExclVals;
            
            /**Adicionei*/
            sObj.Record_Type__c = recordTypes;
            sObj.ApiFieldName__c = apiFieldName;
            sObj.ApiFieldNameValue__c = apiFieldNameValue;

            var action = component.get('c.saveConfig');
            action.setParams({
                'obj': sObj
            });
            var toastEvent = $A.get("e.force:showToast");
            action.setCallback(this, function(res){
                var state = res.getState();                
                if(state === 'SUCCESS'){
                    console.log('o state é: ' + state);

                    var rVal = res.getReturnValue();
                    if(rVal == 'true'){
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "The confuguration has been saved successfully.",
                            "type" : "success"
                        });
                        var homeEvent = $A.get("e.force:navigateToObjectHome");
                            homeEvent.setParams({
                                "scope": "KanbanConfiguration__c"
                            });
                        homeEvent.fire();
                    }else{
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "There was an error while saving the confuguration.",
                            "type" : "error"
                        });
                    }
                    toastEvent.fire();
                }else{
                    toastEvent.setParams({
                            "title": "Error!",
                            "message": "There was an error while saving the confuguration.",
                            "type" : "error"
                        });
                    //console.log(res.getError());
                    console.log(state);
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    iUorN : function(par){
        if($A.util.isUndefinedOrNull(par)){
            return true;
        }else{
            return false;
        }
    },
    errorHelper : function(component, elem, message, tf){
        var el = component.find(elem);
        if(tf){
            el.showError(message);
        }else{
            el.hideError();
        }
    },
    getFields : function(component, event, helper, val){
        var action = component.get('c.getObjFlds');
        action.setParams({
            'objName' : val
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state === 'SUCCESS'){
                var rVal = res.getReturnValue();
                console.log(rVal);
                component.set('v.allFieldsList', rVal);

                //component.find('fldsToShow').externalValueChange('Amount');
            }else{
                console.log(res);
                console.log(state);
            }
        });
        $A.enqueueAction(action);
    },

    loadRecordTypes : function(component, objectName){
        console.log('Loading Record Types for:', objectName);
        
        var action = component.get("c.getObjRecordTypes");
        action.setParams({
            "objName": objectName
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Record Types Response State:', state);
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Record Types Result:', result);
                
                if (result && result.recordTypes) {
                    component.set("v.recordTypeList", result.recordTypes);
                    console.log('Record Types List Updated');
                }
            } else {
                console.error('Error loading Record Types:', response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },

    loadApiFieldNameValues : function(component, objectName, apiFieldName, apiFieldNameValue){
        var action = component.get("c.getApiFieldNameValue");
    
        action.setParams({
            "objectName": objectName,
            "apiFieldName": apiFieldName,
            "apiFieldNameValue": apiFieldNameValue
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.apiFieldNameValue", result[objectName]);
                console.log('Filtrado por ' + objectName + ' with ' + apiFieldName + '=' + apiFieldNameValue + ' com sucesso.');
              
            } else {
                console.error('Error loading apiFieldNameValue:', response.getError());
            }
        });
        
        $A.enqueueAction(action);
    }
})