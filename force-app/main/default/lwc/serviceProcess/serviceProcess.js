/**
 * @description       :  Service Process JS
 * @author            : Christian Niro
 * @group             : Christian Niro
 * @last modified on  : 05-16-2024
 * @last modified by  : 
**/
import { LightningElement, api } from 'lwc';
import { openConfirm } from 'c/customConfirm';
import caricaFileElaborazione from '@salesforce/resourceUrl/CaricaFileElaborazione';
import IniziareCliccaStart from '@salesforce/resourceUrl/IniziareCliccaStart';
import estrazioneRecordStaging from '@salesforce/resourceUrl/EstrazioneRecordStaging';
import DescriptionSecondStep from '@salesforce/label/c.DescriptionSecondStep';
import Descrizione_Secondo_Step2 from '@salesforce/label/c.Descrizione_Secondo_Step2';
import TitleProcessoEstrazione from '@salesforce/label/c.TitleProcessoEstrazione';
import delayTitle from '@salesforce/label/c.DelayTitle';
import delayMessage from '@salesforce/label/c.DelayMessage';
import Send_Email from '@salesforce/label/c.Send_Email';
import Enabled from '@salesforce/label/c.Enabled';
import Disabled from '@salesforce/label/c.Disabled';
import Download_File from '@salesforce/label/c.Download_File';
import Previous from '@salesforce/label/c.Previous';
import Next from '@salesforce/label/c.Next';
import Grazie from '@salesforce/label/c.Grazie';
import Processo from '@salesforce/label/c.Processo'; 
import AMP_Start from '@salesforce/label/c.Start';
import AvvioProcessoHeader from '@salesforce/resourceUrl/AvvioProcessoHeader';
//import AMP_SixthStepThanks from '@salesforce/label/c.AMP_SixthStepThanks';
//import 	AMP_DownloadReport from '@salesforce/label/c.AMP_DownloadReport';
//import getBatchStatus from '@salesforce/apex/AMP_ServiceCreationController.getBatchStatus'; 
//-----Aggiunta
//import deleteAsyncAndLogs from '@salesforce/apex/AMP_ServiceCreationController.deleteAsyncAndLogs';



export default class ServiceProcess extends LightningElement {

    //>>>>>>>>>>>>>>>>>tutto il codice commentato è da eliminare
    //variabili per la gestione della progressBar
    @api send = false;
    @api file = false;
    errorMessage;
 
 
    //variabili per la gestione dei bottoni Previous e Next
    nextToggle = false;
    previousToggle = false;
 
 
    label = {
       TitleProcessoEstrazione,
       DescriptionSecondStep,
       Descrizione_Secondo_Step2,
       Send_Email,
       Enabled,
       Disabled,
       Download_File,
       Previous,
       Next,
       Grazie,
       Processo,
       AMP_Start,
       delayTitle,
       delayMessage
       //AMP_SixthStepThanks,
       //AMP_DownloadReport
    };
 
    //variabili per l'assegnazione delle immagini
 
    iniziareCliccaStart = IniziareCliccaStart;
    estrazioneRecordStaging = estrazioneRecordStaging;
    caricaFileElaborazione = caricaFileElaborazione;
    AvvioProcessoHeader = AvvioProcessoHeader;
 
    
    //variabili per il passaggio da uno step all'altro della UI
    current = "1";
    error = false;
    firstStep = true;
    secondStep = false;
    secondStepWithBar = false;
    forthStepWithBar = false;
    secondStepNoBar = false;
    thirdStep = false;
    forthStep = false;
    fifthStep = false;
    barProgress = false;
    sixthStep = false;
 
 
    //variabili per gestione schermate fine download
    downloadSuccess = false;
    downloadError = false;
    completed = false;
    downloadOperableDisabled = true;
    downloadOperable = false;
    downloadReport = false;
 
    //variabili Error Manage
    onError = false;
    errorMessage;
    forthStepSuccess = false;
 
 
    //toggle first step
    toggleActiveTest = false;
    checkedFirst = false;
    checkedSecond = false;
    checkedThird = false;


    connectedCallback() {
    
        console.log("<<connectedCallback");
        const savedStep = localStorage.getItem('currentStep');

        this._interval = setInterval(() => {
            const element = document.querySelector('body').classList;
           
            if(element.contains('slds-wcag')){
                console.log("<<  overflow connected callBack");
                element.remove('slds-wcag');
                clearInterval(this._interval);
            }

        }, 1);  
  
        if (savedStep) {
            this.current = savedStep;
    
            switch (this.current) {
    
                case "3":
    
                    this.firstStep = false;
                    this.secondStep = false;
                    this.thirdStep = true;
    
                    break;
    
                case "4":
    
                    this.firstStep = false;
                    this.secondStep = false;
                    this.thirdStep = false;
                    this.forthStep = true;
    
                    break;
    
                case "5":
    
                    this.firstStep = false;
                    this.secondStep = false;
                    this.thirdStep = false;
                    this.forthStep = false;
                    this.fifthStep = true;
    
                    break;
    
                case "6":
                    this.firstStep = false;
                    this.secondStep = false;
                    this.thirdStep = false;
                    this.forthStep = false;
                    this.fifthStep = false;
                    this.sixthStep = true;
    
            }
        }
    }

    
    
    // Pass to next step from start page --> ok
    start() {
    
        this.firstStep = false;
    
        if (this.checkedFirst) {
    
            this.current = "5";
            this.forthStep = false;
            this.forthStepSuccess = false;
            this.onError = false;
            this.barProgress = false;
            this.previousToggle = false;
            this.nextToggle = false;
            this.fifthStep = true;
    
        } else if (this.checkedSecond) {
    
            this.current = '3';
            this.nextToggle = false;
            this.previousToggle = false;
            this.thirdStep = true;
            this.secondStep = false;
    
        } else if (this.checkedThird) {
    
            this.current = '2';
            this.secondStep = true;
            this.secondStepWithBar = false;
            this.secondStepNoBar = true;
            this.previousToggle = true;
        }
    
    }
    
    
    nextStep() {
        console.log('<<<<<StepCurrent', this.current);
    
        if (this.current === "2" && (this.file || this.send)) {
            console.log('<<<<secondo Step');
            this.secondStepWithBar = true;
            this.secondStepNoBar = false;
            this.nextToggle = false;
            this.previousToggle = false;
            this.thirdStep = false;
            this.secondStep = true;
        } else if (this.current === "3") {
            console.log('<<<<forthstep', this.forthStep);
            this.current = "4";
            this.nextToggle = false;
            this.thirdStep = false;
            this.forthStep = true;
    
        } else if (this.current === "4") {
            console.log('<<<<entrato nel quintoStep');
            this.current = "5";
            this.forthStep = false;
            this.forthStepSuccess = false;
            this.onError = false;
            this.barProgress = false;
            this.previousToggle = false;
            this.nextToggle = false;
            this.fifthStep = true;
        } else if (this.current === "5") {
    
            console.log('<<< entrato nel sesto Step');
            this.current === "6";
            this.fifthStep = false;
            this.nextToggle = true;
            this.downloadOperable = true;
            this.sixthStep = true;
        }
    }
    
    
    previousStep() {
        if (this.current === "6") {
            // funziona per tornare allo start
            if (this.downloadReport === false) {
    
                this.sixthStep = false;
                this.fifthStep = false;
                this.current = "1";
                this.firstStep = true;
            }
        } else if (this.current === "5") {
    
            this.current = "4";
            this.fifthStep = false;
            this.forthStep = true;
    
        } else if (this.current === "4") {
    
            this.current = "3";
            this.thirdStep = true;
            this.forthStep = false;
    
        } else if (this.current === "2") {
    
            this.current = "1";
            this.secondStep = false;
            this.secondStepNoBar = false;
            this.downloadError = false;
            this.firstStep = true;
        }
    }
    
    
    downloadFileToggle() {
    
        this.file = !this.file;
    
        console.log('<<< this.file: ', this.file);
    
        if (this.file == true || this.send == true) {
            this.nextToggle = true;
        } else {
            this.nextToggle = false;
        }
    }

       
    sendEmailToggle() {
    
        this.send = !this.send;
    
        console.log('<<< this.send: ', this.send);
    
        if (this.send == true || this.file == true) {
            this.nextToggle = true;
        } else {
            this.nextToggle = false;
        }
    }
    
    
    afterExtraction(event) {
        console.log("<<< afterExtraction");
        this.secondStepWithBar = false;
    
        if (event.detail.nextToggle && !event.detail.error) {
            // Schermata di successo
            console.log('Record trovati');
            this.downloadSuccess = true;
            this.downloadError = false;
            this.previousToggle = false;
    
            const tm = setTimeout(() => {
                this.confirmProcess();
            }, 1000);
    
        } else if (!event.detail.nextToggle && event.detail.error) {
            // Schermata di errore
            console.log('Errore');
            this.downloadError = true;
            this.previousToggle = true;
            this.errorMessage = event.detail.errorMessage;
        }
    
    }
    
 
    async confirmProcess(event) {
 
 
       console.log("sono entrato nel confirmProcess");
 
        const result = await openConfirm({
            modalTitle: 'Please Confirm',
            modalMessage: 'Sei sicuro di voler processare questi records?'
        });
 
       console.log("ho passato l'open");
 
 
        if (result) {
            console.log("true--> accettato");
            localStorage.setItem('currentStep', '4');
            this.downloadSuccess = false;
            this.current = '4';
            this.forthStep = true;
            this.nextToggle = false;
            this.secondStep = false;
    
        } else {
            console.log("false--> rifiutato");
            localStorage.setItem('currentStep', '3');
            this.downloadSuccess = false;
            this.current = '3';
            this.thirdStep = true;
            this.secondStep = false;
        }
    }
 
 
    uploadEvent(event) {
 
       this.nextToggle = event.detail.success;
        if (event.detail.success) {
 
          console.log("THIS CURRENT", this.current);
 
            if (this.current === '3') {

                this.thirdStep = true;
                his.nextToggle = true;
                
            } else {
                this.nextToggle = true;

                if (this.downloadReport === true) {
                    this.previousToggle = true;
                }

                this.fifthStep = false;
                this.sixthStep = true;
                this.current = '6';
                localStorage.setItem('currentStep', '6');
                //this.checkBatchStatus();
            }
        }
    }
 
 
    barCompletition(event) {
       console.log("entra nel barCompletition");
 
        if (event.detail.barProgress) {
    
            console.log("Messaggio di Deleay Bar progress");
            this.barProgress = event.detail.barProgress;
    
        } else if (event.detail.onError) {

            console.log(event.detail.errorMessage);
            this.onError = event.detail.onError;
            this.errorMessage = event.detail.errorMessage;
            this.barProgress = false;

        } else {

            this.forthStepSuccess = true;
            this.barProgress = false;
            
        }
 
        this.nextToggle = true;
        this.previousToggle = true;
    }
 
    downloadReportClick() {
 
       console.log("entro nel downloadReport");
       localStorage.clear();
       this.downloadReport = true;
       const vfUrl = `/apex/AMP_ReportPage`;
       window.open(vfUrl, '_blank');
    }
 
 
    async checkBatchStatus() {
 
       /* while (true) {
          console.log("---------------- Esecuzione checkBatchStatus ---------------");
          // Chiama il metodo del controller per controllare lo stato del batch
          const batchStatus = await getBatchStatus({
            batchName: 'EPCProductAttribJSONBatchJob'
          });
 
          if (batchStatus === 'Completed') {
            console.log("batch completato");
            this.downloadOperable = true;
            this.nextToggle = true;
            break;
          } else if (batchStatus === 'Error') {
            this.downloadOperable = true;
            this.nextToggle = false;
            console.log("ERROR: Batch AmplifonServiceCreationSingleBatch--> EPCProductAttribJSONBatchJob")
            break;
          }
 
          await this.delayFunction(10000);
        }*/
 
    }
 
 
    async delayFunction(ms) {
       return new Promise(resolve => setTimeout(resolve, ms));
    }
 
 
    testToggles(event) {
       console.log("-----------------------")
       console.log("toggle click");
       const name = event.target.name;
       console.log('Name:', name);

        switch (name) {
    
            case "toggle-Pricing":
                localStorage.setItem('currentStep', '5');
                this.checkedFirst = !this.checkedFirst;
                this.checkedSecond = false;
                this.checkedThird = false;
                break;
    
            case "toggle-Input":
                localStorage.setItem('currentStep', '3');
                this.checkedSecond = !this.checkedSecond;
                this.checkedFirst = false;
                this.checkedThird = false;
                break;
    
            case "toggle-Extract":
                this.checkedThird = !this.checkedThird;
                this.checkedFirst = false;
                this.checkedSecond = false;
    
        }
 
        if ((this.checkedFirst || this.checkedSecond || this.checkedThird)) {
            this.toggleActiveTest = true;
        } else {
            this.toggleActiveTest = false;
        }

    }
 
 
    resetCache() {
       localStorage.clear();
       location.reload();
       //deleteAsyncAndLogs();
      
    }
    
    disconnectedCallback() {
        console.log("disconnectedCallback");
        clearInterval(this._interval);
    }

}