import { LightningElement, wire, api, track } from "lwc";
import { CartSummaryAdapter } from "commerce/cartApi";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createQuote from "@salesforce/apex/B2B_RequestForQuoteController.createQuote";
import B2B_RequestQuoteUrl from "@salesforce/label/c.B2B_RequestQuoteUrl";
import basePath from "@salesforce/community/basePath";
// import {fireEvent} from 'c/pubSubConnector';

export default class B2bRequestForQuote extends NavigationMixin(
  LightningElement
) {
  //     showSpinner = false;
  //    @api requestQuote= false;//Usha

  @api tabName;
  // @track requestPage = false;
  // messageState = 'Loading';
  // isPreview = true;
  // cartId;
  // connectedCallback() {
  //     this.isPreview = this.isInSitePreview();
  //     if(this.isPreview){
  //         this.showSpinner = false;
  //     }
  // }

  // @wire(CurrentPageReference)  pageRef; //Usha
  // getPageRef(res){
  //     console.log('B2bRequestForQuote CurrentPageReference res------- '+JSON.stringify(res));
  // }

  // @wire(CartSummaryAdapter, {})
  // getCartDetails({ error, data })
  // {
  //     if(error){
  //         console.log('B2bRequestForQuote getCartDetails error exception----- '+ JSON.stringify(error));
  //     }else{
  //         if(data != undefined){
  //             console.log('B2bRequestForQuote getCartDetails data----- '+ JSON.stringify(data));
  //             this.cartId = data.cartId;
  //         }
  //     }
  // }

  // isInSitePreview() {
  //     let url = document.URL;

  //     return (url.indexOf('sitepreview') > 0
  //         || url.indexOf('livepreview') > 0
  //         || url.indexOf('live-preview') > 0
  //         || url.indexOf('live.') > 0
  //         || url.indexOf('.builder.') > 0);
  // }

  handleCreateQuote() {
    console.log("B2bRequestForQuote handleCreateQuote---- ");
    //     this.showSpinner = true;
    //     this.messageState = 'Creating Quote please wait';

    //     // if(this.tabName == B2B_RequestQuoteUrl){
    //     //     console.log('insideSDSPage',this.tabName);
    //     //     this.requestPage = `${basePath}/request-quote`;
    //     //     console.log('requestPgae',this.requestPage);
    //     // }

    //     let mapParams = {};
    //     mapParams.cartId = this.cartId;
    //     createQuote({
    //         'mapParams' : mapParams
    //     }).then((res) => {
    //         let response = JSON.parse(JSON.stringify(res));
    //         console.log('B2bRequestForQuote createQuote res---- '+ JSON.stringify(res));
    //         if(res.isSuccess){
    //             this.showSpinner = false;
    //             // this.showSuccessToast();
    //             this.quoteId = res.quoteObj.Id;
    this.navigateToQuotePage(); //usha
    //             this.navigateToQuoteRecordPage();

    //         }else{
    //             //show no data found error
    //             console.log('B2bRequestForQuote createQuote is success false---- '+ JSON.stringify(res));
    //             this.showSpinner = false;
    //             this.navigateToErrorPage();
    //         }
    //     }).catch((e) => {
    //         console.log('B2bRequestForQuote createQuote catch---- '+ JSON.stringify(e));
    //         this.showSpinner = false;
    //         this.navigateToErrorPage();
    //     });
  }

  // showErrorToast() {
  //     const evt = new ShowToastEvent({
  //         title: 'Error',
  //         message: 'Some unexpected error while creating Quote',
  //         variant: 'error',
  //         mode: 'dismissable'
  //     });
  //     this.dispatchEvent(evt);
  // }

  // showSuccessToast() {
  //     const evt = new ShowToastEvent({
  //         title: 'Success',
  //         message: 'Quote created sucessful',
  //         variant: 'success',
  //         mode: 'dismissable'
  //     });
  //     this.dispatchEvent(evt);
  // }

  //   navigateToQuoteRecordPage() {
  //     // Navigate to a URL
  //     this[NavigationMixin.Navigate](
  //       {
  //         type: "standard__webPage",
  //         attributes: {
  //           url: "/quote/" + this.quoteId,
  //         },
  //       },
  //       true, // Replaces the current page in your browser history with the URL
  //     );
  //   }

  //usha
  navigateToQuotePage() {
    //const url = `https://ascensusspecialties--partial.sandbox.my.site.com/store/request-quote/${this.cartId}`;
    // console.log('Navigating to quote page:', url);
    this[NavigationMixin.Navigate](
      {
        type: "standard__webPage",
        attributes: {
          url: "/request-quote"
        }
      },
      true
    );
  }
  navigateToSelfRegistrationPage() {
    this[NavigationMixin.Navigate](
      {
        type: "standard__webPage",
        attributes: {
          url: "/SelfRegister"
        }
      },
      true
    );
  }

  //   navigateToErrorPage() {
  //     // Navigate to a URL
  //     this[NavigationMixin.Navigate](
  //       {
  //         type: "standard__webPage",
  //         attributes: {
  //           url: "/error",
  //         },
  //       },
  //       true, // Replaces the current page in your browser history with the URL
  //     );
  //   }
}