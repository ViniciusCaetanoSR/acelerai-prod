import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PapaParse from '@salesforce/resourceUrl/PapaParse';
import SheetJS from '@salesforce/resourceUrl/SheetJS';
import ArquivoDeExemplo_LeadPerformance from '@salesforce/resourceUrl/ArquivoDeExemplo_LeadPerformance';
import { loadScript } from 'lightning/platformResourceLoader';
import importLeads from '@salesforce/apex/LeadEntryService.importLeads';
import processLeads from '@salesforce/apex/LeadEntryService.processLeads';

const columns = [   
    { label: 'Name', fieldName: 'Name' },
    { label: 'Email', fieldName: 'Email' },
    { label: 'Phone', fieldName: 'Phone' }
];

export default class SheetDataImporter extends LightningElement {
    @api recordId;
    @track error;
    @track isLoaded;
    @track columns = columns;
    @track data;
    @track papaInitialized = false;
    @track sheetJSInitialized = false;
    sizeOfSpinner = 'small';
    arquivoExemploUrl = ArquivoDeExemplo_LeadPerformance;

    get librariesInitialized() {
        return this.papaInitialized && this.sheetJSInitialized;
    }

    renderedCallback() {
        if (this.librariesInitialized) return;

    Promise.all([
            !this.papaInitialized ? loadScript(this, PapaParse) : Promise.resolve(),
            !this.sheetJSInitialized ? loadScript(this, SheetJS) : Promise.resolve()
        ])        
        .then(() => {
            this.papaInitialized = true;
            this.sheetJSInitialized = true;
            console.log('Bibliotecas carregadas');
        })
        .catch(error => {
            console.error('Erro ao carregar as bibliotecas', error);
            this.error = 'Error loading file parser';
            this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error!',
                message: 'Failed to load file parser',
                variant: 'error',
            }),
            );
        });
    }

    handleFileUpload(event) {
        if (!this.librariesInitialized) {
            this.error = 'Os carregadores de arquivos não estão prontos ainda';
            return;
        }

        const file = event.target.files[0];
        if (!file) return;

        this.data = null;
        this.error = null;
        this.isLoaded = true;

        const fileName = file.name.toLowerCase();
        
        if (fileName.endsWith('.csv')) {
            this.parseCSV(file);
        } else if (fileName.endsWith('.xlsx') || fileName.endsWith('.xls')) {
            this.parseExcel(file);
        } else {
            this.handleError(new Error('Formato de arquivo não suportado. Use CSV ou Excel.'));
        }
    }

    parseCSV(file) {
        Papa.parse(file, {
            header: true,
            skipEmptyLines: true,
            complete: (results) => {
                try {
                    this.processData(results.data);
                } catch (error) {
                    this.handleError(error);
                }
            },
            error: (error) => {
                this.handleError(error);
            }
        });
    }

    parseExcel(file) {
        const reader = new FileReader();
        
        reader.onload = (e) => {
            try {
                const data = new Uint8Array(e.target.result);
                const workbook = window.XLSX.read(data, { type: 'array' });
                
                const firstSheetName = workbook.SheetNames[0];
                const worksheet = workbook.Sheets[firstSheetName];
                
                const excelData = window.XLSX.utils.sheet_to_json(worksheet);
                this.processData(excelData);
            } catch (error) {
                this.handleError(error);
            }
        };
        
        reader.onerror = (error) => {
            this.handleError(error);
        };
        
        reader.readAsArrayBuffer(file);
    }

    processData(rawData) {
        this.data = rawData.map((item, index) => {
            return {              
                Name: item['Name'] || item['name'] || '',
                Email: item['Email__c'] || item['email'] || item['Email'] || '',
                Phone: item['Phone__c'] || item['phone'] || item['Phone'] || ''
            };
        });

        this.isLoaded = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Sucesso!',
                message: 'Arquivo carregado com sucesso',
                variant: 'success',
            }),
        );
    }

    downloadArquivoExemplo() {
        window.open(this.arquivoExemploUrl, '_blank');
    }

    handleError(error) {
        console.error('Error:', error);
        this.isLoaded = false;
        this.error = error.message || 'Erro ao carregar o arquivo';
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error!',
                message: this.error,
                variant: 'error',
            }),
        );
    }

    importData() {
        if (!this.data || this.data.length === 0) {
            this.error = 'Não há dados para importar';
            return;
        }

        this.isLoaded = true;

        processLeads({ leadsData: this.data })
        .then(processedLeads => {
            return importLeads({ leadsToImport: processedLeads });
        })
        .then(res => {
            this.isLoaded = false;
            this.data = res;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Sucesso!',
                    message: 'Os leads foram criados com sucesso.',
                    variant: 'success',
                }),
            );
        })        
        .catch(error => {
            this.isLoaded = false;
            let error_excep = JSON.parse(JSON.stringify(error)).body;
            this.error = error_excep.message;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: error_excep.message,
                    variant: 'error',
                }),
            );
        });
    }
}