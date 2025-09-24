import { LightningElement, api, wire } from 'lwc';
import getRelatedAccounts from '@salesforce/apex/ListRelatedAccountsController.getRelatedAccounts';
import { NavigationMixin } from 'lightning/navigation';

export default class RelatedAccounts extends NavigationMixin(LightningElement) {
    @api recordId;
    @api iconName = 'standard:account'; 
    relatedAccounts = [];
    error;

    @wire(getRelatedAccounts, { accountId: '$recordId' })
    wiredAccounts({ error, data }) {
        if (data) {
            this.relatedAccounts = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.relatedAccounts = [];
        }
    }

    get hasAccounts() {
        return this.relatedAccounts.length > 0;
    }

    get title() {
        return `Contas Relacionadas (${this.relatedAccounts.length})`;
    }

    get iconPath() {
        if (!this.iconName || !this.iconName.includes(':')) {
            return '';
        }
        const [category, name] = this.iconName.split(':');
        return `/assets/icons/${category}-sprite/svg/symbols.svg#${name}`;
    }  
    
    handleNavigate(event) {
        event.preventDefault();
        const accountId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                actionName: 'view'
            }
        });
    }
}