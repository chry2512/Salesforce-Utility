/**
 * @description       : function for manage bar Progress
 * @author            : Christian Niro
 * @group             : Christian Niro
 * @last modified on  : 05-16-2024
 * @last modified by  : 
**/

import getRecords from '@salesforce/apex/ServiceProcessController.getRecords';
import sendMail from '@salesforce/apex/ServiceProcessController.sendMail';



export function toggleProgress(component) {

    component._interval = setInterval(async () => {
        
        if (component.progress < 25) {
            component.progress = component.progress + 1;
        } else {


            try {
                clearInterval(component._interval);
                
                component._interval = setInterval(async () => {
                    component.progress = component.progress + 1;
                }, 800);

                const result = await getRecords();
                clearInterval(component._interval);

                if (result.length > 0) {

                    component.records = result;
                    component.isDataLoaded = true;

                    component._interval = setInterval(() => {
                        console.log('<<< this.progress: ', component.progress);
                        component.progress = component.progress + 2;
                        if (component.progress >= 95) {

                            component.progress = component.progress - 1;
                        }

                        if (component.progress === 100) {
                            clearInterval(component._interval);

                            if (component.file == true) {
                                console.log('<<<Entro progress bar 100');
                                component.exportToXLSX()
                                    .then(() => {
                                        console.log('<<<<< then exportToXLSX');
                                      
                                        const toggleChange = new CustomEvent("togglechange", {
                                            detail: {
                                                nextToggle: true,
                                                error: false
                                            }
                                        });
                                        component.dispatchEvent(toggleChange);
                                        console.log('<<<<< event inviato');
                                    })
                                    .catch(error => {
                                        console.log("Error exporting to XLSX:", error);
                                    });
                            }

                            if (component.send == true) {
                                sendMail();
                                const toggleChange = new CustomEvent("togglechange", {
                                    detail: {
                                        nextToggle: true,
                                        error: false
                                    }
                                });
                                component.dispatchEvent(toggleChange);
                            }
                        }
                    }, 300);

                }
            } catch (error) {

                console.log("error: " + error);
                const toggleChange = new CustomEvent("togglechange", {
                    detail: {
                        nextToggle: false,
                        errorMessage: error,
                        error: true
                    }
                });
                component.dispatchEvent(toggleChange);
            }
        }
    }, 200);

}