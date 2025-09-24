import { LightningElement, track, wire } from 'lwc';
import getMyLeadEntries from '@salesforce/apex/LeadEntryExporterController.getMyLeadEntries';
import { loadScript } from 'lightning/platformResourceLoader';
import SheetJS from '@salesforce/resourceUrl/SheetJS';

export default class LeadEntryExporter extends LightningElement {
    @track leadEntries = [];
    @track selectedRows = [];

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Email', fieldName: 'Email__c' },
        { label: 'Phone', fieldName: 'Phone__c' },
        { label: 'Status', fieldName: 'Status__c' },
        { label: 'Owner Alias', fieldName: 'OwnerAlias' }
    ];

    sheetJsInitialized = false;

    @wire(getMyLeadEntries)
    wiredEntries({ data, error }) {
        console.log('⚙️ Chamou getMyLeadEntries');

        if (data) {
            console.log('Lead entries recebidos:', JSON.stringify(data, null, 2));

            this.leadEntries = data.map(e => ({
                ...e,
                OwnerAlias: e.Owner?.Alias
            }));
        } else if (error) {
            console.error(error);
        }
    }

    renderedCallback() {
        if (this.sheetJsInitialized) return;
        loadScript(this, SheetJS)
            .then(() => {
                this.sheetJsInitialized = true;
            })
            .catch(error => console.error('Erro ao carregar SheetJS', error));
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    handleExport() {
        const rows = (this.selectedRows.length > 0 ? this.selectedRows : this.leadEntries)
            .map(row => ({
                Name: row.Name,
                Email: row.Email__c,
                Phone: row.Phone__c,
                Status: row.Status__c,
                'Owner Alias': row.OwnerAlias
            }));
        
        const worksheet = XLSX.utils.json_to_sheet(rows);
        const workbook = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(workbook, worksheet, "LeadEntries");
        XLSX.writeFile(workbook, "Leads Exportados.xlsx");
    }
}