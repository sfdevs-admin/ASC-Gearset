import { LightningElement } from 'lwc';
import copyrightFooter from '@salesforce/label/c.b2b_Copyright_Footer';

export default class B2bAscensusCopyrightFooter extends LightningElement {
    
    copyrightFooterText;
    connectedCallback() {
        var currentYear = new Date().getFullYear();
        this.copyrightFooterText = currentYear + ' ' +copyrightFooter;
    } 
}