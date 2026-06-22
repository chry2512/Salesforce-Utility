/**
 * @description       :  Js controller for createPrice LWC
 * @author            : Christian Niro
 * @group             : Christian Niro
 * @last modified on  : 05-27-2024
 * @last modified by  : 
**/
import { LightningElement, track } from 'lwc';

export default class PriceManagement extends LightningElement {
    @track productName = '';
    @track priceName = '';
    @track amount = 0;
  

    productsFound = false;
    searchButtonDisabled = true;

    handleProductNameChange(event) {
        this.productName = event.target.value;
        console.log('<<productName', this.productName);
    }

    handlePriceNameChange(event) {
        this.priceName = event.target.value;
        console.log('<<priceName', this.priceName); 
    }

    handlePriceAmountChange(event) {
        this.amount = event.target.value;
        console.log('<<amount', this.amount);   
    }

    // function for clear input
    clearInput(){
        console.log('<<< Entered in the clear Input');
        this.productName = '';
        this.productsFound = false;
        this.searchButtonDisabled = true;
        console.log('<<< Cleared the input');
        this.template.querySelector('c-custom-lookup-price').clearSelection(); 
       
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

    createPrice() {
        //chiama controller Apex
    }
}