/**
 * @description       : Controller Js ExtractionServiceCreation
 * @author            : Christian Niro
 * @group             : Christian Niro
 * @last modified on  : 05-16-2024
 * @last modified by  : 
**/

import { LightningElement, api} from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";
import { toggleProgress } from 'c/progressBar';
import workbook from "@salesforce/resourceUrl/newexcel";
import Estrazione from '@salesforce/label/c.Estrazione';



export default class ExstractionService extends LightningElement {

    label = {
        Estrazione
    };

    @api file = false;
    @api send = false;
    @api errorMessage;
    progress = 0;
    _interval;
    control = true;
    isLibraryLoaded = false;
    isDataLoaded = false;
    columnHeader = ['Id',  'Description', 'SKU', 'ProductCode', 'Class', 'Type', 'RecordStatus', 'isActive', 'isOrderable'];
    records = [];



    connectedCallback() {
        if (this.isLibraryLoaded)
            return;

        // loadscrip fuction load static resource for generate file XLSX
        loadScript(this, workbook)
            .then(() => {
                console.log("success---> ");
                this.isLibraryLoaded = true;
                this.version = XLSX.version;
                console.log('version: ' + this.version);
            })
            .catch((error) => {
                console.log("error: " + error)
            })

        toggleProgress(this);
    }


    exportToXLSX() {

        return new Promise((resolve, reject) => {

            console.log("<<<Entro nel exportToXLSX");
            console.log("<<<<<<Records exportToXLSX" + this.records);
            
            try {
                    
                const tableData = this.records.map(record => [
                    record.Id,
                    record.Description__c,
                    record.ProductSku__c,
                    record.ProductCode__c,
                    record.Class__c,
                    record.Type__c,
                    record.RecordStatus__c,
                    record.isActive__c,
                    record.isOrderable__c
                ]);

                //Use XLSX JS Library to Export XLSX File

                const filename = 'newStagingArea.xlsx';
                const workbook = XLSX.utils.book_new();
                const headers = this.columnHeader;
                const worksheetData = [];

                for (const record of tableData) {
                    const rowData = {};

                    for (let i = 0; i < headers.length; i++) {
                        rowData[headers[i]] = record[i];
                    }

                    worksheetData.push(rowData);
                }

                const worksheet = XLSX.utils.json_to_sheet(worksheetData, {
                    header: headers
                });

                XLSX.utils.book_append_sheet(workbook, worksheet, 'ExportToExcel');

                const excelBuffer = XLSX.write(workbook, {
                    bookType: 'xlsx',
                    type: 'array'
                });
                const blob = new Blob([excelBuffer], {
                    type: 'application/octet-stream'
                });

                // Create element and download file
                const a = document.createElement('a');
                a.href = URL.createObjectURL(blob);
                a.download = filename;
                a.click();

                URL.revokeObjectURL(a.href);

                console.log("<<<fine nel exportToXLSX");
                resolve(); // Risolvi la Promise quando l'esportazione è completata

            } catch (error) {

                console.error("Error exporting to XLSX:", error);
                reject(error); // Rifiuta la Promise se si verifica un errore
                    
            }

            console.log("<<<fine nel exportToXLSX");
        });

    }

    disconnectedCallback() {
        clearInterval(this._interval);
    }

}