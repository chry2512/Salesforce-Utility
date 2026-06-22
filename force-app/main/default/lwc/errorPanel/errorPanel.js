/**
 * @description       : Error Panel Custom Component
 * @author            : Christian Niro
 * @group             : Christian Niro(TMLAB by SPindox)
 * @last modified on  : 05-14-2024
 * @last modified by  : 
**/
import { LightningElement, api } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import noDataIllustration from './templates/noDataIllustration.html';
import inlineMessage from './templates/inlineMessage.html';
import ShowDetails from '@salesforce/label/c.ShowDetails';
import friendlyMessage from '@salesforce/label/c.friendlyMessage';

export default class ErrorPanel extends LightningElement {
    /** Single or array of LDS errors */
    @api errors;
    /** Type of error message **/
    @api type;
    /** Generic / user-friendly message */
    label = {
        ShowDetails,
        friendlyMessage
    };
    

    viewDetails = false;

    get errorMessages() {
        console.log('<<< this.errors panel3 ', this.errors);

        // use utils component reduce for error message
        return reduceErrors(this.errors);
    }

    handleShowDetailsClick() {
        // function for show details 
        this.viewDetails = !this.viewDetails;
    }

    render() {
        if (this.type === 'inlineMessage') 
        return inlineMessage;

        return noDataIllustration;
    }
}