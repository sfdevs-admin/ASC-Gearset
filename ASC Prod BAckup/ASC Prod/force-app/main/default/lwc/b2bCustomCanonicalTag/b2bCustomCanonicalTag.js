import { LightningElement, wire, api } from "lwc";
import { ProductAdapter } from "commerce/productApi";
import { CurrentPageReference } from 'lightning/navigation';

export default class B2bCustomCanonicalTag extends LightningElement {
  @api recordId;
  parentSku;
  interval;
  productId;

  @wire(CurrentPageReference)
  getPageRef(res){
    console.log(' B2bCustomCanonicalTag CurrentPageReference res------- '+JSON.stringify(res));
    this.productId = res.attributes.recordId;
    if( this.parentSku ){
      this.renderedCallback2();
    }
  }

  connectedCallback() {
    console.log("B2bCustomCanonicalTag");
    // interval = setInterval(() => {
    //   this.renderedCallback2(); // ✅ This will now work correctly
    // }, 1);
  }
  renderedCallback2() {
    console.log('renderedCallback2 inside : ');
    let canonicalLink = document.querySelectorAll('link[rel="canonical"], link[rel="alternate"]');
    console.log(canonicalLink);
    if (canonicalLink) {
      console.log(" main renderedCallback  canonical found");
      canonicalLink.forEach(link => {
        let hrefValue = link.href;
        let baseUrl = hrefValue.split('product/');
        if( baseUrl ){
          baseUrl = baseUrl[0];
        }
        // Check if the href contains '01tVN'
        if (hrefValue.includes("01tVN")) {
          // Update the href with the new value
          link.href = baseUrl + 'product/' + this.parentSku; 
          console.log("Canonical link updated:", link.href);
        }
      });
    }
  }
  disconnectedCallback() {
    clearInterval(this.interval);
  }

  renderedCallback() {
    console.log('renderedCallback inside : ');
    let canonicalLink = document.querySelectorAll('link[rel="canonical"], link[rel="alternate"]');
    console.log(canonicalLink);
    if (canonicalLink) {
      console.log(" main renderedCallback  canonical found");
      canonicalLink.forEach(link => {
        let hrefValue = link.href;
        let baseUrl = hrefValue.split('product/');
        if( baseUrl ){
          baseUrl = baseUrl[0];
        }
        // Check if the href contains '01tVN'
        if (hrefValue.includes("01tVN")) {
          // Update the href with the new value
          link.href = baseUrl + 'product/' + this.parentSku; 
          console.log("Canonical link updated:", link.href);
        }
      });
    }
  }
  //@wire(ProductAdapter, { productId: "01tVN000003kDCDYA2" })
  @wire(ProductAdapter, { productId: '$productId' })
  getProductDetails(result) {
    if (result.data) {
      console.log(
        "ProductAdapter Parent Sku ------- " + JSON.stringify(result.data.fields.Parent_Sku__c)
      );
      this.parentSku = result.data.fields.Parent_Sku__c;
      let canonicalLink = document.querySelectorAll('link[rel="canonical"], link[rel="alternate"]');
      console.log(canonicalLink);
      if (canonicalLink) {
        console.log(" main renderedCallback  canonical found");
        canonicalLink.forEach(link => {
          let hrefValue = link.href;
          let baseUrl = hrefValue.split('product/');
          if( baseUrl ){
            baseUrl = baseUrl[0];
          }
          // Check if the href contains '01tVN'
          if (hrefValue.includes("01tVN")) {
            // Update the href with the new value
            link.href = baseUrl + 'product/' + result?.data?.fields?.Parent_Sku__c; 
            console.log("Canonical link updated:", link.href);
          }
        });
      }
      if (result.error) {
        console.log("productadapter error");
        console.error(result.error);
      }
    }
  }
}
// import { LightningElement, wire, api } from "lwc";
// import { ProductAdapter } from "commerce/productApi";

// export default class B2bCustomCanonicalTag extends LightningElement {
//   @api recordId;
//   parentSku;
//   interval;
//   connectedCallback() {
//     console.log("B2bCustomCanonicalTag");
//     // interval = setInterval(() => {
//     //   this.renderedCallback2(); // ✅ This will now work correctly
//     // }, 1);
//   }
//   renderedCallback2() {
//     let canonicalLink = this.template.querySelector('link[rel="canonical"]');
//     console.log(canonicalLink);
//     if (canonicalLink) {
//       let hrefValue = canonicalLink.href;
//       console.log("renderedCallback2  canonical found");
//       console.log(hrefValue);
//       // Check if the href contains '01tVN'
//       if (hrefValue.includes("01tVN")) {
//         clearInterval(interval);

//         // Update the href with the new value
//         canonicalLink.href = hrefValue.replace(
//           /(product\/)[^\/]+/,
//           result.data.fields.Parent_Sku__c
//         );
//         console.log("Canonical link updated:", canonicalLink.href);
//       }
//     }
//   }
//   disconnectedCallback() {
//     clearInterval(this.interval);
//   }

//   renderedCallback() {
//     let canonicalLink = document.querySelector('link[rel="canonical"]');
//     console.log("canonicalLink" + canonicalLink);
//     if (canonicalLink) {
//       console.log(" main renderedCallback  canonical found");
//       let hrefValue = canonicalLink.href;
//       console.log(hrefValue);
//       // Check if the href contains '01tVN'
//       if (hrefValue.includes("01tVN")) {
//         // Update the href with the new value
//         canonicalLink.href = hrefValue.replace(
//           /(product\/)[^\/]+/,
//           result.data.fields.Parent_Sku__c
//         );
//         console.log("Canonical link updated:", canonicalLink.href);
//       }
//     }
//   }
//   @wire(ProductAdapter, { productId: "01tVN000003kDCDYA2" })
//   getProductDetails(result) {
//     console.log(result);
//     if (result.data) {
//       console.log(
//         "Parent Sku ------- " + JSON.stringify(result.data.fields.Parent_Sku__c)
//       );
//       this.parentSku = result.data.fields.Parent_Sku__c;
//       if (true) {
//         let canonicalLink = this.template.querySelector(
//           'link[rel="canonical"]'
//         );

//         console.log("canonicalLink" + canonicalLink);
//         if (canonicalLink) {
//           let hrefValue = canonicalLink.href;
//           console.log("hrefValue" + hrefValue);
//           // Check if the href contains '01tVN'
//           if (hrefValue.includes("01tVN")) {
//             console.log("getProductDetails  canonical found");

//             // Update the href with the new value
//             canonicalLink.href = hrefValue.replace(
//               /(product\/)[^\/]+/,
//               "/" + result.data.fields.Parent_Sku__c
//             );

//             console.log("Canonical link updated:", canonicalLink.href);
//           }
//         }
//       }

//       if (true) {
//         let canonicalLink = document.querySelector('link[rel="canonical"]');

//         console.log("canonicalLink" + canonicalLink);
//         if (canonicalLink) {
//           let hrefValue = canonicalLink.href;
//           console.log("hrefValue" + hrefValue);
//           // Check if the href contains '01tVN'
//           if (hrefValue.includes("01tVN")) {
//             console.log("getProductDetails  canonical found");

//             // Update the href with the new value
//             canonicalLink.href = hrefValue.replace(
//               /\/[^\/]+$/,
//               "/" + result.data.fields.Parent_Sku__c
//             );

//             console.log("Canonical link updated:", canonicalLink.href);
//           }
//         }
//       }
//     }
//     if (result.error) {
//       console.log("productadapter error");
//       console.error(result.error);
//     }
//   }
// }