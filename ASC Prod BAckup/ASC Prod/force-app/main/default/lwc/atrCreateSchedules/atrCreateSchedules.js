import { LightningElement, api } from "lwc";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import { NavigationMixin } from "lightning/navigation";
import getRelatedLineItems from "@salesforce/apex/AtrRelatedListController.getRelatedLineItems";
import getRDProduct from "@salesforce/apex/AtrRelatedListController.getRDProduct";
import establishSchedules from "@salesforce/apex/AtrRelatedListController.establishSchedules";
import updateOrDeleteRecord from "@salesforce/apex/AtrRelatedListController.updateOrDeleteRecord";
import getScheduleTypes from "@salesforce/apex/AtrRelatedListController.getScheduleTypes";

const ACTIONS = [
    { label: "Edit", name: "edit" },
    { label: "Delete", name: "delete" }
];

const LINE_ITEM_COLUMNS = [
    {
        label: "Product Name",
        fieldName: "productName",
    },
    {
        label: "Quantity",
        fieldName: "Quantity",
        type: "number",
        sortable: true,
        cellAttributes: {
            alignment: "left"
        }
    },
    {
        label: "Sales Price",
        fieldName: "UnitPrice",
        type: "currency",
        sortable: true,
        cellAttributes: {
            alignment: "left"
        }
    },
    {
        label: "Date",
        fieldName: "ServiceDate",
        type: "date-local",
        sortable: true
    },
    {
        label: "Line Description",
        fieldName: "Description",
        type: "text",
        sortable: true
    },
    {
        type: "action",
        typeAttributes: {
            rowActions: ACTIONS,
        }
    }

];
export default class AtrCreateSchedules extends NavigationMixin(LightningElement) {

    @api
    recordId;

    originalPageReference;
    showSpinner = false;
    showScheduleSpinner = false;

    onLineItemSelection = true;

    lineItemsRecords = [];
    lineItemColumns = LINE_ITEM_COLUMNS;
    sortBy;
    sortDirection;

    selectedRow = [];
    scheduleTypeOptions = [];

    showEstablishSchedulesModal = false;
    startDate;
    monthsLastDate = false;
    installmentPeriod = "";

    installmentPeriodOptions = [
        { label: "None", value: "" },
        { label: "Daily", value: "Daily" },
        { label: "Weekly", value: "Weekly" },
        { label: "Monthly", value: "Monthly" },
        { label: "Quarterly", value: "Quarterly" },
        { label: "Yearly", value: "Yearly" }
    ];

    scheduleType = "";

    numberOfInstallments;

    get modalHeader() {
        return this.onLineItemSelection
            ? "Select Opportunity Line Item"
            : "Establish Schedule";
    }

    get disableCreateschedules() {
        return this.selectedRow.length === 0;
    }   

    get disableMonthsLastDate() {
        return this.isLastDayOfMonth(this.startDate) === false; 
    }

    get labelToCreateSchedule() {
        return this.selectedRow.length > 0
            ? this.selectedRow[0].OpportunityLineItemSchedules?.length > 0
                ? "Re-Establish Schedules"
                : "Establish Schedules"
            : "Establish Schedules";
    }

    connectedCallback() {
        this.originalPageReference = window.location.href;
        this.fetchRelatedLineItems();
    }

    fetchRelatedLineItems() {
        this.showSpinner = true;
        getRelatedLineItems({
            recordId: this.recordId
        })
            .then(result => {

                this.lineItemsRecords = result.map((item) => {
                    return {
                        ...item,
                        productName: item.Product2 ? item.Product2.Name : "",
                    }
                });
                this.showSpinner = false;

            })
            .catch(error => {
                console.error("Error fetching related line items:", error.getMessage());
                this.showSpinner = false;
            });
    }

    handleSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.lineItemsRecords));

        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === "asc" ? 1 : -1;

        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : "";
            y = keyValue(y) ? keyValue(y) : "";

            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;

        let recordListToDelete;

        switch (action.name) {
            case "edit":
                this[NavigationMixin.Navigate]({
                    type: "standard__recordPage",
                    attributes: {
                        recordId: row.Id,
                        actionName: "edit",
                    },
                });
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    this.checkForRecordUpdate();
                }, 500);

                break;
            case "delete":
                /*eslint quote-props: ["error", "as-needed", { "keywords": true, "unnecessary": false }]*/
                recordListToDelete = [{
                    "Id": row.Id
                }];
                this.performDMLOperation(recordListToDelete, "DELETE")
                
                break;
            default:
                break;
        }
    }

    performDMLOperation(records, operation) {
        this.showSpinner = true;

        updateOrDeleteRecord({
            recordList: records,
            operation: operation
        })
            .then(() => {
                this.fetchRelatedLineItems();
                this.dispatchEvent(new CustomEvent("refresh", {}));
            })
            .catch(error => {
                console.error("Error performing DML operation:", error);
                this.showSpinner = false;
            });
    }

    handleRowSelection(event) {
        this.selectedRow = event.detail.selectedRows;
    }

    handleClick(event) {
        const actionName = event.target.name;
        let defaultValues;

        switch (actionName) {

            case "createSchedules":
                getScheduleTypes()
                    .then(result => {
                        this.scheduleTypeOptions = [...result];
                    })
                    .catch(error => {
                        console.error("Error fetching schedule types:", error.getMessage());
                    });
                
                this.selectedRow = this.lineItemsRecords.filter(item => {
                    return item.Id === this.selectedRow[0].Id;
                });

                this.showEstablishSchedulesModal = true;
                this.revenue = this.selectedRow[0].TotalPrice;
                this.startDate = new Date().toISOString();
                
                break;

            case "addLineItem":
                getRDProduct()
                    .then((result) => {

                        defaultValues = encodeDefaultFieldValues({
                            OpportunityId: this.recordId,
                            Product2Id: result,
                        });

                        this[NavigationMixin.Navigate]({
                            type: "standard__objectPage",
                            attributes: {
                                objectApiName: "OpportunityLineItem",
                                actionName: "new",
                            },
                            state: {
                                defaultFieldValues: defaultValues,
                                navigationLocation: "RELATED_LIST"
                            }
                        });
                        // eslint-disable-next-line @lwc/lwc/no-async-operation
                        setTimeout(() => {
                            this.checkForRecordUpdate();
                        }, 500);
                    })
                    .catch((error) => {
                        console.error("Error fetching RD Product:", error.getMessage());
                    });
                break;

            case "closeModal":

                this.dispatchEvent(
                    new CustomEvent("closemodal", {
                        detail: {
                            refreshData: false
                        }
                    })
                );
                break;

            case "closeScheduleCreationModal":

                this.showEstablishSchedulesModal = false;
                this.startDate = new Date().toISOString();
                this.revenue = this.selectedRow[0].TotalPrice;
                this.installmentPeriod = "None";
                this.scheduleType = "None";
                this.numberOfInstallments = "";
                this.selectedRow = [];
                break;

            case "saveNewSchedules":
                this.checkValidity();
                break;

            default:
                break;
        }
    }

    isLastDayOfMonth(date) {
        const nextDay = new Date(date);
        nextDay.setDate(nextDay.getDate() + 1);

        return nextDay.getDate() === 1;
    }

    checkForRecordUpdate() {
        const currentPageReference = window.location.href;

        if (this.originalPageReference === currentPageReference) {
            this.fetchRelatedLineItems();
        } else {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                this.checkForRecordUpdate();
            }, 500);
        }
    }

    handleScheduleModalInputs(event) {

        const _targetName = event.target.name;
        const _targetValue = event.target.value;
        const _targetChecked = event.target.checked;

        switch (_targetName) {
            case "startDate":
                this.startDate = _targetValue;
                this.monthsLastDate = this.isLastDayOfMonth(this.startDate) ? this.monthsLastDate : false;
                break;
            case "monthsLastDate":
                this.monthsLastDate = _targetChecked;
                break;
            case "revenue":
                this.revenue = _targetValue;
                break;
            case "installmentPeriod":
                this.installmentPeriod = _targetValue;
                break;
            case "scheduleType":
                this.scheduleType = _targetValue;
                break;
            case "numberOfInstallments":
                this.numberOfInstallments = _targetValue;
                break;
            default:
                break;
        }

    }

    checkValidity() {

        const allValid = [...this.template.querySelectorAll(".input-element"),].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            this.generateSchedules();
        }
    }

    generateSchedules() {

        this.showScheduleSpinner = true;

        const scheduleRevenue = this.scheduleType === "Divide Amount into multiple installments"
            ? this.revenue / this.numberOfInstallments
            : this.revenue;
        let schedulesList = [];

        for (let i = 0; i < this.numberOfInstallments; i++) {

            let scheduleDate = new Date(this.startDate);

            switch (this.installmentPeriod) {

                case "Daily":
                    scheduleDate.setDate(scheduleDate.getDate() + i);
                    break;
                case "Weekly":
                    scheduleDate.setDate(scheduleDate.getDate() + (i * 7));
                    break;
                case "Monthly":
                    if (this.monthsLastDate) {
                        scheduleDate = new Date(scheduleDate.getFullYear(), scheduleDate.getMonth() + i + 1, 0);
                    } else {
                        scheduleDate.setMonth(scheduleDate.getMonth() + i);
                    }
                    break;
                case "Quarterly":
                    if (this.monthsLastDate) {
                        scheduleDate = new Date(scheduleDate.getFullYear(), scheduleDate.getMonth() + (i * 3) + 1, 0);
                    } else {
                        scheduleDate.setMonth(scheduleDate.getMonth() + (i * 3));
                    }
                    break;
                case "Yearly":
                    if (this.monthsLastDate) {
                        scheduleDate = new Date(scheduleDate.getFullYear() + i, scheduleDate.getMonth() + 1, 0);
                    } else {
                        scheduleDate.setFullYear(scheduleDate.getFullYear() + i);
                    }
                    break;
                default:
                    break;

            }

            if (this.monthsLastDate) {
                scheduleDate.setDate(scheduleDate.getDate() + 1); //Adding 1 day to balance the date reduced by 1 when converting to ISO string
            }

            let scheduleItem = {
                OpportunityLineItemId: this.selectedRow[0].Id,
                ScheduleDate: scheduleDate.toISOString().split("T")[0],
                Revenue: scheduleRevenue,
                Schedule_Type__c: this.scheduleType,
                Status__c: (scheduleDate.toISOString().split("T")[0] < new Date().toISOString().split("T")[0]) ? "Actual" : "Upside",
                Type: "Revenue"
            }
            schedulesList.push(scheduleItem);
        }

        establishSchedules({
            scheduleLineItems: JSON.stringify(schedulesList),
            deleteExisting: this.selectedRow[0].OpportunityLineItemSchedules?.length > 0,
            lineItemId: this.selectedRow[0].Id
        })
            .then(() => {
                this.showEstablishSchedulesModal = false;
                this.startDate = new Date().toISOString();
                this.revenue = this.selectedRow[0].TotalPrice;
                this.installmentPeriod = "None";
                this.scheduleType = "None";
                this.numberOfInstallments = "";
                this.showScheduleSpinner = false;

                const _event = new CustomEvent("closemodal", {
                    detail: {
                        refreshData: true
                    }
                });
                this.dispatchEvent(_event);
            })
            .catch(error => {
                console.error("Error establishing schedules:", error);
                this.showScheduleSpinner = false;
            });
    }

}