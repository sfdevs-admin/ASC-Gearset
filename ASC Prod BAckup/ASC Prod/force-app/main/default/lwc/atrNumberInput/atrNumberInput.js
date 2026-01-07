import { LightningElement, api } from "lwc";

export default class AtrNumberInput extends LightningElement {

    @api recordId;

    @api value;

    @api columnName

    selectedValue = "";

    connectedCallback() {
        this.selectedValue = parseFloat(this.value).toFixed(2) || "";
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
        this.template.querySelector("input").style.backgroundColor = "#F9E3B6";
        this.template.querySelector("input").style.fontWeight = "bold";
        
        const num = parseFloat(event.target.value); 
        this.selectedValue = num.toFixed(2);
        this.dispatchCustomEvent(this.selectedValue);
    }
}