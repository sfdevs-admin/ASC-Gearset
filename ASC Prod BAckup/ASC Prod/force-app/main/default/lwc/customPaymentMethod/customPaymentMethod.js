import { wire, api, track } from 'lwc';
import { CartSummaryAdapter } from "commerce/cartApi";
import { CheckoutComponentBase, CheckoutInformationAdapter, simplePurchaseOrderPayment } from 'commerce/checkoutApi';
import { refreshCartSummary } from "commerce/cartApi";
import { getSessionContext } from 'commerce/contextApi';
import { NavigationMixin } from "lightning/navigation";
import getPaymentMethodsByAccountId from '@salesforce/apex/CustomPaymentController.getPaymentMethodsByAccountId'
import setPaymentMethod from '@salesforce/apex/CustomPaymentController.setPaymentMethod';
import setPurchaseOrderNumberByCartId from '@salesforce/apex/CustomPaymentController.setPurchaseOrderNumberByCartId';

const CheckoutStage = {
    CHECK_VALIDITY_UPDATE: 'CHECK_VALIDITY_UPDATE',
    REPORT_VALIDITY_SAVE: 'REPORT_VALIDITY_SAVE',
    BEFORE_PAYMENT: 'BEFORE_PAYMENT',
    PAYMENT: 'PAYMENT',
    BEFORE_PLACE_ORDER: 'BEFORE_PLACE_ORDER',
    PLACE_ORDER: 'PLACE_ORDER'
};

const paymentOption = {
    CREDIT_CARD : 'Credit Card',
    PO_NUMBER : 'PO Number',
    EITHER : 'Either'
}

export default class CustomBillingAddress extends NavigationMixin(CheckoutComponentBase){
    
    @api errorMessage;
    isLoading=false;  
    showError=false;  
    txtPurchaseOrderNumber = null;
    cmbPaymentValue = null ;
    accountPaymentMethodId
    @track lstPaymentMethods
    rdbPaymentValue = null;
    @track lstPaymentOptions;

    effectiveAccountId = null;


    async handlePurchaseOrderNumberChange(event){
        let METHOD = 'handlePurchaseOrderNumberChange';
        this.showError=false;  
        this.txtPurchaseOrderNumber=null
        this.txtPurchaseOrderNumber = event.detail.value;
        // console.log(METHOD + ' this.txtPurchaseOrderNumber', this.txtPurchaseOrderNumber);
    }

    async handleLostFocus () {

        // if (! this.txtPurchaseOrderNumber || ! this.cartId) {
        //     this.reportValidity()
        //     return;
        // }

        // // await this.reportValidity();
        // await this.setPurchaseOrderNumber();
        this.cmbPaymentValue = null
        // // Do this reload just to update the Checkout notification component
        // this.windowReload();
    }

    async connectedCallback() {

        this.effectiveAccountId = await this.getEffectiveAccountId();

        this.loadPickList();
    }

    async getEffectiveAccountId() {
        let result = null;
        await getSessionContext()
            .then((response) => {
                result = response.effectiveAccountId;
            })
            .catch((error) => {
                console.error(error);
            });
        return result;
    }

    handleRadioPaymentValue(event){
        let METHOD = 'handleRadioPaymentValue';
        this.showError=false;  
        this.rdbPaymentValue = null 
        this.rdbPaymentValue = event.detail.value;
    }

    get isCreditCardOption(){
        return this.rdbPaymentValue == paymentOption.CREDIT_CARD;
    }

    get isCreditCardPurchaseOption(){
        return this.rdbPaymentValue == paymentOption.PO_NUMBER;
    }

    get customVisibility(){
        if (this.lstPaymentOptions?.length == 1) return 'hide-component';
    }


    async loadPickList(){
        let METHOD = 'loadPickList';
        this.isLoading = true;

        let strPickList = ['PaymentOptions__c' , 'AccountPaymentMethodId__c'];
        let objFilter = {
            pickListFields : strPickList
        };

        await getPaymentMethodsByAccountId({
            accountId : this.effectiveAccountId, 
            strFilter : JSON.stringify(objFilter)
        }).then(result => {
            let newResult = JSON.parse(JSON.stringify(result))
            
            if (! newResult) return;

            // console.log(METHOD + ' newResult', newResult);

            this.lstPaymentMethods = newResult?.AccountPaymentMethodId__c;

            let paymentValue = JSON.parse(JSON.stringify(newResult?.PaymentOptions__c));

            this.lstPaymentOptions= this.setCustomerPaymentOption(paymentValue);
            
            this.cmbPaymentValue = this.getDefaultValueFromDropdown(this.lstPaymentMethods);

            // this.rdbPaymentValue = this.getDefaultValueFromDropdown(this.lstPaymentOptions);
            if (this.lstPaymentOptions.length == 1) this.rdbPaymentValue = this.lstPaymentOptions[0].label

            // If this option is defined, it means the radio button selected here
            if (this.cmbPaymentValue) this.rdbPaymentValue = paymentOption.CREDIT_CARD;
            // But if we have the real PoNumber Saved, that is the real option
            if (newResult?.savedPoNumber) {
                this.rdbPaymentValue = paymentOption.PO_NUMBER;
                this.txtPurchaseOrderNumber = newResult.savedPoNumber[0].value;
            }

        });

        this.isLoading = false;
    }

    setCustomerPaymentOption(customerPaymentOption){
        let availableList = []

        customerPaymentOption.forEach(paymentOpt => {
            // if (availableList.length == 0){
                // By mistake, the user could select all the option, or different ones instead of either
                // due to that  
            if (paymentOpt.label == paymentOption.EITHER){
                availableList.push(this.getDropDownValue(paymentOption.CREDIT_CARD));
                availableList.push(this.getDropDownValue(paymentOption.PO_NUMBER));
            } else if (paymentOpt.label == paymentOption.CREDIT_CARD){
                availableList.push(this.getDropDownValue(paymentOption.CREDIT_CARD));
            } else {
                availableList.push(this.getDropDownValue(paymentOption.PO_NUMBER));
            }    
            // }
        })

        return availableList;
    }

    getDropDownValue(ddlValue){
        return {label : ddlValue, value: ddlValue}
    }

    get noPaymentOptions(){
        return this.lstPaymentOptions?.length == 0
    }

    getDefaultValueFromDropdown(options) {
        for(let index=0; index<options.length; index++) {
            const option = options[index];
            if(option.defaultValue===true) return option.value;
        }
    }    

    async handlePaymentMethodChange(event){
        this.showError=false;  
        this.cmbPaymentValue = null
        this.cmbPaymentValue = event.detail.value;
        // await this.reportValidity();
        // await this.setAccountPayment();
        // Do this reload just to update the Checkout notification component
        // this.windowReload();
        this.txtPurchaseOrderNumber = null;
    }

    windowReload(){
        // window.location.reload();
    }

    cartId;
    @wire(CartSummaryAdapter, {'cartStateOrId': 'active'})
    setCartSummary({ data, error }) {
        // console.log('customPaymentMethod setCartSummary this.cartId', this.cartId);
        // console.log('customPaymentMethod setCartSummary data', data);
        // console.log('customPaymentMethod setCartSummary error', error);
        if (this.cartId !=null) return
        if (data) {
            this.cartId = data.cartId;
        } else if (error) {
            console.error(error);
        }
    }

    get checkValidity() {
        let METHOD = 'checkValidity';
        let validPaymentCheck = (this.cmbPaymentValue != null && this.cmbPaymentValue != '') || (this.txtPurchaseOrderNumber != null && this.txtPurchaseOrderNumber != '' && this.txtPurchaseOrderNumber != ' ' );
        return this.rdbPaymentValue != null && validPaymentCheck && this.noPaymentOptions == false;
    }

    async reportValidity() {
        this.showError = false;
        this.errorMessage = '';
        if (this.checkValidity) {
            // await this.setAccountPayment();
            // Do this reload just to update the Checkout notification component
            // window.location.reload();
        } else {
            this.showError = true;
            this.errorMessage = 'Please select a payment method';
            this.dispatchUpdateErrorAsync({
                groupId: 'Payment Methods',
                type: '/commerce/errors/checkout-failure',
                exception: this.errorMessage,
            });
            return false;
        }
        return true;
    }
    
    async stageAction(checkoutStage) {
        console.log('stageAction payment cmp -', checkoutStage);

        switch (checkoutStage) {
            case CheckoutStage.CHECK_VALIDITY_UPDATE:
                return await Promise.resolve(this.checkValidity);
            case CheckoutStage.REPORT_VALIDITY_SAVE:
                return await Promise.resolve(this.reportValidity());
            case CheckoutStage.BEFORE_PAYMENT:
                return await Promise.resolve(this.beforePaymentProcess());
            case CheckoutStage.PAYMENT:
                return await Promise.resolve(this.paymentProcess());
            default:
                return await Promise.resolve(true);
        }
    }

    /**
     * Determines if you are in the experience builder currently
     */
    isInSitePreview() {
        let url = document.URL;

        return (
            url.indexOf("sitepreview") > 0 ||
            url.indexOf("livepreview") > 0 ||
            url.indexOf("live-preview") > 0 ||
            url.indexOf("live.") > 0 ||
            url.indexOf(".builder.") > 0
        );
    }

    @wire(CheckoutInformationAdapter, {})
    checkoutInfo({ error, data }) {
        this.isPreview = this.isInSitePreview();
            if (!this.isPreview) {
                this.isLoading = true;
                if (data) {
                    this.checkoutId = data.checkoutId;
                    this.shippingAddress = data.deliveryGroups.items.deliveryAddress;
                    if (data.checkoutStatus == 200) {
                        this.isLoading = false;
                    }
                } else if (error) {
                    console.log("##payments checkoutInfo Error: " + error);
                }
            } else {
                this.isLoading = false;
            }
    }

    @api
    async paymentProcess() {

        if (!this.reportValidity()) {
            throw new Error('Required payment is missing');
        }

        let address = this.shippingAddress;
        let purchaseOrderInputValue = 'DefaultPoNumber';
        if(this.txtPurchaseOrderNumber && this.txtPurchaseOrderNumber !== "") {
            purchaseOrderInputValue = this.txtPurchaseOrderNumber;
        }

        // set PO Number
        let po = await simplePurchaseOrderPayment(this.checkoutId, purchaseOrderInputValue, address);

        const orderConfirmation = await this.dispatchPlaceOrderAsync();
        if (orderConfirmation.orderReferenceNumber) {
            refreshCartSummary();
            this.navigateToOrder(orderConfirmation.orderReferenceNumber);
        } else {
            throw new Error("Required orderReferenceNumber is missing");
        }
    }

    /**
     * Naviagte to the order confirmation page
     * @param navigationContext lightning naviagtion context
     * @param orderNumber the order number from place order api response
     */
        navigateToOrder(orderNumber) {
            this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: "Order"
            },
            state: {
                orderNumber: orderNumber
            }
            });
        }

    async setAccountPayment(){
        // console.log('setAccountPayment')
        await setPaymentMethod({
            cartId : this.cartId,
            accountPaymentMethodId : this.cmbPaymentValue,
            paymentValue: this.rdbPaymentValue
        })
        .then( async () => {
            console.log('setAccountPayment SUCCESS');
            this.isPaymentUpdate = true;
        }).catch(async error => {
            console.log('setAccountPayment ERROR: ' + JSON.stringify(error));
            this.isPaymentUpdate = false;
        });          
    }

    async setPurchaseOrderNumber(){
        await setPurchaseOrderNumberByCartId({
            cartId : this.cartId,
            purchaseOrder : this.txtPurchaseOrderNumber,
            paymentValue: this.rdbPaymentValue
        })
        .then( async () => {
            console.log('setPurchaseOrderNumber SUCCESS');
            this.isPaymentUpdate = true;
        }).catch(async error => {
            console.log('setPurchaseOrderNumber ERROR: ' + JSON.stringify(error));
            this.isPaymentUpdate = false;
        });          
    }

    isPaymentUpdate = false;
    async beforePaymentProcess(){
        if (!this.reportValidity()) {
            throw new Error('Required payment is missing');
        }

        //check selected payment option
        let isCreditCardOrder = false;
        if( this.txtPurchaseOrderNumber != null && this.txtPurchaseOrderNumber != '' && this.txtPurchaseOrderNumber != ' ' ){
            isCreditCardOrder = false;
        }else {
            isCreditCardOrder = true;
        }

        //for PO payment
        if( ! isCreditCardOrder ){
            let isSuccess = await this.setPurchaseOrderNumber();
            console.log('PO before payment complete--- '+this.isPaymentUpdate);
            return this.isPaymentUpdate;
        }else{
            //for credit card payment
            let isSuccess = await this.setAccountPayment();
            console.log('Credit card before payment complete--- '+this.isPaymentUpdate);
            return this.isPaymentUpdate;
        }
    }
}