import LightningDatatable from "lightning/datatable";
import atrTextInput from "./atrTextInput";
import atrDateInput from "./atrDateInput";
import atrNumberInput from "./atrNumberInput";
import atrPicklistInput from "./atrPicklistInput.html";

export default class AtrLightningDatatable extends LightningDatatable {
    static customTypes = {
        atrTextInput: {
            template: atrTextInput,
            typeAttributes: ["recordId", "columnName", "value"]
        },
        atrDateInput: {
            template: atrDateInput,
            typeAttributes: ["recordId", "columnName", "value"]
        },
        atrNumberInput: {
            template: atrNumberInput,
            typeAttributes: ["recordId", "columnName", "value"]
        },
        atrPicklistInput: {
            template: atrPicklistInput,
            typeAttributes: ["recordId", "columnName", "value", "options"]
        }
    }
}