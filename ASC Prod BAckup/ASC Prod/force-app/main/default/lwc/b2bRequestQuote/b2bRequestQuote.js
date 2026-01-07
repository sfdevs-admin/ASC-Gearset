/**
 * @description       :
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 17-12-2025
 * @last modified by  : Mradul Maheshwari
 **/
import { LightningElement, wire, api, track } from "lwc";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import Quote from "@salesforce/schema/Quote";
import QuoteLineItem from "@salesforce/schema/QuoteLineItem";
import Unit_of_Measure__c from "@salesforce/schema/QuoteLineItem.Unit_of_Measure__c";
import QuoteCountry__c from "@salesforce/schema/Quote.QuoteCountry__c";
import QuoteState__c from "@salesforce/schema/Quote.QuoteState__c";
import Salutation__c from "@salesforce/schema/Quote.Salutation__c";
import saveQuoteWithLineItems from "@salesforce/apex/B2B_RequestForQuoteController.saveQuoteWithLineItems";
import getPicklist from "@salesforce/apex/B2B_RequestForQuoteController.getPicklist";
import getProductDetails from "@salesforce/apex/B2B_RequestForQuoteController.getProductDetails";
import createAccountAndContact from "@salesforce/apex/B2B_RequestForQuoteController.createAccountAndContact";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Toast from "lightning/toast";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import isGuestUser from "@salesforce/user/isGuest";
//SCC-25 changes start
import CURRENCY from "@salesforce/i18n/currency";
import { RefreshEvent } from "lightning/refresh";
//SCC-25 changes end


//Asc - 163
import { CartItemsAdapter } from 'commerce/cartApi';
import { getRecord } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import Account_Name_Field from "@salesforce/schema/Account.Name";
import Customer_Number_Field from "@salesforce/schema/Account.Customer_Number__c";
import Account_CurrencyIsoCode_Field from "@salesforce/schema/Account.CurrencyIsoCode";
import userId from '@salesforce/user/Id';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import PHONE_FIELD from '@salesforce/schema/Contact.Phone';

const USER_FIELDS = [CONTACT_FIELD];
const CONTACT_FIELDS = [FIRSTNAME_FIELD, LASTNAME_FIELD, EMAIL_FIELD, PHONE_FIELD];

export default class B2bRequestQuote extends NavigationMixin(LightningElement) {
  @track unityOfMeasureOptions = [];
  @track unityOfSalutation = [];
  @track unityOfState = [];
  @track unityOfCountry = [];

  @track selectedUnityOfMeasure1;
  @track selectedUnityOfMeasure2;
  @track selectedUnityOfMeasure3;

  @track selectedSalutation;
  @track selectedCountry;
  @track selectedState;

  @track billingCountry;
  @track billingState;
  @track billingProvince21;

  @track catalogNumber1;
  @track catalogNumber2;
  @track catalogNumber3;

  @track casNumber1;
  @track casNumber2;
  @track casNumber3;

  @track productDescription1;
  @track productDescription2;
  @track productDescription3;

  @track isValidCatalogNumber1 = true;
  @track isValidCatalogNumber2 = true;
  @track isValidCatalogNumber3 = true;

  @track TotalQuantity21;
  @track TotalQuantity22;
  @track TotalQuantity23;

  @track CommentPurity15;
  @track CommentPurity16;
  @track CommentPurity17;

  @track SpecialInstructions18;
  @track SpecialInstructions19;
  @track SpecialInstructions20;

  @track CompanyName4;

  @track Address5 = "";
  @track Address55 = "";
  @track Address56 = "";
  @track fullAddress;
  @track billingAddress15 = "";
  @track billingAddress16 = "";
  @track billingAddress17 = "";
  @track billingFullAddress;

  @track FirstName6;
  @track City7;
  @track billingCity18;
  @track MiddleInitial8;
  @track LastName9;
  @track Province10;
  @track Email11;
  @track AccountNumber14;
  @track Phone12;
  @track PostalCode13;
  @track billingPostalCode20;
  @track Fax14;

  @track Id1;
  @track Id2;
  @track Id3;
  @track LineItemId;
  // @track isInvalidCatalogNumber = false;
  // @track quoteValues = {};
  // @track quoteLineItems = [];
  @track selectedUnityOfMeasure;
  @track catalogNumber;
  @track molecularFormula;
  @track selectedGrade;
  @track molecularWeight;
  @track selectedDemandType;
  @track chemicalStructure;
  @track technicalPublicationReference;
  @track casNumber;
  @track id;
  @track totalQuantity;
  @track productDescription;
  @track showItem2 = false;
  @track info;
  @track isUSASelected = false;
  @track isUSASelectedForBilling = false;
  @track showRemoveBtn = false;
  delayTimeout;
  showSpinner = false;
  @track desiredShipmentDate;
  @track isBillingSame = false;

    @track staticDemandTypeOptions = [
    
    { label: 'One-time need', value: 'One-time need' },
    { label: 'Ongoing supply', value: 'Ongoing supply' },
    { label: 'Secondary source', value: 'Secondary source' }
  ];


   @track staticGradeOptions  = [
    { label: 'Reagent', value: 'Reagent' },
    { label: 'ACS', value: 'ACS' },
    { label: 'USP', value: 'USP' },
    { label: 'Technical', value: 'Technical' },
    { label: 'Custom', value: 'Custom' }
];
handleBillingCheckboxChange(event) {
  this.isBillingSame = event.target.checked;
}


  // @track
  @track items = [
    {
      id: 1,
      catalogNumber: "",
      casNumber: "",
      LineItemId: "",
      productDescription: "",
      totalQuantity: "",
      selectedUnityOfMeasure: "",
      commentPurity: "",
      specialInstructions: "",
      molecularFormula: "",
      selectedGrade:"",
      selectedDemandType:"",
      chemicalStructure:"",
      molecularWeight:"",
      technicalPublicationReference:"",
      unitPrice:0

    }
  ];

  objectFieldMap = {
    Quote: ["QuoteCountry__c", "QuoteState__c", "Salutation__c"],
    QuoteLineItem: ["Unit_of_Measure__c"]
  };

  handleAddItem() {
    const newItem = {
      id: this.items.length + 1,
      catalogNumber: "",
      casNumber: "",
      LineItemId: "",
      productDescription: "",
      totalQuantity: "",
      selectedUnityOfMeasure: "",
      commentPurity: "",
      specialInstructions: "",
      chemicalStructure:"",
      molecularFormula:"",
      molecularWeight:"",
      selectedGrade:"",
      selectedDemandType:"",
      technicalPublicationReference:"",
      unitPrice:0
    };
    console.log("newItem", newItem);
    this.items = [...this.items, newItem];
    console.log("this.items-->", this.items);
    this.showRemoveBtn = this.items.length > 1 ? true : false;
  }

  handleRemoveItem() {
    const index = this.items.length - 1;
    console.log("index", index);
    if (index > -1) {
      this.items.splice(index, 1);
    }
    console.log("this.items => ", this.items);
    this.showRemoveBtn = this.items.length > 1 ? true : false;
  }

  @wire(getPicklist, { objectFieldMap: "$objectFieldMap" })
  wiredPicklistValues({ error, data }) {
    if (data) {
      console.log("Picklist Values Map:", data);
      this.unityOfCountry = data.Quote.QuoteCountry__c.map((value) => ({
        label: value,
        value: value
      }));
      this.unityOfState = data.Quote.QuoteState__c.map((value) => ({
        label: value,
        value: value
      }));
      // this.unityOfSalutation = data.Quote.Salutation__c.map(value=>({label: value,value: value}));
      this.unityOfMeasureOptions = data.QuoteLineItem.Unit_of_Measure__c.map(
        (value) => ({ label: value, value: value })
      );
    } else if (error) {
      console.error("Error fetching picklist values:", error);
    }
  }

  // handleAddItem() {
  //     const newItemId = this.items.length + 1;
  //     console.log('newItemId', newItemId);
  //     this.items.push({ id: newItemId});
  // }



  handleDateChange(event) {
    this.desiredShipmentDate = event.target.value;
    console.log('Selected Date:', this.desiredShipmentDate);
  }

  handleCountry(event) {
    this.selectedCountry = event.detail.value;
    console.log("this.selectedCountry", this.selectedCountry);
    //this.isUSASelected = this.selectedCountry;
    this.isUSASelected = this.selectedCountry === "United States of America";
  }
  handleState(event) {
    this.selectedState = event.detail.value;
    console.log("this.selectedState", this.selectedState);
  }

  handleBillingCountry(event){
    this.billingCountry = event.detail.value ;
      this.isUSASelectedForBilling = this.billingCountry === "United States of America";
  }
    handleBillingState(event){
    this.billingState = event.detail.value;
}
  getProductClass(index) {
    return this[`isValidCatalogNumber${index}`] ? "" : "invalid-input";
  }
  @api
  get productDetails() {}
  set productDetails(value) {
    this.info = value;
    console.log("this.info", this.info);
  }
  handleonBlurCatalogNumberChange(event) {
    const index = event.target.dataset.index;
    const field = event.target.dataset.field;

    window.clearTimeout(this.delayTimeout);

    // changes done for https://ascensus-saphelpdesk.atlassian.net/browse/SCC-53 start
    // const value = event.target.value;
    let value = event.target.value;
    value = value.trim();
    // changes done for https://ascensus-saphelpdesk.atlassian.net/browse/SCC-53 end

    // Update the catalog number
    this.items[index - 1][field] = value;
    // Fetch product details based on the catalog number
    this.delayTimeout = setTimeout(() => {
      this.getProductDetailsbyCatalog(value, index, field);
    }, 500);
  }

  getProductDetailsbyCatalog(value, index) {
    this.items[index - 1].isLoading = true;
    getProductDetails({ catalogNumber: value })
      .then((result) => {
        if (result) {
          console.log("result from getProductDetails", result);
          this.items[index - 1].productDescription = result.Product_Description__c;
          this.items[index - 1].casNumber = result.CAS__c;
          this.items[index - 1].LineItemId = result.Id;

          if (this.cartIdFromState && this.cartItems.length > 0) {
              this.items[index - 1].selectedUnityOfMeasure = 'EA';
              this.unityOfMeasureOptions = [{ label: 'EA', value: 'EA' }];
              this.isUnitOfMeasureDisabled = true;
          } else {
              this.isUnitOfMeasureDisabled = false;
          }

        } else {
          this.items[index - 1].productDescription = "Invalid catalog number";
          this.items[index - 1].casNumber = "";
        }
        // Update the items array to trigger reactivity
        this.items = [...this.items];
        // this.updateProductDescription(index);
        console.log("Updated items:", JSON.parse(JSON.stringify(this.items)));
        this.items[index - 1].isLoading = false;
      })
      .catch((error) => {
        this.items[index - 1].isLoading = false;
        this.items[index - 1].productDescription = "Invalid catalog number";
        this.items[index - 1].casNumber = "";
        // Update the items array to trigger reactivity
        this.items = [...this.items];
        // this.updateProductDescription(index);
        console.error("Error fetching product details:", error);
        console.log(
          "Items after error:",
          JSON.parse(JSON.stringify(this.items))
        );
      });
  }
  handleInputChange(event) {
    const index = event.target.dataset.index;
    const field = event.target.dataset.field;
    const value = event.target.value;
    this.items[index - 1][field] = value;
    this.items = [...this.items];
    console.log(
      "Input changed:",
      JSON.parse(JSON.stringify(this.items[index - 1]))
    );
  }

  handleCASNumberChange(event) {
    this.handleInputChange(event);
  }

  handleProductDescriptionChange(event) {
    this.handleInputChange(event);
  }

  // updateProductDescription(index) {
  //     const descriptionElement = this.template.querySelector(`#product-description-${index}`);
  //     if (descriptionElement) {
  //         descriptionElement.textContent = this.items[index - 1].productDescription;
  //         console.log('descriptionElement-->',descriptionElement.textContent);
  //     }
  // }

  handleUnityOfMeasureChange(event) {
    this.handleInputChange(event);  
  }

  handleDemandTypeChange(event) {
     this.handleInputChange(event);  
  }

  handleGradeChange(event) {
     this.handleInputChange(event);  
  }

  handleDataChange(event) {
    // const name = event.target.name;
    const index = event.target.dataset.index;
    this[`CompanyName${index}`] = event.target.value;

    this[`Address${index}`] = event.target.value;
    this.fullAddress =
      `${this.Address5} ${this.Address55} ${this.Address56}`.trim();

      this[`billingAddress${index}`]  = event.target.value;
      this.billingFullAddress = `${this.billingAddress15} ${this.billingAddress16} ${this.billingAddress17}`.trim();

    //this[`Address${index}`] = event.target.value;
    this[`FirstName${index}`] = event.target.value;
    this[`City${index}`] = event.target.value;
    // this[`MiddleInitial${index}`] = event.target.value;
    this[`LastName${index}`] = event.target.value;
    this[`Province${index}`] = event.target.value;
    this[`Email${index}`] = event.target.value;
    this[`Phone${index}`] = event.target.value;
    this[`PostalCode${index}`] = event.target.value;
    this[`AccountNumber${index}`] = event.target.value;
    this[`billingCity${index}`] = event.target.value;
    this[`billingProvince${index}`] = event.target.value;
    this[`billingPostalCode${index}`] = event.target.value;
       
    // this[`Fax${index}`] = event.target.value;
  }

  handleSubmit() {
    // Check if the checkboxes are checked
    const createAccountCheckbox = true; //this.template.querySelector('input[name="Create a new account"]');
    const termsCheckbox = this.template.querySelector(
      'input[name="I have read and accept the Terms of Use  Privacy Policy."]'
    );
    this.showSpinner = true;
    if (!createAccountCheckbox || !termsCheckbox.checked) {
      this.showSpinner = false;
      console.error("One or both checkboxes are not checked.");
      // If either checkbox is not checked, show an error message
      Toast.show(
        {
          label: "Failure",
          message: "Please accept the terms and policies.",
          variant: "error"
        },
        this
      );
      return;
    }


    //Check if all required fields are filled in
    if (
      this.items &&
      this.CompanyName4 &&
      this.Address55 &&
      this.FirstName6 &&
      this.LastName9 &&
      this.City7 &&
      this.Email11 &&
      this.Phone12 &&
      this.PostalCode13 &&
      this.selectedCountry  &&
        (this.isBillingSame || ( // only validate billing address if checkbox is unchecked
    this.billingAddress16 &&
    this.billingCity18 &&
    this.billingPostalCode20 &&
    this.billingCountry 
  ))
    ) {

       if (this.isBillingSame) {
    this.billingFullAddress = this.fullAddress;
    this.billingCity18 = this.City7;
    this.billingState = this.selectedState;
    this.billingProvince21 = this.Province10;
    this.billingPostalCode20 = this.PostalCode13;
    this.billingCountry = this.selectedCountry;
  }
      //SCC-25 changes start
      let locale = isGuestUser ? CURRENCY : this.currencyIsoCode; //CURRENCY;
      console.log("locale----- " + locale);

      //SCC-25 changes end
      const quoteValues = {
        isGuest: isGuestUser,
          CompanyName: this.CompanyName4,
         Address: this.fullAddress,
         BillingAddress: this.billingFullAddress,
        // Salutation: this.selectedSalutation,
        FirstName: this.FirstName6,
        City: this.City7,
        BillingCity: this.billingCity18,

        // MiddleInitial: this.MiddleInitial8,
        LastName: this.LastName9,
        Province: this.Province10,
        BillingProvince : this.billingProvince21,
        Email: this.Email11,
        Phone: this.Phone12,
        PostalCode: this.PostalCode13,
        BillingPostalCode: this.billingPostalCode20,
        AccountNumber: this.AccountNumber14,
  // Fax: this.Fax14,
        Country: this.selectedCountry,
        BillingCountry : this.billingCountry,

        State: this.selectedState,
        BillingState: this.billingState,
        quoteLineItems: this.items, // Directly assign items array here,
        DesiredShipmentDate: this.desiredShipmentDate,
        currencyCode: locale,
        cartId: this.cartIdFromState
      };
      console.log("Submitting quote values 1:", JSON.stringify(quoteValues));
      const QuoteData = JSON.stringify(quoteValues);
      console.log("QuoteData", QuoteData);
      this.updateQuoteValues(QuoteData);
    } else {
      this.showSpinner = false;
      Toast.show(
        {
          label: "Failure",
          // message: '${quoteId} created sucessfully',
          message: "Please fill in all required fields",
          // mode: 'dismissable',
          variant: "error"
        },
        this
      );
    }
  }

 updateQuoteValues(QuoteData) {
  this.showSpinner = true;

  saveQuoteWithLineItems({ quoteJson: QuoteData })
    .then((res) => {
      this.showSpinner = false;
      console.log(
        "saveQuoteWithLineItems response ---- ",
        JSON.stringify(res)
      );

      let response = JSON.parse(JSON.stringify(res));

      if (response.isSuccess) {
        const quoteId = response.quote?.Name;

        Toast.show(
          {
            label: "Success",
            message: "Quote Created Successfully",
            variant: "success"
          },
          this
        );

        this[NavigationMixin.Navigate](
          {
            type: "standard__webPage",
            attributes: {
              url: "/request-quote-thank-you"
            }
          },
          true
        );

        this.clearFormFields();

        setTimeout(() => {
          window.location.reload();
        }, 1000);
      } else {
        // Business-level failure from Apex
        console.error(
          "saveQuoteWithLineItems isSuccess false ---- ",
          JSON.stringify(response)
        );

        Toast.show(
          {
            label: "Some Error Occurred!",
            message:
              "Unfortunately, there was an issue submitting your quote request. Please contact our customer service team at (978) 499 1600",
            variant: "warning"
          },
          this
        );
      }
    })
    .catch((e) => {
      // Technical / unexpected error
      this.showSpinner = false;
      console.error(
        "saveQuoteWithLineItems catch ---- ",
        JSON.stringify(e)
      );

      Toast.show(
        {
          label: "System Error",
          message:
            "Unfortunately, there was an issue submitting your quote request. Please contact our customer service team at (978) 499 1600",
          variant: "warning"
        },
        this
      );
    });
}

  navigateToHomePage() {
    this[NavigationMixin.Navigate](
      {
        type: "standard__webPage",
        attributes: {
          url: "https://ascensusspecialties--partial.sandbox.my.site.com/store/"
        }
      },
      true
    );
  }

  clearFormFields() {
    this.CompanyName4 = "";
    this.Address5 = "";
    this.FirstName6 = "";
    this.LastName9 = "";
    this.Province10 = "";
    this.City7 = "";
    this.Email11 = "";
    this.AccountNumber14 = "";
    this.Phone12 = "";
    this.PostalCode13 = "";
    this.selectedCountry = "";
    this.selectedState = "";
    this.billingAddress15 = "";
    this.billingCity18 = "";
    this.billingCountry = "";
     this.billingState = "";
     this.billingProvince21 = "";
     this.billingPostalCode20 = "";
    //this.items = [];
    // Reset the items array to its initial state with one empty item block
    this.items = [
      {
        id: 1,
        catalogNumber: "",
        casNumber: "",
        LineItemId: "",
        productDescription: "",
        totalQuantity: "",
        selectedUnityOfMeasure: "",
        commentPurity: "",
        specialInstructions: "",
        chemicalStructure: "",
        molecularFormula: "",
        molecularWeight: "",
        selectedGrade: "",
        selectedDemandType: "",
        technicalPublicationReference: "",
        unitPrice: 0
      }
    ];

    this.dispatchEvent(new RefreshEvent());
  }

  cartIdFromState;
  cartItems = [];
  accountid;
  contactId;
  billingAddresses = [];
  shippingAddresses = [];

  @track isUnitOfMeasureDisabled = false;
  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
      if (currentPageReference) {
          this.cartIdFromState = currentPageReference.state.cartid;
      }
  }

  @wire(CartItemsAdapter)
  setCartItems({ data, error }) {
      if (data) {
          this.accountid = data?.cartSummary?.accountId;
          this.cartItems = data?.cartItems || [];

          // only build items if cartId is present in state
          if (this.cartIdFromState && this.cartItems.length > 0) {
              this.items = this.cartItems.map((cartItem, index) => {
                  let sku = cartItem?.cartItem?.productDetails?.fields?.StockKeepingUnit || cartItem?.cartItem?.productDetails?.sku || "";
                  // Force EA as unit of measure for cart-to-quote
                  this.unityOfMeasureOptions = [{ label: 'EA', value: 'EA' }];
                  
                  let newItem = {
                      id: index + 1,
                      catalogNumber: sku, // populate SKU into catalogNumber
                      casNumber: cartItem?.cartItem?.productDetails?.fields?.CAS__c || "",
                      LineItemId: cartItem?.cartItem?.productDetails?.productId || "",
                      productDescription: cartItem?.cartItem?.productDetails?.fields?.Product_Description__c || "Invalid catalog number",
                      totalQuantity: cartItem?.cartItem?.quantity || "",
                      selectedUnityOfMeasure: 'EA',
                      commentPurity: "",
                      specialInstructions: "",
                      chemicalStructure: "",
                      molecularFormula: "",
                      molecularWeight: "",
                      selectedGrade: "",
                      selectedDemandType: "",
                      technicalPublicationReference: "",
                      unitPrice: cartItem?.cartItem?.listPrice || cartItem?.cartItem?.salesPrice || 0
                  };
                  return newItem;
              });

              this.isUnitOfMeasureDisabled = true ;

              this.items.forEach((item, index) => {
                  if (item.catalogNumber) {
                    this.getProductDetailsbyCatalog(item.catalogNumber, index + 1, 'catalogNumber');
                  }
              });
              console.log("Items populated from cartId state:", this.items);
              this.showRemoveBtn = this.items.length > 1;
          }
      } else if (error) {
          console.error('Error fetching cart items', error);
      }
  }

  @wire(getRecord, {
        recordId: "$accountid",
        fields: [Account_Name_Field, Customer_Number_Field, Account_CurrencyIsoCode_Field]
    })
    currentAccountRecord({ error, data }) {
      if (data) {
        this.currencyIsoCode =  data.fields?.CurrencyIsoCode?.value;
      }
      if (this.cartIdFromState && data) {
            this.CompanyName4 = data.fields?.Name?.value;
            this.AccountNumber14 = data.fields?.Customer_Number__c?.value;
      }
    }

    @wire(getRecord, { recordId: userId, fields: USER_FIELDS })
    wiredUser({ data, error }) {
        if (this.cartIdFromState && data) {
            this.contactId = data.fields.ContactId.value;
        }
    }

    @wire(getRecord, { recordId: '$contactId', fields: CONTACT_FIELDS })
    wiredContact({ data, error }) {
        if (this.cartIdFromState && data) {
            this.FirstName6 = data.fields.FirstName.value;
            this.LastName9 = data.fields.LastName.value;
            this.Email11 = data.fields.Email.value;
            this.Phone12 = data.fields.Phone.value;
        }
    }

    handlePrivacyStatement(event) {
      event.preventDefault();

      this[NavigationMixin.GenerateUrl]({
          type: 'standard__webPage',
          attributes: {
              url: '/privacy-statement'
          }
      }).then((generatedUrl) => {
          window.open(generatedUrl, '_blank');
      });
    }

}