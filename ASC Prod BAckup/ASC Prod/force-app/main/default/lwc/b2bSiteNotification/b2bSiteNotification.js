import { LightningElement, api } from 'lwc';
import B2B_Show_Site_Notification from '@salesforce/label/c.B2B_Show_Site_Notification';
import B2B_Site_Notification from '@salesforce/label/c.B2B_Site_Notification';

export default class B2bSiteNotification extends LightningElement {
    label = {
        B2B_Show_Site_Notification,
        B2B_Site_Notification
    };

    get showNotification() {
        let labelVal = this.label.B2B_Show_Site_Notification;
        if( labelVal && labelVal != '' ){
            labelVal = labelVal.toLowerCase(); // lowercase the string
            labelVal = labelVal.trim(); // remove trailling/leading spaces
            return labelVal === 'true';
        }else{
            return false;
        }


    }

    get notificationMessage() {
        let labelMessage = this.label.B2B_Site_Notification;
        if( labelMessage && labelMessage != '' ){
            return labelMessage;
        }else{
            return '';
        }
        
    }
}