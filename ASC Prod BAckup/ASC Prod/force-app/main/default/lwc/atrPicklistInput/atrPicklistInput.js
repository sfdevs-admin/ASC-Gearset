import { LightningElement, api } from "lwc";

export default class AtrPicklistInput extends LightningElement {
    @api recordId;
    @api options;
    @api value;
    @api columnName;

    selectedValue;

    connectedCallback() {
        if (this.value) {
            this.selectedValue = this.value;
        }
    }

    dispatchCustomEvent(value) {
        const event = new CustomEvent("tablerowchange", {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                recordId: this.recordId,
                columnName: this.columnName,
                selectedValue: value
            },
        });
        this.dispatchEvent(event);
    }

    handleChange(event) {
        this.template.querySelector("lightning-combobox").classList.add("is-edited");
        this.template.querySelector("lightning-combobox").style.fontWeight = "bold";

        this.selectedValue = event.target.value;

        this.dispatchCustomEvent(this.selectedValue);
    }
}