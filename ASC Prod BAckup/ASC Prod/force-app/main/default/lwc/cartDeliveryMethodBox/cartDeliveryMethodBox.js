import { LightningElement, track, wire } from 'lwc';
import updateCartDeliveryOption from '@salesforce/apex/cartDeliveryMethodOption.updateCartDeliveryOption';

/** bug fixes SCC-33 start */
import { CheckoutInformationAdapter, CheckoutComponentBase, useCheckoutComponent } from 'commerce/checkoutApi';
import B2B_Other_Shipping_Checkout_Error_Msg from '@salesforce/label/c.B2B_Other_Shipping_Checkout_Error_Msg';
import Toast from 'lightning/toast';
const CheckoutStage = {
    CHECK_VALIDITY_UPDATE: 'CHECK_VALIDITY_UPDATE',
    REPORT_VALIDITY_SAVE: 'REPORT_VALIDITY_SAVE',
    BEFORE_PAYMENT: 'BEFORE_PAYMENT',
    PAYMENT: 'PAYMENT',
    BEFORE_PLACE_ORDER: 'BEFORE_PLACE_ORDER',
    PLACE_ORDER: 'PLACE_ORDER'
};
/** bug fixes SCC-33 end */

export default class CartDeliveryMethodBox extends useCheckoutComponent(LightningElement) {
   @track txtDeliveryOption = '';
    @track txtOrderNotes = '';

    handleDeliveryOption(event){
        this.txtDeliveryOption = event.target.value;
        console.log('txtDeliveryOption value -->',this.txtDeliveryOption);
        sessionStorage.setItem('deliveryValue', this.txtDeliveryOption); //
        //this.updateCartDelivery(); // Call method to update cart delivery option
    }
    
    handleLostFocus(){
        console.log('inside handlelost');
        this.updateCartDelivery();
    }

    updateCartDelivery() {
        const storedValue = sessionStorage.getItem('deliveryValue');
        // const storedOrderNote = sessionStorage.getItem('OrderNoteValue');
        const storedOrderNote = '';
        console.log('storedValue',storedValue);
         // If no stored value, do nothing
         if (!storedValue) {
            return;
        }
        // updateCartDeliveryOption({ deliveryOption: storedValue })
        updateCartDeliveryOption({ deliveryOption: storedValue, OrderNotes: storedOrderNote })
            .then(result => {
                // Handle success
                console.log('Cart delivery option updated successfully');
            })
            .catch(error => {
                // Handle error
                console.error('Error updating cart delivery option:', error);
            });
    }

    /** bug fixes SCC-33 start */

    enableValidation = false;
    showError = false;
    errorMessage = '';
    selectedDeliveryMethod;
    /**
     * 
     * Get the CheckoutData from the standard salesforce adapter
     * Response is expected to be 202 while checkout is starting
     * Response will be 200 when checkout start is complete and we can being processing checkout data 
     */
    @wire(CheckoutInformationAdapter, {})
    checkoutInfo({ error, data }) {
        if (!this.isInSitePreview()) {
            if (data) {
                console.log('CartDeliveryMethodBox checkoutInfo checkoutInfo: ' +JSON.stringify(data));
                let checkoutData = data;
                if( checkoutData.deliveryGroups?.items?.length > 0 ){
                    this.selectedDeliveryMethod = checkoutData.deliveryGroups?.items[0]?.selectedDeliveryMethod;
                    this.showError = false;
                    this.errorMessage = '';
                }
            } else if (error) {
                console.error('##CartDeliveryMethodBox checkoutInfo Error: ' + error);
            }
        }
    }

    /**
     * Determines if you are in the experience builder currently
     */
    isInSitePreview() {
        let url = document.URL;
        return (
        url.indexOf('sitepreview') > 0 ||
        url.indexOf('livepreview') > 0 ||
        url.indexOf('live-preview') > 0 ||
        url.indexOf('live.') > 0 ||
        url.indexOf('.builder.') > 0
        );
    }

    async stageAction(checkoutStage) {
        console.log('CartDeliveryMethodBox stageAction--- ', checkoutStage);
        switch (checkoutStage) {
            case CheckoutStage.BEFORE_PAYMENT:
                return await Promise.resolve(this.reportValidity());
            default:
                return await Promise.resolve(true);
        }
    }

    get checkValidity() {
        console.log('CartDeliveryMethodBox checkValidity enableValidation--- '+ this.enableValidation);
        if( this.selectedDeliveryMethod && 
            ( this.selectedDeliveryMethod.carrier == 'Other' || this.selectedDeliveryMethod.name == 'Other' || this.selectedDeliveryMethod.classOfService == 'Other' ) 
        ){
            if( this.txtDeliveryOption == '' || this.txtDeliveryOption.length == 0 ){
                return false;
            }else{
                return true;
            }
        }else{
            return true;
        }
    }

    async reportValidity() {
        this.showError = false;
        this.errorMessage = '';
        if (this.checkValidity) {
            //do nothing
        } else {
            this.errorMessage = B2B_Other_Shipping_Checkout_Error_Msg;
            this.showError = true;
            this.showToast('Error', this.errorMessage, 'dismissible', 'error');
            return false;
        }
        return true;
    }

    // this.showToast('Success', this.errorMessage, 'dismissible', 'error');
    // this.showToast('Error', this.errorMessage, 'dismissible', 'error');
    showToast(label, message, mode, variant){
        this.showToastMsg = false;
        Toast.show({
            label: label, //Error //Success
            message: message, //text msg
            mode: mode, //'sticky', 'dismissible'
            variant: variant //'info','success','warning','error'
        }, this);
    }

    /** bug fixes SCC-33 end */
}