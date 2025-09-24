import { LightningElement, api } from 'lwc';
import cloneOpportunityUpsell from '@salesforce/apex/OpportunityCloneController.cloneOpportunityUpsell';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";

export default class CreateVarejoSBT extends NavigationMixin(LightningElement) {

    @api recordId;

    @api
    invoke() {
        this.handleCreateUpsell();
    }
    
    handleCreateUpsell() {
        cloneOpportunityUpsell({oppId: this.recordId})
            .then(result => {
                const successMsg = new ShowToastEvent({
                    title: 'Sucesso',
                    message: 'A oportunidade do tipo "Upsell" foi criada',
                    variant: 'success'
                })
                this.dispatchEvent(successMsg);

                const pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result.Id,
                        objectApiName: 'Opportunity',
                        actionName: 'view'
                    }
                };

                this[NavigationMixin.Navigate](pageReference);

            })
            .catch(error => {
                let errorMessage = 'Erro desconhecido ao criar a oportunidade do tipo "Upsell"';

                if(error.body && error.body.message){
                    errorMessage = error.body.message;
                } else if (error.message) {
                    errorMessage = error.message;                
                }

                const errorMsg = new ShowToastEvent({
                    title: 'Erro',
                    message: errorMessage,
                    variant: 'error'
                })
                this.dispatchEvent(errorMsg);
            });
    }
}