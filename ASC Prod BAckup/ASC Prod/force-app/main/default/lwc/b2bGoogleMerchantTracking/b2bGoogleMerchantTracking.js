import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import isGuestUser from "@salesforce/user/isGuest";
import USER_ID from '@salesforce/user/Id';
import CONTACTID_FIELD from '@salesforce/schema/User.ContactId';
import createGMCRecord from '@salesforce/apex/B2B_GoogleTrackingController.createGMCRecord';

export default class B2bGoogleMerchantTracking extends LightningElement {
    _productData;
    productId;
    contactId;
    keys;

    @api
    set productData(data) {
        console.log('productData:: ', data);
        if(data != null){
            this._productData = data;
            this.productId = data.id;
            if (this.productId) {
                console.log('inside IF');
                let queryString = window.location.search;
                if (queryString && queryString.startsWith('?')) {
                    queryString = queryString.substring(1); 
                }

                if (queryString) {
                    this.createGoogleMerchantRecord(queryString);
                } 
            }
        }
    }
    get productData() {
        return this._productData;
    }

    @wire(getRecord, { recordId: USER_ID, fields: [CONTACTID_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            this.contactId = data.fields.ContactId?.value;
            console.log('contact id :: ', this.contactId);
        }
    }

    createGoogleMerchantRecord(keyValue) {
        let mapParams = {};
        mapParams.productId = this.productId;
        mapParams.gmcKey = keyValue;
        mapParams.isGuest = isGuestUser;
        mapParams.contactId = this.contactId;

        createGMCRecord({ mapParams: mapParams})
            .then ((response) => {
                console.log('response:: ', response);
            })
            .catch (error => {
                console.log('error:: ', error);
            });
    }
}