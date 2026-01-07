/**
 * @description       :
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 12-15-2025
 * @last modified by  : Swati Chilap
 **/
import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import Id from "@salesforce/user/Id";
import isGuestUser from "@salesforce/user/isGuest";
import hasPermission from "@salesforce/customPermission/Guest_IP_feature";
//import USERLOCALE from '@salesforce/schema/User.LocaleSidKey';
import USERCOUNTRY from "@salesforce/schema/User.User_Country__c";
import basePath from "@salesforce/community/basePath";
import { ProductAdapter, ProductPricingAdapter } from "commerce/productApi";
import getProductAvailability from "@salesforce/apex/B2B_ProductDetailVariantsController.getProductAvailability";
//import { subscribe, MessageContext } from 'lightning/messageService';
//import COUNTRY_SELECTOR_CHANNEL from '@salesforce/messageChannel/countrySelector__c';
import ipifyURL from "@salesforce/label/c.B2B_IP_Address_URL";
import defaultCountry from "@salesforce/label/c.B2B_User_Default_Country";
import availabilityInquiry from "@salesforce/label/c.AvailabilityInquiry";
import availabilityInquiryKit from "@salesforce/label/c.AvailabilityInquiryKit";

export default class B2bProductDetailVariantsChild extends LightningElement {
  userId = Id;
  userLocale = "";
  static renderMode = "light"; // the default is 'shadow'
  @api productData;
  @api productId;
  pricingData;
  prodDataTemp;
  inventoryValue;
  showSpinner = false;
  messageState = "Loading";
  guestIpAddress;
  userCountry;

  // @wire(MessageContext)
  // messageContext;

  // connectedCallback() {
  //     this.subscribeToMessageChannel();
  // }

  // subscribeToMessageChannel(){
  //     this.subscription = subscribe(
  //         this.messageContext,
  //         COUNTRY_SELECTOR_CHANNEL,
  //         (message) => this.handleMessage(message)
  //     );
  // }

  // handleMessage(message){
  //     alert("Message : "+JSON.stringify(message));
  // }

  connectedCallback() {
    this.guestIpAddress = sessionStorage.getItem('ipAddressForGuest');
    if (isGuestUser && hasPermission && !this.guestIpAddress) {
      this.getIpData();
    }
  }

  getIpData() {
    let ipAddress;
    var request = new XMLHttpRequest();
    request.open("GET", ipifyURL, true);
    request.onload = function () {
      if (request.status >= 200 && request.status < 400) {
        ipAddress = request.responseText;
      } else {
        console.log(request.statusText);
      }
    };
    request.onerror = function () {
      console.log(request.statusText);
    };
    request.send();
    setTimeout(() => {
      sessionStorage.setItem('ipAddressForGuest', ipAddress);
      this.guestIpAddress = ipAddress;
    }, 1200);
  }

  @wire(getRecord, { recordId: Id, fields: [USERCOUNTRY] }) //fields: [USERLOCALE]
  userDetails({ error, data }) {
    if (error) {
      console.log("error =>", error);
    } else if (data) {
      //this.userLocale = data.fields?.LocaleSidKey?.value?.split('_')[1];
      this.userCountry = data.fields?.User_Country__c?.value
        ? data.fields?.User_Country__c?.value
        : defaultCountry; //?? data.fields?.MailingAddress?.value; // added by Mradul for SCC-48 Wrong delivery date on website in Jan 2025

      console.log("userCountry =>", this.userCountry);
      this.userLocale = this.userCountry === defaultCountry ? "US" : "FR";
      console.log("this.userLocale =>", this.userLocale);
    }
  }

  @wire(ProductPricingAdapter, { productId: "$productId" })
  getProductPricing(result) {
    console.log('ProductPricingAdapter ---> ', result);
    if (result.data) {
      this.pricingData = result.data;
    }
  }

  @wire(ProductAdapter, { productId: "$productId" })
  getProductDetails(result) {
    console.log("getProductDetails result------- " + result);
    if (result.data) {
      // let productClass = result.data.productClass;
      this.prodDataTemp = result.data;
      this.showSpinner = true;
      let tempthis = this;
      window.setTimeout(function () {
        tempthis.callGetProductAvailability();
      }, 2000);
    }
  }

  get sizeValue() {
    if (this.productData) {
      for (const key in this.productData.selectedAttributes) {
        let data = this.productData.selectedAttributes[key];
        if (data.apiName == "Unit_Size__c") {
          return data.value;
        }
      }
    }
    return "size";
  }

  get qtySelectorId() {
    return "quantity-varQty" + this.productId;
  }

  handleDecrement() {
    var input = document.getElementById(this.qtySelectorId);
    input.stepDown();
    this.showSpinner = true;
    this.callGetProductAvailability();
  }

  handleIncrement() {
    var input = document.getElementById(this.qtySelectorId);
    input.stepUp();
    this.showSpinner = true;
    this.callGetProductAvailability();
  }

  handleKeyUp(e) {
    this.showSpinner = true;
    this.callGetProductAvailability();
  }

  async callGetProductAvailability() {
    // if(!this.userLocale ){
    //     this.userLocale = ;
    //     console.log('basePath locale => ', this.userLocale);
    // }else{// if(!this.userLocale)
    //     console.log('inside else');
    //     this.userLocale = 'US';
    // }
    //this.userLocale = !this.userLocale && basePath.includes('-')? basePath?.substring(basePath?.lastIndexOf("/")+1, basePath?.length)?.split('-')[1] : 'US';

    //this.userLocale = !this.userLocale && isGuestUser? 'US' : 'FR';
    console.log("callGetProductAvailability userLocale ===> ", this.userLocale);
    if (!this.userLocale && isGuestUser) {
      let countryCode = sessionStorage.getItem('countryCodeForGuest');
      this.userLocale = countryCode !== null || countryCode !== undefined ? countryCode : 'US'; //"US";
    }
    // console.log(" this.userLocale ===> ", this.userLocale);
    // console.log("this.guestIpAddress => ", this.guestIpAddress);
    if (this.prodDataTemp) {
      if (!this.prodDataTemp.fields.StockKeepingUnit.includes("KIT")) {
        let mapParams = {};
        mapParams.catalogItemNumber = this.prodDataTemp.fields.Parent_Sku__c;
        mapParams.productSKU = this.prodDataTemp.fields.StockKeepingUnit;
        mapParams.inputQTY = document.getElementById(this.qtySelectorId).value;
        mapParams.countryCode = this.userLocale;
        mapParams.unitSize = this.sizeValue;
        mapParams.guestIpAddress = this.guestIpAddress;
        mapParams.userCountry = this.userCountry;
        getProductAvailability({
          mapParams: mapParams
        })
          .then((res) => {
            let response = JSON.parse(JSON.stringify(res));
            console.log(
              "B2bProductDetailVariantsChild callGetProductAvailability res---- " +
                JSON.stringify(res)
            );
            if (res.isSuccess) {
              this.inventoryValue = response.output;
              this.showSpinner = false;
            } else {
              //show no data found error
              this.inventoryValue = [];
              this.inventoryValue.push(availabilityInquiry);

              this.showSpinner = false;
              console.log(
                "B2bProductDetailVariantsChild callGetProductAvailability is success false---- " +
                  JSON.stringify(res)
              );
            }
          })
          .catch((e) => {
            this.inventoryValue = [];
            this.inventoryValue.push(availabilityInquiry);

            this.showSpinner = false;
            console.log(
              "B2bProductDetailVariantsChild callGetProductAvailability catch---- " +
                JSON.stringify(e)
            );
          });
      } else {
        this.inventoryValue = [];
        this.inventoryValue.push(availabilityInquiryKit);
        this.showSpinner = false;
      }
    } else {
      this.showSpinner = false;
    }
  }
}