import { LightningElement, track, wire } from 'lwc';
import { CartSummaryAdapter } from "commerce/cartApi";
import Toast from 'lightning/toast';
import updateCart from '@salesforce/apex/B2B_GetInTouchController.updateCart';

export default class B2bCartCoupon extends LightningElement {

    showEnterCouponBtn = false;
    showCouponField = false;
    cartId;
    couponCodeValue = '';
    @track applyCopuonBtnDisabled = true;
    errorMessage = 'We are currently facing some issues, please contact support.';
    applyBtnLabel = 'Apply';
    showSpinner = false;
    messageState = 'Loading';
    successMsg = 'Coupon has been applied successfully';
    
    connectedCallback(){
        let isPreview = this.isInSitePreview();
        if( isPreview ){
            this.showEnterCouponBtn = true;
        }
    }
    @wire(CartSummaryAdapter, {'cartStateOrId': 'active'})
    getCartSummary({ data, error }) {
        if ( data ) {
            console.log('B2bCartCoupon getCartSummary data--- '+ data);
            this.cartId = data.cartId;
            let customFieldsList = data.customFields;
            let existingCouponCode = '';
            if( customFieldsList.length > 0 ){
                customFieldsList.forEach( ele => {
                    console.log('B2bCartCoupon ele--- '+ ele);
                    let tempMap = new Map( Object.entries( ele ) );
                    if( tempMap.has('Coupon_Code__c') ){
                        existingCouponCode = tempMap.get('Coupon_Code__c');
                    }
                });
            }
            if( existingCouponCode != '' ){
                this.couponCodeValue = existingCouponCode;
                this.applyBtnLabel = 'Applied';
                this.applyCopuonBtnDisabled = true;
                this.showEnterCouponBtn = false;
                this.showCouponField = true;
            }else{
                this.applyBtnLabel = 'Apply';
                this.applyCopuonBtnDisabled = false;
                this.showEnterCouponBtn = true;
                this.showCouponField = false;
            }
            // this.showEnterCouponBtn = true;
        } else if ( error ) {
            console.error('B2bCartCoupon getCartSummary error exception--- '+error);
            this.showEnterCouponBtn = false;
        }
    }

    handleEnterCouponCode(event) {
        //hide the enter coupon code btn
        this.showEnterCouponBtn = false;
        //show the coupon code input field
        this.showCouponField = true;
    }

    handleCouponCodeInputChange(event) {
        let tempVal = event.detail.value;
        this.couponCodeValue = tempVal.trim();
        console.log('B2bCartCoupon handleCouponCodeInputChange couponCodeValue--- '+ this.couponCodeValue);
        if( this.couponCodeValue != '' || this.couponCodeValue.length > 0 ){
            this.applyCopuonBtnDisabled = false;
            this.applyBtnLabel = 'Apply';
        }else{
            this.applyCopuonBtnDisabled = true;
        }
    }

    handleApplyCouponCode(){
        console.log('B2bCartCoupon handleApplyCouponCode couponCodeValue--- '+ this.couponCodeValue);
        if( this.couponCodeValue == '' || this.couponCodeValue == undefined ){
            //show validation error
            let errorMsg = 'Please enter a valid coupon code.';
            this.showToast('Error', errorMsg, 'dismissible', 'error');
        }else{
            this.updateCartFunc();
        }
    }

    updateCartFunc(){
        console.log('B2bCartCoupon updateCartFunc couponCodeValue--- '+ this.couponCodeValue);
        if( this.cartId && this.couponCodeValue != '' ){
            this.showSpinner = true;
            let mapParams = {
                couponCode : this.couponCodeValue,
                cartId : this.cartId
            };
            updateCart({
                'mapParams' : mapParams
            }).then((res) => {
                console.log('updateCartFunc updateCart res---- '+ JSON.stringify(res));
            if(res.isSuccess){
                this.applyBtnLabel = 'Applied';
                this.applyCopuonBtnDisabled = true;
                this.showToast('Success', this.successMsg, 'dismissible', 'success');
                this.showSpinner = false;
            }else{
                //show no data found error
                this.applyBtnLabel = 'Apply';
                this.applyCopuonBtnDisabled = false;
                this.showToast('Error', this.errorMessage, 'dismissible', 'error');
                this.showSpinner = false;
                console.error('updateCartFunc updateCart is success false---- '+ JSON.stringify(res));
            }
            }).catch((e) => {
                this.applyBtnLabel = 'Apply';
                this.applyCopuonBtnDisabled = false
                this.showToast('Error', this.errorMessage, 'dismissible', 'error');
                this.showSpinner = false;
                console.error('updateCartFunc updateCart catch---- '+ JSON.stringify(e));
            });
        }else{
            // show error
            this.showToast('Error', this.errorMessage, 'dismissible', 'error');
        }
    }

    // this.showToast('Success', this.successMsg, 'dismissible', 'success');
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

    isInSitePreview() {
        let url = document.URL;
        
        return (url.indexOf('sitepreview') > 0 
            || url.indexOf('livepreview') > 0
            || url.indexOf('live-preview') > 0 
            || url.indexOf('live.') > 0
            || url.indexOf('.builder.') > 0);
    }
}