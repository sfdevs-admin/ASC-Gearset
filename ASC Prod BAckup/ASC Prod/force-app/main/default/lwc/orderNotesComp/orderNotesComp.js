import { LightningElement,track } from 'lwc';
import updateCartDeliveryOption from '@salesforce/apex/cartDeliveryMethodOption.updateCartDeliveryOption';


export default class OrderNotesComp extends LightningElement {
    @track txtOrderNotes = '';
    handleOrderNotes(event){
        this.txtOrderNotes = event.target.value;
        console.log('txtOrderNotes value -->',this.txtOrderNotes);
        sessionStorage.setItem('OrderNoteValue', this.txtOrderNotes);  //
        //this.updateCartDelivery(); // Call method to update cart delivery option
    }
    
    handleLostFocus(){
        console.log('inside handlelost');
        this.updateCartDelivery();
    }

    updateCartDelivery() {
        const storedValue = sessionStorage.getItem('OrderNoteValue');
        console.log('storedValue',storedValue);
         // If no stored value, do nothing
         if (!storedValue) {
            return;
        }
        // updateCartDeliveryOption({ deliveryOption: storedValue })
        updateCartDeliveryOption({ OrderNotes: storedValue })
            .then(result => {
                // Handle success
                console.log('Cart delivery option updated successfully');
            })
            .catch(error => {
                // Handle error
                console.error('Error updating cart delivery option:', error);
            });
    }
}