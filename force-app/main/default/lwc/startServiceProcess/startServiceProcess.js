/**
  @description       : Component for Start Service Process
  @author            : Christian Niro
  @group             : Christian Niro
  @last modified on  : 05-16-2024
  @last modified by  : 
**/

import { LightningElement, api } from 'lwc';
import batchExecute from '@salesforce/apex/AMP_BatchServiceCreationHandler.executeBatchService';
import getBatchStatus from '@salesforce/apex/AMP_BatchServiceCreationHandler.getBatchStatus';
import checkErrorBatch from '@salesforce/apex/AMP_BatchServiceCreationHandler.checkErrorBatch';
import Elaboro from '@salesforce/label/c.Elaboro';
import Inizia from '@salesforce/label/c.Inizia';
import asyncJobsControl from '@salesforce/apex/AMP_BatchServiceCreationHandler.asyncJobsControl';

export default class StartServiceProcess extends LightningElement {
    label = {
        Elaboro, 
        Inizia
    };

    @api file = false;
    @api send = false;
    @api completed = false;
    progress = 0;
    _interval;
    _timeout;
    control = true;
    isLibraryLoaded = false;
    records;
//----isButtonVisible è probabilmente da modificare
//----is button Disabled a true
    isButtonVisible = true;
    isButtonDisabled = false;
    //isButtonDisabled = true;
    isProgressBarVisible = false;
    totalProgress = 0;
    

    connectedCallback() {
        console.log('<<< entrato nella Callback');
        // Chiamare repeatControl quando il componente viene collegato al DOM
        this.repeatControl();
    }

    async barProgress(){
       
        console.log('<<< entrato nella barra');   
        
        this._interval = setInterval(() => {
            if(this.progress < 30){   
                     
                this.progress = this.progress + 1; 
                this.totalProgress += 1; 
                console.log('<<< entrato nel 30');  
            }else{

                clearInterval(this._interval);
                     
                    batchExecute()
                    .then(async(result) => {
                                
                          
                        console.log("------------- START APEX BATCH ------------");
                        console.log(result);
                        localStorage.setItem('currentStep', '5'); 
                       

                        this._timeout = setTimeout(() => {
                            const barCss=this.template.querySelector('.container-bar');
                            console.log('<<< barCss ', barCss);
                            
                            if(barCss){
                                barCss.style.marginTop = '74px';
                            }
                            const barCompleted = new CustomEvent("barcompleted", {        
                                detail: { barProgress: true}
                            });

                            console.log("entrato nel delay message");

                            this.dispatchEvent(barCompleted);

                            clearTimeout(this._timeout);

                        }, 800 );
                         

                       
                   
                        await this.checkBatchStatus(result, this);

                
                        this._interval = setInterval(() => {

                            console.log("------------- ENTRO NEL SET INTERVAL FUNZIONE PRIMARIA ------------");

                            switch (this.progress) {
                                case 90:
                                    console.log("sono entrato nel case 95 del BarProgress");
                                    this.progress += 2;
                                    break;
                                   
                                case 100:
                                    console.log("sono entrato nel case 100 del BarProgress");
                                    this.isProgressBarVisible = false;
                                    this.isButtonVisible = false;
                                    clearInterval(this._interval);

                                    const barCompleted = new CustomEvent("barcompleted", {        
                                        detail: { onError: false}
                                    });
             
                                    this.dispatchEvent(barCompleted);
                                    break;

                                  
                                default:
                                    console.log("sono entrato nel case default del BarProgress");
                                    this.progress += 1;
                                   
                            }

                            
                            

                            
                                                    
                        }, 800);
                        
                             
                    })
                    .catch((error) => {
                       
                        console.error('<<< getExecuted error:', error);
                        clearInterval(this._interval);
                        this.isProgressBarVisible = false;
                        this.isButtonVisible = false;

                        const barCompleted = new CustomEvent("barcompleted", {        
                            detail: {errorMessage: error, onError: true}
                        });

                        this.dispatchEvent(barCompleted);
                            
                    });

                   
            }
        }, 1200);
        
    }


    async checkBatchStatus(result, component){
       
        return new Promise((resolve, reject) => {
           
        
            getBatchStatus({ jobId: result})
            .then(async result => {
                
                console.log("------------- APEX STATUS ------------");
                console.log(result);
               

                if (result.Status === 'Completed') {

                    clearInterval(component._interval);
                    // funzione delay per assicurarsi che l'oggetto sia stato inserito a DB
                    console.log('Lo stato Completed è in coda. Attendo 10 secondi...');

                    if(component.totalProgress < 80){

                        console.log('<<MINORE di 80 NEL COMPLETED');
                        clearInterval(component._interval);
                        
                        this._interval = setInterval(() => {
                            console.log("<<TOTAL dentro al SetInterval NEL COMPLETED", component.totalProgress);
                            this.progress += 1;
                            component.totalProgress += 1;
                            
                        }, 800);

                    }
                    else{
                        console.log('<<<<CLEAR NEL COMPLETED');
                        clearInterval(component._interval);
                    }

                    console.log('delay');

                    await this.delay(20000); 

                    console.log(' after delay');
                    
                    console.log("<<TOTAL Finish  al SetInterval Completed", component.totalProgress);

                    clearInterval(component._interval);
                    

                    
                    //funzione await che controlla se l'oggetto async custom è valorizzato
                    await this.checkErrorAsync(result.Id, this);

                  
                }else{
                    
                    console.log("<<TOTAL Fuori al SetInterval", component.totalProgress);

                        if(component.totalProgress < 65){

                            console.log('<<MINORE di 65');
                            clearInterval(component._interval);
                            
                            this._interval = setInterval(() => {
                                console.log("<<TOTAL dentro al SetInterval", component.totalProgress);
                                this.progress += 1;
                                component.totalProgress += 1;
                                
                            }, 10000 );

                        }
                        else{
                            console.log('<<<<CLEAR');
                            clearInterval(component._interval);
                        }

                    
                    console.log('Lo stato è in coda. Attendo 10 secondi...');
                    await this.delay(10000); 

                    console.log('Esecuzione dopo il ritardo.');
                    resolve(this.checkBatchStatus(result.Id, this)); // Ricorsivamente richiamiamo la funzione per verificare nuovamente lo stato

                } 

                resolve(result);
        
            })
            .catch(error => {
                 
                clearInterval(component._interval);
                this.isProgressBarVisible = false;
                this.isButtonVisible = false;
                const barCompleted = new CustomEvent("barcompleted", {        
                    detail: {errorMessage: error, onError: true}
                });
                
                this.dispatchEvent(barCompleted);

                reject(error);

            });
            
        });
    }

   
    //funzione delay 
    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }


    checkErrorAsync(result, component){

        return new Promise((resolve, reject) => {

            checkErrorBatch({jobId: result })
            .then(async result =>{
                resolve(result);
            })

            .catch(error => {

                clearInterval(component._interval);
                this.isProgressBarVisible = false;
                this.isButtonVisible = false;

                const barCompleted = new CustomEvent("barcompleted", {        
                    detail: {errorMessage: error, onError: true}
                });

                this.dispatchEvent(barCompleted);

                reject(error);

            });
            
        });

    }
   

    async handleStartButtonClick() {
        this.isButtonVisible = false;
        this.isButtonDisabled = false;
        console.log('<<< isButtonDisabled: ', this.isButtonDisabled);
        this.isProgressBarVisible = true;
        this.barProgress();
           
    }

    disconnectedCallback() {
        clearInterval(this._interval);
    }

    delay(time) {
        return new Promise(resolve => setTimeout(resolve, time));
    }

    async repeatControl() {

        console.log('<<< entrato in repeat Control, Attendere...');
        return new Promise(async (resolve) => {
            do {
                await this.delay(5000);
                asyncJobsControl()
                .then((result) => {
                    console.log('<<< valore di result: ', result);

                    if (result === false) {
                        this.isButtonDisabled = false;
                        console.log('<<< buttonDisabled: ', this.isButtonDisabled);
            
                    } else {
            
                        console.log('<<< delay activated');
                        this.isButtonDisabled = true;
                        this.isButtonVisible = false;
                        console.log('<<< uscito dal ciclo');
                        console.log('<<< buttonVisible: ', this.isButtonVisible);
                        return;
                    }
                    resolve(result);
                });      
            } while (this.isButtonVisible === true);
            
        });
                
    }

}