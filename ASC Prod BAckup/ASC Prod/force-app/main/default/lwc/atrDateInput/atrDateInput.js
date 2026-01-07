import { LightningElement, api } from "lwc";

export default class AtrDateInput extends LightningElement {

    @api recordId;

    @api value;

    @api columnName

    selectedValue = "";
    inputClass = "";

    connectedCallback() {
        this.selectedValue = this.value || "";

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

    openDatePicker(event) {
        event.target.showPicker();
    }

    handleChange(event) {
        this.template.querySelector("input").style.backgroundColor = "#F9E3B6";
        this.template.querySelector("input").style.fontWeight = "bold";

        this.selectedValue = event.target.value;
        this.dispatchCustomEvent(this.selectedValue);
    }
}