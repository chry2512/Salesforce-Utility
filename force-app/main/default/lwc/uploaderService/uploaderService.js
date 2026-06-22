/**
 * @description       : Component Child for Upload File
 * @author            : Christian Niro
 * @group             : Christian Niro(TMLAB by Spindox)
 * @last modified on  : 05-17-2024
 * @last modified by  : 
**/

// problema drag e drop sul file size 

import { LightningElement,track, api } from 'lwc';

//import uploadFile from '@salesforce/apex/AMP_ServiceCreationController.uploadFile';

//import getContentFile from '@salesforce/apex/AMP_ServiceCreationController.getContentFile';

//import getContentSize from '@salesforce/apex/AMP_ServiceCreationController.getContentSize';

import Upload_Files from '@salesforce/label/c.Upload_Files';

import or_Drop_Files from '@salesforce/label/c.or_Drop_Files';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';



export default class UploaderService extends LightningElement {

    @track file;
    @track showLoadingSpinner = false;
    @api thirdStep;
    @api myRecordId;
    boosterMode= true;
    uploadDisabled = true;
    stopPropagation = false;
    errorMessage = '';
    fileContentSize;

  
    //custom Label

    label = {
      Upload_Files,
      or_Drop_Files
    };

    get acceptedFormats() {
      return ['.pdf', '.csv'];
    }

    // funzione di connectedCallback
    connectedCallback() {
      this.setupDragAndDropListeners();
    }
  
    // setup event dragover e drop
    setupDragAndDropListeners() {
      document.addEventListener('dragover', this.handleDragOver.bind(this));
      document.addEventListener('drop', this.handleDrop.bind(this));
    }

    // remove event dragover e drop
    cleanupDragAndDropListeners() {
      console.log("<<<<sono entrato nel  disconnectedCallback()");
      this.stopPropagation = true;
      document.removeEventListener('dragover', this.handleDragOver);
      document.removeEventListener('drop', this.handleDrop);
    }
    
    //handle dragover for ignore default setup e stop propagation
    handleDragOver(e) {
     
      if(!this.stopPropagation){
        console.log("<<<sono entrato nel  handleDragOver --> Activate");
        e.preventDefault();
      }

      if(this.stopPropagation){
        console.log("<<<sono entrato nel  handleDragOver --> Stop Propagation");
        e.nativeEvent.stopImmediatePropagation();
      }
        
    }
 //handle drop for ignore default setup e stop propagation
    handleDrop(e) {

      console.log("<<<sono entrato nel  handleDrop");
        e.preventDefault();
        this.file = e.dataTransfer.files[0];
        this.uploadDisabled = false;

        if(this.stopPropagation){
          console.log("<<<sono entrato nel   handleDrop his.stopPropagation");
          e.nativeEvent.stopImmediatePropagation();
        }
        console.log("Drag and drop function", this.file);
        
    }
    
    // function to manage booster mode
    activateBoosterMode(){
      console.log("entrato booster mode");
      this.boosterMode = !this.boosterMode;
    }

    // Function to start manage file -->old
    handleUpload() {
      console.log("Sono entrato nell'handleUpload");
      if (this.file) {
        console.log("Il file è valido");
        this.showLoadingSpinner = true;
        this.readFileByChunk(this.file);
      }
    }

    // Function Booster for Upload File 
    /*handleFileChange(event) {

      this.file = event.target.files[0];
      console.log("<<<sono entrato nel  handleFileChange");
      console.log("<<<il file è" , this.file);
      //abilito il bottone upload
      this.uploadDisabled = false;
    }

    // Function Standard for Upload File 

    handleUploadFinished(event) {

      console.log("<<<sono entrato nel  handleUploadFinished");
      this.file = event.detail.files[0];
      console.log("<<<il file nell' handleUploadFinished è" , this.file);
      const documentId = this.file.documentId;
      // retrieve  file content version
      getContentFile({ documentId: documentId, thirdStep: this.thirdStep})
        .then(result => {
          console.log('result', result);
          const fileDetail = new Blob([result], { type: 'text/csv' });
          this.file= fileDetail;
          console.log('File recuperato:', this.file);
          this.retrieveContentSize(documentId);
          this.uploadDisabled = false;
          
        })
        .catch(error => {
          console.error('Errore nel recupero del file:', error);

          if( error.body.message === 'String length exceeds maximum: 6000000'){
            this.errorMessage = 'Warning il file è troppo grande !! Procedi al Next Steps,verrà processato in backgroud!';
          }else if(error.body.message === 'il File è vuoto'){
            this.errorMessage = error.body.message;
          }else{
            this.errorMessage = 'Errore nel processo di elaborazione del file: CPU time out! riduci il file!'
          }
  
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error Upload File',
              message:  this.errorMessage,
              variant: 'warning',
              mode: 'sticky'
            })
          );
          //invio esito lettura file al padre

          if(this.errorMessage = 'Warning il file è troppo grande !! Procedi al Next Steps,verrà processato in backgroud!'){
            const uploadEvent = new CustomEvent("uploadevent", {        
              detail: { success: true }
            });
            this.dispatchEvent(uploadEvent);
          }else{
            const uploadEvent = new CustomEvent("uploadevent", {        
              detail: { success: false }
            });
            this.dispatchEvent(uploadEvent);
          }
        });
        
    }
    
    // function to retrieve file content size
    retrieveContentSize(documentId) {

      console.log("<<<sono entrato nel  retrieveContentSize");

      getContentSize({ documentId })
        .then(result => {
          // Result size file
          this.fileContentSize = result; 
          console.log("<<<sono entrato nel  this.fileContentSize", this.fileContentSize);
        })
    }

  
    // this funciton read file for chunk--> max Size for Chunck --> 65536
    readFileByChunk(file) {

      console.log("Sono entrato nella funzione readFileByChunk");

      if(this.boosterMode){
        var fileSize = file.size; 
        console.log("Sono entrato nella funzione booster file size", fileSize);
      }else if(file.size){
        var fileSize = file.size; 
        console.log("Sono entrato nella funzione drop file size", fileSize);
      } else{
        var fileSize = this.fileContentSize; 
        console.log("Sono entrato nella funzione standard file size", fileSize);
      }

      var chunkSize = 64 * 1024;
      var offset = 0;
      var chunks = [];
      console.log("<<<fileSize ", fileSize);
      console.log("<<<chuckSize ", chunkSize);
      console.log("<<<offSet ", offset);
      
      var chunkReaderBlock = (_offset, length, _file) => {
        console.log("Sono nel chunkReaderBlock");
        var r = new FileReader();
        console.log("offSET", _offset);
        console.log("leng+Offset",length + _offset);

        // slice chunk
        var blob = _file.slice(_offset, length + _offset);

        console.log("<<<<<<<ho fatto il slice del blob", blob);
        

        // read chunk
        r.onload = (evt) => {
            if (evt.target.error == undefined) {
                console.log("entrato nel loading");
                var chunk = evt.target.result;
                console.log("Chunk:", chunk);
                chunks.push(chunk);
                    // increment offset for slice
                offset += chunkSize;
                if (offset < fileSize) {
                    chunkReaderBlock(offset, chunkSize, file);
                } else {
                    const fileContent = chunks.join('');
                    console.log("fileContent", fileContent);
                    this.uploadFileToApex(fileContent);
                    console.log("Lettura del file completata");
                    return;
                }
            } else {
                console.log("Errore di lettura: " + evt.target.error);
            }
        };
  
        r.readAsText(blob);
      };
  
      chunkReaderBlock(offset, chunkSize, file);
    }
    
    // manage file to apex controller
    uploadFileToApex(fileContent) {
      console.log("final", fileContent);
      console.log("ThirdStep", this.thirdStep);
      
      
      uploadFile({ csv: fileContent , thirdStep: this.thirdStep})
        .then(result => {
          this.showLoadingSpinner= false;
          console.log("Risposta dal controller Apex:", result);
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Upload Successfull!!',
              message: result,
              variant: 'success',
              mode: 'sticky'
            })
          );
          //invio esito lettura file al padre
          const uploadEvent = new CustomEvent("uploadevent", {        
            detail: { success: true }
          });
        this.dispatchEvent(uploadEvent);
        })
        .catch(error => {
          this.showLoadingSpinner= false;
           
          if(error.body.message === 'Received exception event aura:systemError from server' && this.boosterMode){
            this.errorMessage = 'Il File è troppo grande per essere caricato ! Riduci il file a 4MB, non dimenticare gli headers!';
          }else{
            this.errorMessage = error.body.message;
          }
          console.error('<<<<<<errorMessageJSON',JSON.stringify(error));
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error Upload File',
              message:  this.errorMessage,
              variant: 'warning',
              mode: 'sticky'
            })
          );
          //invio esito lettura file al padre
          const uploadEvent = new CustomEvent("uploadevent", {        
            detail: { success: false }
          });
        this.dispatchEvent(uploadEvent);
        });
    }*/
    
    // fuction disconnected callback to clear event
    disconnectedCallback() {
      this.cleanupDragAndDropListeners();
    }
    
}