/**
 * @description       :
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 27-05-2025
 * @last modified by  : Mradul Maheshwari
 **/
import { LightningElement, api } from "lwc";

import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class NavigateAndShowToast extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api objectApiName;
  @api showToast;
  @api toastTitle;
  @api toastType;
  @api toastMessage;
  @api webPageURL;
  @api parameterName;
  @api parameterValue;

  renderedCallback() {
    if (this.showToast === true || this.showToast === "true") {
      this.showCustomToast();
    }

    console.log(this.recordId);
    console.log(this.objectApiName);
    if (this.recordId) {
      const recordPageRef = {
        type: "standard__recordPage",
        attributes: {
          recordId: this.recordId,
          objectApiName: this.objectApiName,
          actionName: "view"
        }
      };
      this[NavigationMixin.GenerateUrl](recordPageRef)

        .then((url) => (this.url = url));

      this[NavigationMixin.Navigate](recordPageRef);
    }

    if (this.webPageURL && this.parameterName && this.parameterValue) {
      this.webPageURL += "?" + this.parameterName + "=" + this.parameterValue;
    }

    if (this.webPageURL) {
      this[NavigationMixin.Navigate](
        {
          type: "standard__webPage",
          attributes: {
            url: this.webPageURL
          }
        },
        true
      );
    }
  }

  showCustomToast() {
    const event = new ShowToastEvent({
      title: this.toastTitle,
      message: this.toastMessage,
      variant: this.toastType
    });
    this.dispatchEvent(event);
  }
}