import { wire, api, track } from 'lwc';
import { CartSummaryAdapter } from "commerce/cartApi";
import { CheckoutComponentBase } from 'commerce/checkoutApi';
// import { getSessionContext } from 'commerce/contextApi';
import getCarrierNumberByCartId from '@salesforce/apex/CustomerCarrierNumberController.getCarrierNumberByCartId'
import setCarrierNumberByCartId from '@salesforce/apex/CustomerCarrierNumberController.setCarrierNumberByCartId';

const CheckoutStage = {
    CHECK_VALIDITY_UPDATE: 'CHECK_VALIDITY_UPDATE',
    REPORT_VALIDITY_SAVE: 'REPORT_VALIDITY_SAVE',
    BEFORE_PAYMENT: 'BEFORE_PAYMENT',
    PAYMENT: 'PAYMENT',
    BEFORE_PLACE_ORDER: 'BEFORE_PLACE_ORDER',
    PLACE_ORDER: 'PLACE_ORDER'
};


export default class CustomerCarrierNumber extends CheckoutComponentBase {
    @api errorMessage;
    isLoading=false;  
    showError=false;  
    txtCarrierNumber='' ;
    cartId;

    async getSavedData(){
        let METHOD = 'getSavedData';
        // console.log('METHOD: ' + METHOD + ' this.cartId', this.cartId);

        if (! this.cartId ) return

        this.isLoading = true;
        this.txtCarrierNumber ='';

        await getCarrierNumberByCartId({cartId : this.cartId})
        .then(result => {
            console.log(METHOD + ' result', result);
            if (result) {
                this.txtCarrierNumber = result;
            }
            
        });

        this.isLoading = false;
    }

    getDefaultValueFromDropdown(options) {
        for(let index=0; index<options.length; index++) {
            const option = options[index];
            if(option.defaultValue===true) return option.value;
        }
    }    

    async handleCarrierNumberChange(event){
        let METHOD = 'handleCarrierNumberChange';
        this.showError=false;  
        this.txtCarrierNumber=''
        this.txtCarrierNumber = event.detail.value;
        // console.log(METHOD + ' this.txtCarrierNumber', this.txtCarrierNumber);
    }

    async handleLostFocus () {
        let METHOD = 'handleLostFocus';
        // console.log(METHOD + ' this.txtCarrierNumber', this.txtCarrierNumber);

        if (! this.txtCarrierNumber || ! this.cartId) return

        // console.log(METHOD + ' this.txtCarrierNumber', this.txtCarrierNumber);
        // console.log(METHOD + ' this.cartId', this.cartId);

        await this.reportValidity();
        await this.setCarrierNumber();
    }

    @wire(CartSummaryAdapter, {'cartStateOrId': 'active'})
    setCartSummary({ data, error }) {
        // console.log('customerCarrierNumber setCartSummary this.cartId', this.cartId);
        // console.log('customerCarrierNumber setCartSummary data', data);
        // console.log('customerCarrierNumber setCartSummary error', error);
        if (this.cartId !=null) return
        if (data) {
            this.cartId = data.cartId;
            this.getSavedData();
        } else if (error) {
            console.error(error);
        }
    }

    get checkValidity() {
        // this is not a mandatory field, so... everything is valid here
        return true
    }

    async reportValidity() {
        return true;
    }
    
    async stageAction(checkoutStage) {
        console.log('stageAction checkoutStage', checkoutStage);

        switch (checkoutStage) {
            case CheckoutStage.CHECK_VALIDITY_UPDATE:
                return await Promise.resolve(this.checkValidity);
            case CheckoutStage.REPORT_VALIDITY_SAVE:
                return await Promise.resolve(this.reportValidity());
            default:
                return await Promise.resolve(true);
        }
    }

    async setCarrierNumber(){
        console.log('setCarrierNumber')
        await setCarrierNumberByCartId({
            cartId : this.cartId,
            carrierNumber : this.txtCarrierNumber
        })
        .then( async () => {
            console.log('setCarrierNumber SUCCESS');
            
        }).catch(async error => {
            console.log('setCarrierNumber ERROR: ' + JSON.stringify(error));
        });          
    }
}