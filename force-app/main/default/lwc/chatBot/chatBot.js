/**
 * @description       : Controller Component Chat bot
 * @author            : Christian Niro
 * @group             : 
 * @last modified on  : 05-15-2024
 * @last modified by  : 
**/
import { LightningElement,track,api } from 'lwc';
import getQueryData from '@salesforce/apex/ChatBotController.getQueryData';
import IMAGE from '@salesforce/resourceUrl/chatBotImage';
import Aiutarti from '@salesforce/label/c.Aiutarti';
import ChatGpt from '@salesforce/label/c.ChatGpt';

export default class ChatBot extends LightningElement {
    @track searchResults = [];
    @track searchTerm = [];
    @api imageUrl = IMAGE;
    @track showSpace = true;
    @track showSpinner = false;
    @track responseData;

    label = {
      Aiutarti,
      ChatGpt
    };

    

    handleKeyDown(event) {
    
        if (event.keyCode === 13) {
          // Perform search when the Enter key is pressed
          this.searchTerm = event.target.value;
          this.showSpinner = true
          this.searchResults = [];
          getQueryData({searchString:this.searchTerm})
            .then(result=>{

              this.showSpinner = false
              // Convert response from Calllouts to OpenIa in String after JSON Parse
              let response = JSON.parse(JSON.stringify(JSON.parse(result)));

                if (response.error) {
                    his.responseData = response.error.message;
                } 
                else if (response.choices[0].text) {
                    this.responseData = response.choices[0].text;
                    this.responseData = this.responseData.replace(/\n/g, "<br />");
                    let tempScriptData = ''
                    tempScriptData = (response.choices[0].text.includes('<script>')) ? 'JS File: ' + response.choices[0].text.split('<script>')[1] : '';
                    tempScriptData = this.responseTextLWCJS.replace(/\n/g, "<br />");
                    this.responseData = this.responseData + this.responseTextLWCJS;
                    this.responseData = (this.responseData.includes('XML File:')) ? this.responseData.split('XML File:')[0] : this.responseData;
                    this.responseData.trim();
                }

             console.log('ss',JSON.stringify(responseData))
           })

           .catch(error=>{
             this.showSpinner = false
             console.log('error is '+error)
           })
          // Replace with a call to your search service
          if(this.searchResults.length > 0 ){
            this.showSpace =false
          }
        }
      
    }

}