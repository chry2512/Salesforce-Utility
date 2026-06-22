/*
    @description       : Dynamic Lookup Component
    @author            : Christian Niro
    @group             : 
    @last modified on  : 06-22-2026
    @last modified by  : Christian Niro
*/
import { LightningElement,api } from 'lwc';
import fetchRecords from '@salesforce/apex/DynamicLookupController.fetchRecords'


const DELAY = 500;

export default class CustomLookup extends LightningElement {
    @api helpText = "custom search";
    @api label ;
    @api required;
    @api selectedIconName = "utility:search";
    @api objectLabel ;
    @api showResultsOnFocus = false;
    recordsList = [];
    selectedRecordName;

    @api objectApiName ;
    @api fieldApiName ;
    @api otherFieldApiName ;
    @api searchString = "";
    @api whereString = "";
    @api whereField = "";
    @api selectedRecordId;
    @api parentRecordId;
    @api parentFieldApiName;
    
  

    preventClosingOfSerachPanel = false;

    get methodInput() {
        return {
            objectApiName: this.objectApiName,
            fieldApiName: this.fieldApiName,
            otherFieldApiName: this.otherFieldApiName,
            searchString: this.searchString,
            whereString: this.whereString,
            whereField: this.whereField,
            selectedRecordId: this.selectedRecordId,
            parentRecordId: this.parentRecordId,
            parentFieldApiName: this.parentFieldApiName
        };
    }

    get showRecentRecords() {
        if (!this.recordsList) {
            return false;
        }
        return this.recordsList.length > 0;
    }


    connectedCallback() {
        if (this.selectedRecordId) {
            this.fetchSobjectRecords(true);
        }
    }

    @api
    validate() {
        if(this.selectedRecordId != null && this.selectedRecordId != '') { 
            console.log("entro nel validate ok");
            console.log("<<<<selectedrecordId: " + this.selectedRecordId);
            return { isValid: true }; 
        } 
        else { 
            console.log("entro nel validate false");
            return { 
                isValid: false, 
                errorMessage: ' ' 
            }; 
        }
    }


    fetchSobjectRecords(loadEvent) {
        fetchRecords({
            inputWrapper: this.methodInput
        }).then(result => {
            if (loadEvent && result) {
                this.selectedRecordName = result[0].mainField;
            } else if (result) {
                this.recordsList = JSON.parse(JSON.stringify(result));
            } else {
                this.recordsList = [];
            }
        }).catch(error => {
            console.log(error);
        })
    }

    get isValueSelected() {
        return !!this.selectedRecordId;
    }

    handleFocus() {
        console.log("handleFocus");
        if (this.showResultsOnFocus) {
            console.log("showResultsOnFocus");
            this.fetchSobjectRecords(false);
        }
    }


    handleChange(event) {
        this.searchString = event.target.value;
        this.fetchSobjectRecords(false);
    }


    handleBlur() {
        this.recordsList = [];
        this.preventClosingOfSerachPanel = false;
    }


    handleDivClick() {
        this.preventClosingOfSerachPanel = true;
    }


    handleCommit() {
        this.selectedRecordId = "";
        this.selectedRecordName = "";

        const deselectEvent = new CustomEvent('valueselected', {
            detail: null 
        });
        this.dispatchEvent(deselectEvent);
    }


    handleSelect(event) {
        let selectedRecord = {
            mainField: event.currentTarget.dataset.mainfield,
            subField: event.currentTarget.dataset.subfield,
            id: event.currentTarget.dataset.id
        };

        this.selectedRecordId = selectedRecord.id;
        this.selectedRecordName = selectedRecord.mainField;
        this.recordsList = [];

        console.log("selectedRecordId: " + this.selectedRecordId);

        const selectedEvent = new CustomEvent('valueselected', {
            detail: selectedRecord
        });
        
        this.dispatchEvent(selectedEvent);
    }
    
    
    handleInputBlur(event) {
       
        window.clearTimeout(this.delayTimeout);

        this.delayTimeout = setTimeout(() => {
            if (!this.preventClosingOfSerachPanel) {
                this.recordsList = [];
            }
            this.preventClosingOfSerachPanel = false;
        }, DELAY);
    }

}