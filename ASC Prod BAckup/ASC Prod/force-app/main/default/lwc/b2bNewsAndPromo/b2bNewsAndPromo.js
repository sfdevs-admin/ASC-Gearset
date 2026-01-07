import { LightningElement } from 'lwc';
import arrowNewsletter from '@salesforce/resourceUrl/ArrowNewsletter';

export default class B2bNewsAndPromo extends LightningElement {
    arrowNewsletterUrl = arrowNewsletter;
    email = '';

    handleChange(event) {
        this.email = event.target.value;
        console.log('Email entered:', this.email);
    }

    handleClick(event) {
        // Handle the click event
        console.log('Submit button clicked with email:', this.email);
    }
}