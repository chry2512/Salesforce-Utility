/**
 * @description       : LWC for Search Product
 * @author            : Christian Niro
 * @group             : Christian Niro
 * @last modified on  : 05-27-2024
 * @last modified by  : 
**/
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Product2.Name';
import ACTIVE_FIELD from '@salesforce/schema/Product2.IsActive';
import ORDERABLE_FIELD from '@salesforce/schema/Product2.IsOrderable__c';
import PRODUCTCODE_FIELD from '@salesforce/schema/Product2.ProductCode';
import PRODUCT_SKU from '@salesforce/schema/Product2.StockKeepingUnit';
import PRODUCT_TYPE from '@salesforce/schema/Product2.Type__c';
import PRODUCT_CLASS from '@salesforce/schema/Product2.Class__c';
import PRODUCT_DESCRIPTION from '@salesforce/schema/Product2.Description';
import searchProducts from '@salesforce/apex/SearchProductController.searchProducts';
import updateProducts from '@salesforce/apex/SearchProductController.updateProducts';

//labels
import cardTitle from '@salesforce/label/c.SearchProduct_CardTitle';
import clearInput from '@salesforce/label/c.SearchProduct_ClearInputButton';
import Search from  '@salesforce/label/c.Search';



// Declare label 

const LABEL = {
    cardTitle,
    clearInput,
    Search
};

// Table Columns
const COLUMNS = [
    { label: 'Name', fieldName: 'recordLink', type: 'url', 
        typeAttributes: { 
            label: { fieldName: NAME_FIELD.fieldApiName }, 
        target: '_blank'}, 
        editable: false 
    },
    { label: 'Code', fieldName: PRODUCTCODE_FIELD.fieldApiName, type: 'text', editable: false},
    { label: 'SKU', fieldName: PRODUCT_SKU.fieldApiName, type: 'text', editable: true},
    { label: 'Descr', fieldName: PRODUCT_DESCRIPTION.fieldApiName, type: 'text', editable: true},
    { label: 'Class', fieldName: PRODUCT_CLASS.fieldApiName, type: 'text', editable: true},
    { label: 'Type', fieldName: PRODUCT_TYPE.fieldApiName, type: 'text', editable: true},
    { label: 'Orderable', fieldName: ORDERABLE_FIELD.fieldApiName, type: 'boolean', editable: true},
    { label: 'isActive', fieldName: ACTIVE_FIELD.fieldApiName, type: 'boolean', editable: true}
    
];

export default class SearchProduct extends LightningElement {

    productName = '';
    label = LABEL;
    columns = COLUMNS;
    products = [];
    draftValues = [];
    productsFound = false;
    errorText = '';
    searchButtonDisabled = true;
    

    handleNameChange(event){
        this.productName = event.detail.value;
        if(this.productName != '' && this.productName != undefined){
            this.searchButtonDisabled = false;
        } else{
            this.searchButtonDisabled = true;
        }
    }

    searchClick(){
        if(this.productName != ''){
            this.products = [];
            this.productSearch();
        } else{
            
            this.productsFound = false;
            this.errorText = 'Inserisci un nome con cui cercare i prodotti';
        }
    }
  

    // function for search product by Name
    productSearch(){
        searchProducts({ productName: this.productName })
        .then((result) => {
            console.log('result', result);
            if(result.length > 0) {
                let prList = [];
                result.forEach(element => {
                    let pr = Object.assign({}, element);
                    pr.recordLink = '/' + pr.Id;
                    prList.push(pr);

                });
                this.products = prList;
                this.productsFound = true;
                
            } else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'No Products found',
                        variant: 'warning',
                        mode: 'dismissable'
                    })
                )
                this.productsFound = false;
                this.errorText = 'No products found';
            }
        })
    }
    
    // this funcion manage upload on Product
    async handleSave(event){

        const updateFields = event.detail.draftValues;
        console.log('updateFields', updateFields);

        const notifyChangeIds = updateFields.map(row => { return {"recordId": row.Id } });

        notifyRecordUpdateAvailable(notifyChangeIds);
        this.draftValues = [];

        try{

            // function update product
            const result = await updateProducts({data: updateFields});

            // showToastEvent
            if(result == 'Success'){

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Products updated',
                        variant: 'success',
                        mode: 'dismissable'
                    })
                )
            } else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'error',
                        mode: 'dismissable'
                    })
                )
            }

        } catch (error){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error,
                    variant: 'error',
                    mode: 'dismissable'
                })
             )
        }

        this.productSearch();
    }

    
    // function for clear input
    clearInput(){
        console.log('<<< Entered in the clear Input');
        this.productName = '';
        this.productsFound = false;
        this.searchButtonDisabled = true;
        console.log('<<< Cleared the input');
        this.template.querySelector('c-looku-page').clearSelection(); 
       
    }

    selectedRecord(event){
        console.log('<<< entered in the Parent LWC');

        this.productName = event.detail.value;
        console.log('<<< productName: ', this.productName);

        this.searchButtonDisabled = false;
        console.log('<<< selectedButtonDisabled è a false');
    }

    clearEvent(event){
        console.log('<<< entered in the clearEvent');
        this.searchButtonDisabled = true;
        this.productName = event.detail.value;
        
    }



}