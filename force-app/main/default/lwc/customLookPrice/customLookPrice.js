/**
 * @description       : Controller for customLookPrice LWC
 * @author            : Christian Niro
 * @group             : Christian Niro
 * @last modified on  : 05-27-2024
 * @last modified by  : 
**/
import { LightningElement, api, wire, track } from 'lwc';
import getLookupValues from '@salesforce/apex/SearchProductController.getLookupValues';
import getinitRecord from '@salesforce/apex/CreatePriceController.getinitRecord';
import gerRecentlyCreatedRecords from '@salesforce/apex/CreatePriceController.gerRecentlyCreatedRecords';
import inputPlaceholder from '@salesforce/label/c.inputPlaceHolderPrice';

export default class CustomLookPrice extends LightningElement {
    label = {
        inputPlaceholder
    };
    @api initialLookupValue = '';
    @api where = '';
    @api searchKeyWord = '';
    @api uniqueName = 'PriceList';
    @api objectAPIName = 'PriceList__c';
    @api iconName = 'standard:pricebook';
    @api labelForComponent = 'Search Price List';
    @api recordLimit = 5;
    @api labelHidden = false;
    
    @api selectedRecord = {};
   
    @track selectedRecordLabel = '';

    displayLabelField = 'Name';
    recordIsSelected = false;
    searchRecordList = [];
    message = '';
    error = '';
    noRecordFound = false;

    @wire(getLookupValues, { searchKeyWord: '$searchKeyWord', objectAPIName: '$objectAPIName', whereCondition: '$where', fieldNames: '$displayLabelField', customLimit: '$recordLimit' })
    wiredsearchRecordList({ error, data }) {
        if (data) {
            this.searchRecordList = JSON.parse(JSON.stringify(data));
            this.error = undefined;
            this.hasRecord();
        } else if (error) {
            console.log('getLookupValues Error 2 —> ' + JSON.stringify(error));
            this.hasRecord();
            this.error = error;
            this.searchRecordList = undefined;
        }
    }

    connectedCallback() {
        if (this.initialLookupValue != '') {
            getinitRecord({ recordId: this.initialLookupValue, 'objectAPIName': this.objectAPIName, 'fieldNames': this.displayLabelField })
                .then((data) => {
                    if (data != null) {
                        this.selectedRecord = data;
                        this.selectedRecordLabel = data.Name;
                        this.selectionRecordHelper();
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.selectedRecord = {};
                });
        }
    }

    handleClickOnInputBox(event) {
        const container = this.template.querySelector('.custom-lookup-container');
        container.classList.add('slds-is-open');
        if (typeof this.searchKeyWord === 'string' && this.searchKeyWord.trim().length === 0) {
            gerRecentlyCreatedRecords({ 'objectAPIName': this.objectAPIName, 'fieldNames': this.displayLabelField, 'whereCondition': this.where, 'customLimit': this.recordLimit })
                .then((data) => {
                    if (data != null) {
                        this.searchRecordList = JSON.parse(JSON.stringify(data));
                        this.hasRecord();
                    }
                })
                .catch((error) => {
                    this.error = error;
                });
        } else if (typeof this.searchKeyWord === 'string' && this.searchKeyWord.trim().length > 0) {
            this.searchKeyWord = this.searchKeyWord.trim();
            getLookupValues({ 'searchKeyWord': this.searchKeyWord, 'objectAPIName': this.objectAPIName, 'whereCondition': this.where, 'fieldNames': this.displayLabelField, 'customLimit': this.recordLimit })
                .then((data) => {   
                    if (data != null) {
                        this.searchRecordList = JSON.parse(JSON.stringify(data));
                        this.error = undefined;
                        this.hasRecord();
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.selectedRecord = {};
                });
        }
    }

    fireLookupUpdateEvent(value) {
        if( value != undefined){
            const selectedRecord = new CustomEvent('selected', { detail : { value: this.selectedRecordLabel }});
            this.dispatchEvent(selectedRecord);    
        }
    }

    fireClearEvent() {
        const clearEvent = new CustomEvent('clearevent', {detail: {name: this.uniqueName, value: undefined}});
        this.dispatchEvent(clearEvent);
    }

    handleKeyChange(event) {
        this.searchKeyWord = event.detail.value;
        if (typeof this.searchKeyWord === 'string' && this.searchKeyWord.trim().length > 0) {
            this.searchRecordList = [];
        }
    }

    handleOnblur(event) {
        let container = this.template.querySelector('.custom-lookup-container');
        container.classList.remove('slds-is-open');
        this.searchRecordList = [];
    }

    handleSelectionRecord(event) {
        let recid = event.target.getAttribute('data-recid');
        let container = this.template.querySelector('.custom-lookup-container');
        container.classList.remove('slds-is-open');
        this.selectedRecord = this.searchRecordList.find(data => data.Id === recid);
        this.selectedRecordLabel = this.selectedRecord.Name;
        this.fireLookupUpdateEvent(this.selectedRecordLabel);
        this.selectionRecordHelper();
    }


    toggleClasses(selector, removeClass, addClass) {
        const element = this.template.querySelector(selector);
        element.classList.remove(removeClass);
        element.classList.add(addClass);
    }

    selectionRecordHelper() {
        this.toggleClasses('.custom-lookup-pill', 'slds-hide', 'slds-show');
        this.toggleClasses('.search-input-container', 'slds-show', 'slds-hide');
       
    }

    clearSelectionHelper() {
        this.selectedRecord = {};
        this.selectedRecordLabel = '';
        this.searchKeyWord = '';
        this.searchRecordList = [];
    }

    @api clearSelection() {
        this.toggleClasses('.custom-lookup-pill', 'slds-show', 'slds-hide');
        this.toggleClasses('.search-input-container', 'slds-hide', 'slds-show');
        this.clearSelectionHelper();
        this.fireClearEvent();
        this.fireLookupUpdateEvent(undefined);
        
    }


    hasRecord() {
        this.noRecordFound = !(this.searchRecordList && this.searchRecordList.length > 0);
    }
}