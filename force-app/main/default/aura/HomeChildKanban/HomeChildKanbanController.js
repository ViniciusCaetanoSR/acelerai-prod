/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

({
    handleRecordUpdated : function(component, event, helper){
        var currentRec = component.get('v.record');
        if(!$A.util.isUndefinedOrNull(currentRec)){
            var recFlds = currentRec.fields;
            var evtSrc = event.getSource();
            if(evtSrc.getLocalId() == 'refreshButton'){
                helper.spinnerHelper(component, true);
                $A.util.addClass(evtSrc,'refreshSpin');
                window.setTimeout($A.getCallback(function(){
                    if(component.isValid()){
                        $A.util.removeClass(evtSrc,'refreshSpin');
                    }
                }), 400);
            }
            var recId = component.get('v.recordId');
            var objName = recFlds.Child_Object__c.value;
            //var objRelField = recFlds.Relation_Field__c.value;
            var objFields = recFlds.Fields_To_Show__c.value;
            var kanbanPicklistField = recFlds.Group_By__c.value;
            var ExcVal = recFlds.Exclude_From_Group_By__c.value;
            var KbObjNameField = recFlds.Name_Field__c.value;
            
            //Adicionado por: Barbara
            var objRecordType = recFlds.Record_Type__c.value;
            var objFilter_Field1 = recFlds.Filter_Field_1__c.value;
            var objFilterFieldValue1 = recFlds.FilterFieldValue1__c.value;
            var objFilter_Field2 = recFlds.Filter_Field_2__c.value;
            var objFilterFieldValue2 = recFlds.FilterFieldValue2__c.value;
            var objFilter_Field3 = recFlds.Filter_Field_3__c.value;
            var objFilterFieldValue3 = recFlds.FilterFieldValue3__c.value;
            var objFilter_Field4 = recFlds.Filter_Field_4__c.value;
            var objFilterFieldValue4 = recFlds.FilterFieldValue4__c.value;

            console.log('[KanbanController] ApiFieldName: ' + objFilter_Field1);
            console.log('[KanbanController] filterFieldValue1: ' + objFilterFieldValue1);

            console.log('[KanbanController] Filter_Field2: ' + objFilter_Field2);
            console.log('[KanbanController] FilterFieldValue2: ' + objFilterFieldValue2);
            //Fim

            var ExcFVal = ExcVal ? ExcVal.split(';') : '';
            if(ExcFVal != ''){
                for(var i=0; i<ExcFVal.length; i++){
                    ExcFVal[i] = ExcFVal[i].trim();
                }
            }
            //var agrFld = recFlds.Summarize_By__c.value;
            //var agrFldFval = agrFld ? agrFld : null;
            
            if(objName && objFields && kanbanPicklistField){
               // alert(recId + objName + objRelField + objFields + kanbanPicklistField);
                var action = component.get('c.getKanban');
                action.setParams({
                    'objName' : objName,
                    'objFields' : objFields.split(';'),
                    'kabnanField' : kanbanPicklistField,
                    //'summField' : agrFldFval,
                    'ParentRecId' : recId,
                    //'relField' : objRelField,
                    'ExcVal' : ExcFVal,
                    'KbObjNameField' : KbObjNameField,
                    'recordTypes': objRecordType,
                    'filter_Field_1': objFilter_Field1,
                    'filterFieldValue1': objFilterFieldValue1,
                    'filter_Field_2': objFilter_Field2,
                    'filterFieldValue2': objFilterFieldValue2,
                    'filter_Field_3': objFilter_Field3,
                    'filterFieldValue3': objFilterFieldValue3,
                    'filter_Field_4': objFilter_Field4,
                    'filterFieldValue4': objFilterFieldValue4
                });
                console.log('[KanbanController] Params: ApiFieldName: ' + objFilter_Field1);
                console.log('[KanbanController] Params: filterFieldValue1: ' + objFilterFieldValue1);
    
                console.log('[KanbanController] Params: Filter_Field2: ' + objFilter_Field2);
                console.log('[KanbanController] Params: FilterFieldValue2: ' + objFilterFieldValue2);

                action.setCallback(this, function(resp){
                    console.log('[KanbanController] getState>>>' + resp.getState());
                console.log('[KanbanController] getError>>>' + resp.getError());
                //console.clear();
                console.log('[KanbanController] getReturnValue>>>' + resp.getReturnValue()); 

                helper.spinnerHelper(component, false);
                if(resp.getState() === 'SUCCESS'){
                    var rVal = resp.getReturnValue();
                    component.set('v.isSuccess', rVal.isSuccess);
                    if(rVal.isSuccess){
                        for(var i=0; i<rVal.records.length; i++){
                            rVal.records[i].kanbanfield = rVal.records[i][kanbanPicklistField];
                        }
                        component.set('v.kwrap',rVal);
                    }else{
                        component.set('v.errorMessage', rVal.errorMessage);
                    }
                }
            });
            $A.enqueueAction(action);
        }
        }
    },
    childChanged : function(component, event, helper) {
        var recFlds = component.get('v.record').fields;
        var data = event.getParam('KanbanChildChange');
        if(data.from != data.to){
            //helper.spinnerHelper(component, true);
            var objFields = recFlds.Fields_To_Show__c.value.split(';');
            var recsMap = component.get('v.kwrap');
            var rec = recsMap.records[data.from][data.pos];
            var nameInToast;
            var simpleRecord = component.get('v.simpleRecord');
            if(!$A.util.isUndefinedOrNull(simpleRecord.Name_Field__c) && simpleRecord.Name_Field__c != 'false'){
                if($A.util.isUndefinedOrNull(rec[simpleRecord.Name_Field__c])){
                    nameInToast = component.get('v.kwrap').cObjName;
                }else{
                	nameInToast = rec[simpleRecord.Name_Field__c];    
                }
            }else{
                nameInToast = component.get('v.kwrap').cObjName;
            }
            var kfld = recFlds.Group_By__c.value;
            var sfield = recFlds.Summarize_By__c.value;
            
            if(rec[sfield] && !isNaN(rec[sfield])){
                var smap = recsMap.rollupData;
                smap[data.from] = smap[data.from] - rec[sfield];
                smap[data.to] = smap[data.to] + rec[sfield];
                recsMap.rollupData = smap;
            }
            
            rec[kfld] = data.to;
            recsMap.records[data.to].unshift(rec);
            recsMap.records[data.from].splice(data.pos, 1);
            
            component.set('v.kwrap',recsMap);
            var toastEvent = $A.get("e.force:showToast");
            var action = component.get('c.updateRec');
            action.setParams({
                'recId' : rec.Id,
                'recField' : kfld,
                'recVal' : data.to
            });
            action.setCallback(this, function(res){
                //helper.spinnerHelper(component, false);
                if(res.getState() === 'SUCCESS' && res.getReturnValue() === 'true'){
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : "success",
                        "duration" : 400,
                        "message": nameInToast+' moved to '+ data.to
                    });
                    toastEvent.fire();
                }else{
                    var em = 'An Unknown Error Occured';
                    if(res.getState() === 'SUCCESS' && res.getReturnValue() != 'true'){
                        em = res.getReturnValue();
                    }else if(res.getState() === 'ERROR'){
                        var errors = res.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                em = errors[0].message;
                            }
                        } else {
                            em = 'An Unknown Error Occured';
                        }
                    }
                    toastEvent.setParams({
                        "title": "Error",
                        "type" : "error",
                        "duration" : 400,
                        "message": em
                    });
                    toastEvent.fire();
                    var rec = recsMap.records[data.to][0];
                    rec[kfld] = data.from;
                    recsMap.records[data.to].splice(0, 1);
                    recsMap.records[data.from].splice(data.pos, 0, rec);
                    component.set('v.kwrap',recsMap);
                }
            });
            $A.enqueueAction(action);
        }
    },
    childDelete : function(component, event, helper) {
        var data = event.getParam('KanbanChildDelete');
        component.set('v.delInfo', data);
        helper.modalHelper(component, 'srModal', 'modalBkdrp', true);
    },
    deleteRecord : function(component, event, helper) {
        var recFlds = component.get('v.record').fields;
        helper.modalHelper(component, 'srModal', 'modalBkdrp', false);
        helper.spinnerHelper(component, true);
        var data = component.get('v.delInfo');
        console.log(data);
        var recsMap = component.get('v.kwrap');
        var rec = recsMap.records[data.from][data.pos];
        console.log(rec);
        var action = component.get('c.deleteRec');
        var sfield = recFlds.Summarize_By__c.value;
        action.setParams({
            'obj' : rec
        });
        action.setCallback(this, function(res){
            helper.spinnerHelper(component, false);
            var state = res.getState();
            var toastEvent = $A.get("e.force:showToast");
            if(state === 'SUCCESS'){
                recsMap.records[data.from].splice(data.pos, 1);
                
                if(rec[sfield] && !isNaN(rec[sfield])){
                    var smap = recsMap.rollupData;
                    smap[data.from] = smap[data.from] - rec[sfield];
                    recsMap.rollupData = smap;
                }
                toastEvent.setParams({
                    "title": "Success",
                    "type" : "success",
                    "duration" : 400,
                    "message" : "The record has been delete successfully."
                });
                toastEvent.fire();
                component.set('v.kwrap',recsMap);
                
            }else if(state === 'ERROR'){
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        em = errors[0].message;
                    }
                }else{
                    em = 'An Unknown Error Occured';
                }
                toastEvent.setParams({
                    "title": "Error",
                    "type" : "error",
                    "duration" : 400,
                    "message" : em
                });
                toastEvent.fire();
            }
            
        });
        $A.enqueueAction(action);
    },
    closeModal : function(component, event, helper) {
        helper.modalHelper(component, 'srModal', 'modalBkdrp', false);
        component.set('v.delInfo', null);
    },
    initiateNewRecordCreation : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        if($A.util.isUndefinedOrNull(recordId)){
            var simpleRecord = component.get('v.simpleRecord');
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": simpleRecord.For_Object__c
            });
            createRecordEvent.fire();
        }else{
            var simpleRecord = component.get('v.simpleRecord');
            var createRecordEvent = $A.get("e.force:createRecord");
            var recObj = {};
            recObj[simpleRecord.Relation_Field__c] = recordId;
            createRecordEvent.setParams({
                "entityApiName": simpleRecord.Child_Object__c,
                "defaultFieldValues": recObj
            });
            createRecordEvent.fire();
        }
    },
    navToRelatedList : function(component, event, helper){
        var recordId = component.get('v.recordId');
        if(!$A.util.isUndefinedOrNull(recordId)){
            var simpleRecord = component.get('v.simpleRecord');
            var relatedListEvent = $A.get("e.force:navigateToRelatedList");
            relatedListEvent.setParams({
                "relatedListId": simpleRecord.Child_Object__c,
                "parentRecordId": recordId
            });
            relatedListEvent.fire();
        }
    }
})