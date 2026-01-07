/**
 * This Lightning Web Component (LWC) displays a highly configurable related list.
 * It can show records related to the current parent record or records based on custom SOQL conditions.
 * The component is primarily designed to be configured and used on Lightning Record Pages via the Lightning App Builder.
 *
 * Usage Instructions
 *
 * 1.  **Add to a Lightning Record Page:**
 * Drag the "AtrRelatedList" component onto your desired Lightning Record Page (e.g., Opportunity record page)
 * using the Lightning App Builder.
 *
 * 2.  **Configure Properties in Lightning App Builder:**
 * Once the component is on the page, select it to open the properties panel on the right.
 * Here, you will configure the related list by setting the following `@api` properties:
 *
 * -   **`title` (Required):** The title for your related list.
 * Example: `Line Item Schedule`
 *
 * -   **`icon` (Optional):** The SLDS icon name to display next to the title.
 * Example: `standard:opportunity`
 *
 * -   **`objectApi` (Required):** The API name of the SObject whose records you want to display.
 * Example: `OpportunityLineItemSchedule`
 *
 * -   **`columnJsonString` (Required):** A JSON string defining the columns for the datatable.
 * This string must be an array of column objects, following the lightning-datatable column format.
 * Example:
 * `[
 *      {"label":"Opportunity Name","fieldName":"Name","type":"url","typeAttributes":{"label":{"fieldName":"Name"},"target":"_blank","columnType":"text"}}, 
 *      {"label":"Stage","fieldName":"StageName","type":"text"}, {"label":"Amount","fieldName":"Amount","type":"currency"},
 *      {"label": "Status", "fieldName": "Status__c", "type": "picklist", "options": ["Actual", "Forecast", "Upside"]},
 * ]`
 * (Note: For URL types, ensure `typeAttributes.label.fieldName` points to the field to display as text, 
 * and `fieldName` itself should be the record ID field for the link, or adjust data processing in `fetchRelatedRecords` accordingly if `fieldName` is not the ID.)
 *
 * -   **`whereClause` (Required):** The SOQL WHERE clause to filter the records.
 * Use `recordId` (lowercase) as a placeholder for the current parent record"s ID. It will be automatically replaced.
 * You can also include an `ORDER BY` clause.
 * Example for Opportunities related to an Account: `AccountId = "recordId" AND IsClosed = false ORDER BY Amount DESC`
 *
 * -   **`actionList` (Optional):** A JSON string for custom buttons above the list.
 * Example: `[{"label":"Create New Schedule","name":"newSchedule"}]`
 * (You"ll need to handle these actions in `handleActionButtonClick`).
 *
 * -   **`addRowAction` (Optional):** Check this box (sets to `true`) if you want standard Edit/Delete actions on each row.
 *
 * 3.  **Save and Activate:**
 * Save your changes in the Lightning App Builder and activate the page if necessary.
 */

import { LightningElement, api } from "lwc";
import getRelatedRecords from "@salesforce/apex/AtrRelatedListController.getRelatedRecord";
import updateOrDeleteRecord from "@salesforce/apex/AtrRelatedListController.updateOrDeleteRecord";
import { NavigationMixin } from "lightning/navigation";

const ACTIONS = [
    { label: "Edit", name: "edit" },
    { label: "Delete", name: "delete" }
];

export default class AtrRelatedList extends NavigationMixin(LightningElement) {
    @api title;
    @api icon;

    @api columnJsonString;

    @api objectApi;
    @api whereClause;

    _actionList;
    @api
    get actionList() {
        return this._actionList;
    }

    set actionList(value) {
        this._actionList = JSON.parse(value);
    }

    @api addRowAction;

    @api recordId;

    fieldToQuery = "";
    data = [];
    sortBy;
    sortDirection;
    showDeleteModal = false;
    selectedRow = "";
    showSpinner = false;
    originalPageReference;

    showEditSchedules = false;
    showScheduleCreationModal = false;

    dataForEditModal = [];
    updatedRowsInModal = [];
    deletedRowsInEditModal = [];

    /**
     * Initializes column definitions and fetches the initial set of related records.
     * Also stores the initial page URL to detect navigation for refresh purposes.
     */
    connectedCallback() {
        this.parseColumnJson();
        this.fetchRelatedRecords();

        this.originalPageReference = window.location.href;
    }

    /**
     * Getter for the related list title. Appends the count of records to the title if data exists.
     */
    get relatedListTitle() {
        return this.data && this.data.length > 0 ? this.title + " (" + this.data.length + ")" : this.title;
    }

    get showRelatedList() {
        return this.data && this.data.length > 0;
    }

    /**
     * Getter that transforms the `columnJsonString` into a format suitable for an editable datatable modal.
     * It maps standard column types to custom input components (atrTextInput, atrNumberInput, atrDateInput)
     * and appends a delete icon button column for inline editing scenarios within the modal.
     */
    get editableColumns() {
        const originalColumns = JSON.parse(this.columnJsonString);
        const result = originalColumns.filter(item => (item.type === "url" ? item.typeAttributes?.columnType : item.columnType)).map((item) => {
            const columnType = item.type === "url" ? item.typeAttributes.columnType : item.columnType;
            const value = item.type === "url" ? item.typeAttributes.label.fieldName : item.fieldName;
            const columnName = item.type === "url" ? item.typeAttributes.label.fieldName : item.fieldName;

            switch (columnType) {
                case "text":
                    return {
                        ...item,
                        type: "atrTextInput",
                        typeAttributes: {
                            ...(item.typeAttributes || {}),
                            recordId: { fieldName: "Id" },
                            columnName: columnName,
                            value: { fieldName: value }
                        }
                    };
                case "number":
                    return {
                        ...item,
                        type: "atrNumberInput",
                        typeAttributes: {
                            ...(item.typeAttributes || {}),
                            recordId: { fieldName: "Id" },
                            columnName: columnName,
                            value: { fieldName: value }
                        }
                    };
                case "date":
                    return {
                        ...item,
                        type: "atrDateInput",
                        typeAttributes: {
                            ...(item.typeAttributes || {}),
                            recordId: { fieldName: "Id" },
                            columnName: columnName,
                            value: { fieldName: value }
                        }
                    };
                case "currency":
                    return {
                        ...item,
                        type: "atrNumberInput",
                        typeAttributes: {
                            ...(item.typeAttributes || {}),
                            recordId: { fieldName: "Id" },
                            columnName: columnName,
                            value: { fieldName: value }
                        }
                    };
                case "picklist":
                    return {
                        ...item,
                        type: "atrPicklistInput",
                        typeAttributes: {
                            ...(item.typeAttributes || {}),
                            recordId: { fieldName: "Id" },
                            columnName: columnName,
                            value: { fieldName: value },
                            options: item.options.map(option => { return { "label": option, "value": option }; })
                        }
                    }
                default:
                    return item;
            }
        });

        result.push(
            {
                label: "",
                type: "button-icon",
                fixedWidth: 50,
                typeAttributes: {
                    label: "",
                    name: "delete",
                    iconName: "utility:delete",
                    variant: "base"
                },
                cellAttributes: { alignment: "left" },
            }

        );

        return result;
    }

    /**
     * Parses the `columnJsonString` to extract field API names needed for the SOQL query.
     * It also prepares the column definitions for the main datatable, including adding a
     * row actions column if `addRowAction` is true, and appropriately suffixes URL field names.
     */
    parseColumnJson() {
        const columns = JSON.parse(this.columnJsonString);

        const fieldNames = [];

        columns.forEach(column => {
            if (column.fieldName && column.fieldName !== "Id") {
                fieldNames.push(column.fieldName);
            }

            if (column.type === "url" && column.typeAttributes && column.typeAttributes.label && column.typeAttributes.label.fieldName && column.typeAttributes.label.fieldName !== "Id") {
                fieldNames.push(column.typeAttributes.label.fieldName);
            }
        });

        if (this.addRowAction) {
            columns.push(
                {
                    type: "action",
                    typeAttributes: {
                        rowActions: ACTIONS,
                    }
                }
            );
        }

        this.columns = columns.map(col => {
            if (col.type === "url") {
                return { ...col, fieldName: col.fieldName + "URL" };
            }
            return col;
        });

        this.fieldToQuery = fieldNames.join(",");
    }

    /**
     * Fetches related records from Salesforce using the `getRelatedRecords` Apex method.
     * It constructs the SOQL condition by replacing "recordId" placeholder with the actual `recordId`.
     * It also processes records to create clickable URLs for "url" type columns.
     */
    fetchRelatedRecords() {
        this.showSpinner = true;

        const conditionClause = this.whereClause.includes("recordId") ?
            this.whereClause.replace("recordId", this.recordId) :
            this.whereClause;

        getRelatedRecords({
            objectName: this.objectApi,
            fieldToQuery: this.fieldToQuery,
            conditionClause: conditionClause
        })
            .then(result => {

                const originalColumns = JSON.parse(this.columnJsonString);
                const data = result.map(record => {
                    const newRecord = { ...record };

                    originalColumns.forEach(col => {
                        if (col.type === "url") {
                            const originalFieldName = col.fieldName;
                            const newFieldName = originalFieldName + "URL";

                            if (record[originalFieldName] !== undefined && record[originalFieldName] !== null) {
                                newRecord[newFieldName] = "/" + record[originalFieldName];
                            } else {
                                newRecord[newFieldName] = null;
                            }
                        }
                    });
                    return newRecord;
                });

                this.data = data;
                this.showSpinner = false;
            })
            .catch(error => {
                console.error("Error fetching related records:", error);
                this.showSpinner = false;
            });
    }

    /**
     * Handles click events on custom action buttons defined in `actionList` (e.g., "Edit Schedules").
     */
    handleActionButtonClick(event) {
        const actionName = event.target.label;

        switch (actionName) {
            case "Edit Schedules":
                this.showEdit();
                break;
            case "Establish Schedules":
                this.showScheduleCreationModal = true;
                break;
            default:
                break;
        }
    }

    handleSort(event) {
        const sortColumn = this.columns.find(col => col.fieldName === event.detail.fieldName);
        const sortByColumnName = sortColumn.type === "url" ? sortColumn.typeAttributes.label.fieldName : sortColumn.fieldName;

        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(sortByColumnName, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));

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

    /**
     * Handles actions (e.g., "edit", "delete") invoked on individual rows in the datatable.
     */
    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;

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
                this.showDeleteModal = true;
                this.selectedRow = row;
                break;
            default:
                break;
        }
    }

    /**
     * Periodically checks if the page URL has changed from its original state
     * or if other conditions suggest a refresh is needed after a standard edit action.
     * This is a fallback mechanism.
     */
    checkForRecordUpdate() {
        const currentPageReference = window.location.href;

        if (this.originalPageReference === currentPageReference) {
            this.fetchRelatedRecords();
        } else {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                this.checkForRecordUpdate();
            }, 500);
        }
    }

    closeModal() {
        this.showDeleteModal = false;
        this.selectedRow = "";
    }

    handleDelete() {
        this.showSpinner = true;
        const recordListToDelete = [this.selectedRow];

        this.performDMLOperation(recordListToDelete, "DELETE")
        this.closeModal();
    }

    closeSchdeuleEditModal() {
        this.showEditSchedules = false;
        this.dataForEditModal = [];
    }

    handleSave() {
        this.closeSchdeuleEditModal();
        if (this.deletedRowsInEditModal.length > 0) {
            this.performDMLOperation(this.deletedRowsInEditModal, "DELETE");
            this.deletedRowsInEditModal = [];
        }

        if (this.updatedRowsInModal.length > 0) {
            this.performDMLOperation(this.updatedRowsInModal, "UPDATE");
            this.updatedRowsInModal = [];
        }
    }

    performDMLOperation(records, operation) {
        this.showSpinner = true;

        updateOrDeleteRecord({
            recordList: records,
            operation: operation
        })
            .then(() => {
                this.fetchRelatedRecords();
            })
            .catch(error => {
                console.error("Error performing DML operation:", error);
                this.showSpinner = false;
            });
    }

    showEdit() {
        this.showEditSchedules = true;
        this.dataForEditModal = this.data;
    }

    /**
     * Handles row actions (specifically "delete") within the "Edit Schedules" modal"s datatable.
     * Marks rows for deletion in `deletedRowsInEditModal` and removes them from the modal"s view.
     */
    handleEditTableRowAction(event) {
        const action = event.detail.action;
        const Id = event.detail.row.Id;

        switch (action.name) {
            case "delete":
                this.deletedRowsInEditModal.push({ Id });
                this.dataForEditModal = this.dataForEditModal.filter(item => item.Id !== Id);
                this.updatedRowsInModal = this.updatedRowsInModal.filter(item => item.Id !== Id);
                break;
            default:
                break;
        }
    }

    /**
     * Handles changes to cell values within the "Edit Schedules" modal"s editable datatable.
     * Tracks changed rows and their updated values in `updatedRowsInModal`.
     */
    handleTableRowChange(event) {
        const { recordId, columnName, selectedValue } = event.detail;

        const trackingUpdatesList = this.updatedRowsInModal
        const existingIndex = trackingUpdatesList.findIndex(item => item.Id === recordId);

        if (existingIndex !== -1) {
            trackingUpdatesList[existingIndex] = { ...trackingUpdatesList[existingIndex], [columnName]: selectedValue };

        } else {
            /*eslint quote-props: ["error", "as-needed", { "keywords": true, "unnecessary": false }]*/
            trackingUpdatesList.push({
                "Id": recordId,
                [columnName]: selectedValue
            });
        }

        this.updatedRowsInModal = trackingUpdatesList;
    }

    /**
     * Handles the closing of the "Establish Schedules" (creation) modal.
     * Optionally refreshes the related list data if the modal indicates data was changed.
     */
    closeEstablishSchedules(event) {
        const refershData = event.detail.refreshData;
        this.showScheduleCreationModal = false;

        if (refershData) {
            this.fetchRelatedRecords();
        }
    }

    /**
     * Refreshes the related list data by re-fetching records from Salesforce.
     */
    refreshRelatedListData() {
        this.fetchRelatedRecords();
    }
}