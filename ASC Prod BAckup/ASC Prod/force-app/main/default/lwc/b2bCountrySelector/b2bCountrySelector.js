/**
 * @description       :
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 11-12-2025
 * @last modified by  : Swati Chilap
 **/
import { LightningElement, track, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import isGuestUser from "@salesforce/user/isGuest";
import hasPermission from "@salesforce/customPermission/Guest_IP_feature";
import getInitData from "@salesforce/apex/B2B_CountrySelectorController.getInitData";
import updateUserRelatedRecords from "@salesforce/apex/B2B_CountrySelectorController.updateUserRelatedRecords";
import updateCountryInOrgCache from "@salesforce/apex/B2B_CountrySelectorController.updateCountryInOrgCache";
import defaultCountry from "@salesforce/label/c.B2B_User_Default_Country";
import defaultCurrencyCode from "@salesforce/label/c.B2B_User_Default_CurrencyIsoCode";
import ipifyURL from "@salesforce/label/c.B2B_IP_Address_URL";
import ipinfoURL from "@salesforce/label/c.B2B_IP_Info_URL";
import basePath from "@salesforce/community/basePath";
import currentLanguage from "@salesforce/i18n/lang";

import B2B_SITE_URL from "@salesforce/label/c.B2B_SITE_URL";

const SHOWPANELCSSCLASS =
  "slds-panel slds-panel_docked slds-panel_docked-right slds-is-open overlay overlay-content";
const HIDEPANELCSSCLASS =
  "slds-panel slds-panel_docked slds-panel_docked-right";

import { deleteCurrentCart } from "commerce/cartApi";

import USERCUSTOMCOUNTRY from "@salesforce/schema/User.User_Country__c";
import USERCOUNTRY from "@salesforce/schema/User.Country";
import Id from "@salesforce/user/Id";
import { getRecord } from "lightning/uiRecordApi";

export default class B2bCountrySelector extends NavigationMixin(
  LightningElement
) {
  @track showhidePanelClass = HIDEPANELCSSCLASS;
  @track countryOptions = [];
  @track currentUser;
  @track currencyIsoCode;
  @track oldCurrencyIsoCode;
  @track showCountryList = false;
  @track selectedCountryName;
  @track showSpinner = true;
  messageState = "Loading";
  guestIpAddress;
  guestCountryInfo;

  loggedinUserCountryEmpty = false;
  @wire(getRecord, { recordId: Id, fields: [USERCOUNTRY, USERCUSTOMCOUNTRY] }) //fields: [USERLOCALE]
    userDetails({ error, data }) {
      if (data) {
        console.log('uer details::: ', data);
        const userCountryField = data.fields?.User_Country__c?.value;
        const countryField = data.fields?.Country?.value;

        if (!userCountryField || !countryField) {
            this.loggedinUserCountryEmpty = true;
            deleteCurrentCart();
            this.getIpData();
        } else {
            this.loggedinUserCountryEmpty = false;
        }
      }
    }

  connectedCallback() {
    // console.log("hasPermission =>", hasPermission);
    // console.log("b2bCountrySelector basePath =>", basePath);
    // console.log("b2bCountrySelector currentLanguage =>", currentLanguage);

    if (isGuestUser && hasPermission) {
      this.getIpData();
    } else {
        const currentUrl = window.location.pathname;
        if (currentUrl && currentLanguage === "en-DE") {
          const restOfUrl = currentUrl.substring(basePath.length);
          const newBasePath = basePath.replace(currentLanguage, "en-US");
          window.location.href = window.location.origin + newBasePath + restOfUrl;
        }
        this.getConnectedCallbakInitData();
    }
  }

  countryCodeFromApi;
  async getIpData() {
    // console.log("getIpData =>");
    let ipAddress;
    /** 
    var request = new XMLHttpRequest();
    request.open("GET", ipifyURL, true);
    request.onload = function () {
      if (request.status >= 200 && request.status < 400) {
        ipAddress = request.responseText;
      } else {
        // We reached our target server, but it returned an error
        console.log(request.statusText);
      }
    };
    request.onerror = function () {
      // There was a connection error of some sort
      console.log(request.statusText);
    };
    request.send();

    setTimeout(() => {
      console.log("getInitData1 IP =>", ipAddress);
      this.guestIpAddress = ipAddress;
      this.getConnectedCallbakInitData();
    }, 1200);
    */

    try {
      // step 1 - fetch Ip address for current location
        const ipResponse = await fetch(ipifyURL);
        console.log('ipResponse ::: ', ipResponse);
        if (ipResponse.ok) {
          ipAddress = await ipResponse.text();
          console.log('Guest User IP:', ipAddress);
        } else {
          console.log('Failed to fetch IP');
        }

        // step 2- fetch gew location info using IP address
        let countryCode = '';
        if (ipAddress) {
          const geoResponse = await fetch(`${ipinfoURL}${ipAddress}/json`);
          console.log('geoResponse ::: ', geoResponse);

          if (geoResponse.ok) {
            const geoData = await geoResponse.json();
            console.log('geoData:', geoData);
            countryCode = geoData.country;
            this.countryCodeFromApi = countryCode;

            let _countryCode = sessionStorage.getItem('countryCodeForGuest');
            if (_countryCode == null || _countryCode == undefined) {
              sessionStorage.setItem('countryCodeForGuest', countryCode);
            }
            if (_countryCode && _countryCode != countryCode ) {
              sessionStorage.setItem('countryCodeForGuest', _countryCode);
            }
            sessionStorage.setItem('ipAddressForGuest', ipAddress);
          } else {
            console.log('Failed to fetch geo info');
          }

          this.guestIpAddress = ipAddress;
        }
      } catch (error) {
        console.error('Error during IP/Geo fetch:', error);
      } finally {
        // Always runs, even if fetch fails
        this.getConnectedCallbakInitData();
      }
  }

  getConnectedCallbakInitData() {
    // console.log("getInitData IP =>", this.guestIpAddress);
    getInitData({
      guestIpAddress: this.guestIpAddress,
      countryCode: this.countryCodeFromApi,
      loggedinUserCountryEmpty: this.loggedinUserCountryEmpty
    })
      .then((result) => {
        console.log("wiredGetInitData => ", result);
        this.countryOptions = result?.countriesData?.map((value) => {
          return {
            label: value.Country_Name__c,
            value: JSON.stringify({
              countryName: value.Country_Name__c,
              currencyISOCode: value.Currency_Code__c,
              countryCode: value.Country_Code__c
            })
          };
        });
        // console.log("this.countryOptions => ", this.countryOptions);
        if (!isGuestUser) {
          this.currentUser = result?.currentUser;
          this.currencyIsoCode = this.currentUser?.CurrencyIsoCode
            ? this.currentUser.CurrencyIsoCode
            : defaultCurrencyCode;
          this.selectedCountryName = this.currentUser?.Country
            ? this.currentUser.Country
            : defaultCountry;

        } else {
          this.guestCountryInfo = result?.guestCountryInfo;
          this.currencyIsoCode = this.guestCountryInfo.split("-")[0];
          this.selectedCountryName = this.guestCountryInfo.split("-")[1];
          

          if (this.oldCurrencyIsoCode != this.currencyIsoCode) {
            this.redirectWithLocale();
          } else {
            window.location.reload();
          }
        }
        // console.log("this.currentUser => ", this.currentUser);
        this.showSpinner = false;
      })
      .catch((error) => {
        console.error("getInitData Error => ", error);
        this.showSpinner = false;
      });
  }

  handleChange(event) {
    this.showSpinner = true;
    // console.log("events", event);

    // console.log("events =>", event.target.dataset.value);
    const selectedValue = JSON.parse(event.target.dataset.value);
    // console.log("selectedValue =>", selectedValue);

    this.selectedCountryName = selectedValue.countryName;
    // console.log("selectedCountryName =>", this.selectedCountryName);
    this.oldCurrencyIsoCode = this.currencyIsoCode;
    this.currencyIsoCode = selectedValue.currencyISOCode;
    // console.log("currencyIsoCode =>", this.currencyIsoCode);

    this.handleClickClose();

    if (!isGuestUser) {
      deleteCurrentCart();
      this.callUpdateUserRelatedRecords();
      // updateUserRelatedRecords({
      //   country: this.selectedCountryName,
      //   currencyIsoCode: this.currencyIsoCode
      // })
      //   .then((result) => {
      //     console.log("updateUserRelatedRecords result =>", result);
      //     if (result.isSuccess) {
      //       console.log("updateUserRelatedRecords Success =>");
      //       window.location.reload();
      //     }
      //   })
      //   .catch((error) => {
      //     console.error("updateUserRelatedRecords Error => ", error);
      //   });
    } else {
      //TODO
      sessionStorage.setItem('countryCodeForGuest', selectedValue.countryCode);

      updateCountryInOrgCache({
        country: this.selectedCountryName,
        currencyIsoCode: this.currencyIsoCode,
        guestIpAddress: this.guestIpAddress
      })
        .then((result) => {
          console.log("updateCountryInOrgCache result =>", result);
          if (result.isSuccess) {
            // console.log("updateCountryInOrgCache Success =>");
            if (this.oldCurrencyIsoCode != this.currencyIsoCode) {
              this.redirectWithLocale();
            } else {
              window.location.reload();
            }
          }
        })
        .catch((error) => {
          console.error("updateCountryInOrgCache Error => ", error);
        });
    }
    //this.showSpinner = false;
  }

  handleClickOpen() {
    this.showCountryList = true;
    this.showhidePanelClass = SHOWPANELCSSCLASS;
  }

  handleClickClose() {
    this.showCountryList = false;
    this.showhidePanelClass = HIDEPANELCSSCLASS;
  }

  redirectWithLocale() {
    let currUrl = window.location.href;
    let splitList = currUrl.split(B2B_SITE_URL);
    // console.log("currUrl => ", currUrl);
    // console.log("splitList =>", splitList);
    // console.log("this.currencyIsoCode => ", this.currencyIsoCode);
    if (this.currencyIsoCode === "EUR") {
      //update url set locale to en-DE for eur and redirect to home.
      // let redirectUrl = B2B_SITE_URL + '/en-DE';
      let suffix = splitList[1];
      if (!suffix.includes("/en-DE")) {
        suffix = "/en-DE" + suffix;
        console.log("suffix =>", suffix);
      }
      let redirectUrl = B2B_SITE_URL + suffix;
      if (!currUrl.includes("/en-DE")) {
        console.log("redirectUrl =>", redirectUrl);
        window.location.href = redirectUrl;
      }
      // let suffix = splitList[1];
      // if(!suffix.includes('/en-DE')){
      //     suffix = '/en-DE' + suffix;
      // }
      // let redirectUrl = B2B_SITE_URL + suffix;
      // window.location.href = redirectUrl;
    } else {
      //remove locale from url, default is set to USD and redirect to home
      // let redirectUrl = B2B_SITE_URL + '/en-US';
      let suffix = splitList[1];
      if (suffix.includes("/en-DE")) {
        let val = suffix.split("/en-DE")[1];
        suffix = "/en-US" + val;
        console.log("else suffix => " + suffix);
      }
      let redirectUrl = B2B_SITE_URL + suffix;
      if (currUrl.includes("/en-DE")) {
        console.log("else redirectUrl => " + redirectUrl);
        window.location.href = redirectUrl;
      }
      // let suffix = splitList[1];
      // if(suffix.includes('/en-DE') ){
      //     let val = suffix.split('/en-DE')[1];
      //     suffix = '/en-US' + val;
      // }
      // let redirectUrl = B2B_SITE_URL + suffix;
      // window.location.href = redirectUrl;
    }
  }

  //
  callUpdateUserRelatedRecords() {
    updateUserRelatedRecords({
        country: this.selectedCountryName,
        currencyIsoCode: this.currencyIsoCode
      })
        .then((result) => {
          console.log("updateUserRelatedRecords result =>", result);
          if (result.isSuccess) {
            // console.log("updateUserRelatedRecords Success =>");
            window.location.reload();
          }
        })
        .catch((error) => {
          console.error("updateUserRelatedRecords Error => ", error);
        });
  }
}