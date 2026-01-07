import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import TECHNOTEURL_FIELD from '@salesforce/schema/Product2.Technical_Notes_URL__c';
import SDSURLCH_FIELD from '@salesforce/schema/Product2.SDS_URL_CH__c';
import SDSURLCN_FIELD from '@salesforce/schema/Product2.SDS_URL_CN__c';
import SDSURLFR_FIELD from '@salesforce/schema/Product2.SDS_URL_FR__c';
import SDSURLGB_FIELD from '@salesforce/schema/Product2.SDS_URL_GB__c';
import SDSURLKR_FIELD from '@salesforce/schema/Product2.SDS_URL_KR__c';
import SDSURLUS_FIELD from '@salesforce/schema/Product2.SDS_URL_US__c';

import SDSURLDE_FIELD from '@salesforce/schema/Product2.SDS_URL_DE__c';

import B2B_TechnicalNoteTab from '@salesforce/label/c.B2B_TechnicalNoteTab';
import B2B_SdsTab from '@salesforce/label/c.B2B_SdsTab';
import B2B_TechPageUrl from '@salesforce/label/c.B2B_TechPageUrl';
import B2B_SdsPageUrl from '@salesforce/label/c.B2B_SdsPageUrl';
import B2B_Technical_Note_Msg from '@salesforce/label/c.B2B_Technical_Note_Msg';
import B2B_SDS_Msg from '@salesforce/label/c.B2B_SDS_Msg';
import getProductRecord from "@salesforce/apex/Tech_SdsController.getProductRecord";
import { ProductAdapter } from 'commerce/productApi';

export default class B2bProductRelatedDocument extends NavigationMixin(LightningElement) {

    @api tabName;
    @track productId;
    @track technicalNotesURL;
    @track sdsUrlCH;
    @track sdsUrlCN;
    @track sdsUrlFR;
    @track sdsUrlGB;
    @track sdsUrlKR;
    @track sdsUrlUS;

    @track sdsUrlDE;

    @track sdsUrl;
    @track sdsUrlOther;
    @track techNoteTab = false;
    @track techNoteTabError = false;
    @track sdsTab = false;
    @track sdsTabError = false;
    @track showPreview = false;
    @track previewURL;
    @track erroredOut= false;
    @track errorMsg;
    @track techPage = false;
    @track sdsPage = false;
    @track techUrl;
    productData;

    label = {B2B_Technical_Note_Msg, B2B_SDS_Msg};

    @wire(CurrentPageReference)
    getPageRef(res){
                if(this.tabName == B2B_TechPageUrl){
                    this.techPage = true;
                }
                if(this.tabName == B2B_SdsPageUrl){
                    this.sdsPage = true;
                }
        this.productId = res.attributes.recordId;  
    }

    @wire(ProductAdapter, { productId: '$productId' })
    getProdDetails({ error, data })
    {
        if(error){
            console.log('getProdDetails Error => '+ JSON.stringify(error));
        }else{
            if(data != undefined){
                this.productData = data;
                let productClass = this.productData?.productClass;
                let variationParentId = this.productData?.variationParentId;
                if(this.productId && variationParentId && productClass === 'Variation'){
                    this.productId = variationParentId;
                }
            }
        }
    }

    @wire(getRecord, { recordId: "$productId", fields: [TECHNOTEURL_FIELD, SDSURLCH_FIELD, SDSURLCN_FIELD, SDSURLFR_FIELD, SDSURLGB_FIELD, SDSURLKR_FIELD, SDSURLUS_FIELD, SDSURLDE_FIELD]}) 
    wireProduct({ error, data }) {
        if(this.productId){
            if (error) {
                console.log('error => ',error);
                this.erroredOut = true;
                this.errorMsg = error;
            } else if (data) {
                this.technicalNotesURL = data?.fields?.Technical_Notes_URL__c?.value;
                if(this.tabName == B2B_TechnicalNoteTab && this.technicalNotesURL){
                    this.techNoteTab = true;
                }
                if(this.tabName == B2B_TechnicalNoteTab && !this.technicalNotesURL){
                    this.techNoteTabError = true;
                }

                this.sdsUrlUS = data?.fields?.SDS_URL_US__c?.value;

                this.sdsUrlDE = data?.fields?.SDS_URL_DE__c?.value;

                this.sdsUrlGB = data?.fields?.SDS_URL_GB__c?.value;
                this.sdsUrlOther = !(this.sdsUrlUS || this.sdsUrlOther) && this.sdsUrlGB ? this.sdsUrlGB : this.sdsUrlOther;
                this.sdsUrlCH = data?.fields?.SDS_URL_CH__c?.value;
                this.sdsUrlOther = !(this.sdsUrlUS || this.sdsUrlOther) && this.sdsUrlCH ? this.sdsUrlCH : this.sdsUrlOther;
                this.sdsUrlCN = data?.fields?.SDS_URL_CN__c?.value;
                this.sdsUrlOther = !(this.sdsUrlUS || this.sdsUrlOther) && this.sdsUrlCN ? this.sdsUrlCN : this.sdsUrlOther;
                this.sdsUrlFR = data?.fields?.SDS_URL_FR__c?.value;
                this.sdsUrlOther = !(this.sdsUrlUS || this.sdsUrlOther) && this.sdsUrlFR ? this.sdsUrlFR : this.sdsUrlOther;
                this.sdsUrlKR = data?.fields?.SDS_URL_KR__c?.value;
                this.sdsUrlOther = !(this.sdsUrlUS || this.sdsUrlOther) && this.sdsUrlKR ? this.sdsUrlKR : this.sdsUrlOther;

                if(this.tabName == B2B_SdsTab && (this.sdsUrlUS || this.sdsUrlOther)){
                    this.sdsTab = true;
                    this.sdsUrl = this.sdsUrlUS ? this.sdsUrlUS : this.sdsUrlOther;
                }
                if(this.tabName == B2B_SdsTab && !(this.sdsUrlUS || this.sdsUrlOther )){
                    this.sdsTabError = true;
                }
            }
        }
    }

    handleTechSerach() {
        const techValue = this.template.querySelector('.tech-note').value; // Retrieve the SKU entered by the user
        console.log('entered sku tech',techValue);

        getProductRecord({ sku: techValue })
            .then(result => {
                // Assuming getProductRecord returns the product record
                const productId = result.Id;
                this.productId = productId;
                this.technicalNotesURL = result.Technical_Notes_URL__c;
                console.log('techUrl',this.technicalNotesURL);
            })
            .catch(error => {
                console.error('Error fetching product record:', error);
            });
    }

    handleSdsSerach(){
        const sdsValue = this.template.querySelector('.sds-note').value; // Retrieve the SKU entered by the user
        console.log('entered sku sds',sdsValue);

        getProductRecord({ sku: sdsValue })
            .then(result => {
                console.log('result',result);
                // Assuming getProductRecord returns the product record
                this.sdsUrlCH = result.SDS_URL_CH__c;
                this.sdsUrlCN = result.SDS_URL_CN__c;
                this.sdsUrlFR = result.SDS_URL_FR__c;
                this.sdsUrlGB = result.SDS_URL_GB__c;
                this.sdsUrlKR = result.SDS_URL_KR__c;
                this.sdsUrlUS = result.SDS_URL_US__c;
            })
            .catch(error => {
                console.error('Error fetching product record:', error);
            });
    }

    previewHandler(){
        console.log('URL => ',event.target.dataset.value);
        this.showPreview = true;
        this.previewURL = event.target.dataset.value;
        window.open(event.target.dataset.value,'_blank');
        
    }

    hideModalBox() {  
        this.showPreview = false;
    }

}