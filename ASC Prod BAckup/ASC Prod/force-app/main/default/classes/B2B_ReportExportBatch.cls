/**
 * @description       : 
 * @author            : Swati Chilap
 * @group             : 
 * @last modified on  : 02-03-2026
 * @last modified by  : Swati Chilap
 * @Testclass         : B2B_CsvExportControllerTest
**/
global with sharing class B2B_ReportExportBatch
    implements Database.Batchable<Integer>,
               Database.Stateful,
               Database.AllowsCallouts {

    private Id reportId;
    private Blob reportBlob;
    private Integer retryCount = 0;
    private static final Integer MAX_RETRIES = 3;
    private static final String REPORT_API_PATH ='/services/data/v65.0/analytics/reports/';

    global B2B_ReportExportBatch(Id reportId) {
        this.reportId = reportId;
    }

    global Iterable<Integer> start(Database.BatchableContext bc) {
        return new List<Integer>{ 1 };
    }

    global void execute(Database.BatchableContext bc, List<Integer> scope) {

        while (retryCount < MAX_RETRIES && reportBlob == null) {
            retryCount++;
            try {
                System.debug('Attempt #' + retryCount);
                reportBlob = fetchReportFile();
            } catch (Exception e) {
                AscensusHandleCustomException.LogException(e, 'B2B_ReportExportBatch', 'fetchReportFile');
                System.debug('Callout failed: ' + e.getMessage());
            }
        }
    }

    global void finish(Database.BatchableContext bc) {

        if (reportBlob == null) {
            System.debug('No report file generated.');
            return;
        }
        try {
            Id contentVersionId = createContentVersion(reportBlob, reportId);
            sendEmail(contentVersionId);
        } catch (Exception e) {
            AscensusHandleCustomException.LogException(e, 'B2B_ReportExportBatch', 'finish');
        }
        
    }

    private Blob fetchReportFile() {
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:Price_Report'+ REPORT_API_PATH + reportId);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader(
            'Accept',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        );
        req.setTimeout(120000);

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() != 200) {
            AscensusHandleCustomException.createLogErrorRecord('HTTP Callout',res.getStatus(),'B2B_ReportExportBatch','fetchReportFile');
        }

        return res.getBodyAsBlob();
    }

    // ------------------ EMAIL ------------------

    private void sendEmail(Id contentVersionId) {
        User userDetails = B2B_Util.getEffectiveAccountId();
        String contactName = userDetails.Contact != null && userDetails.Contact.Name != null
                            ? userDetails.Contact.Name
                            : 'Customer';

        ContentVersion cv = getContentVersionById(contentVersionId);
        Id orgWideEmailId = B2B_Util.getOrgWideEmailAddressId(userDetails);
        String emailBody = String.format(
            System.Label.B2B_Price_Report_Email_Body,
            new List<String>{ contactName }
        );
        
        Messaging.SingleEmailMessage mail =
            new Messaging.SingleEmailMessage();

        mail.setOrgWideEmailAddressId(orgWideEmailId);
        mail.setToAddresses(
            // new List<String>{ userDetails.Contact.Email, 'ascensus@stackintelligence.com' }
            new List<String>{ userDetails.Contact.Email }
        );
        mail.setSubject(System.Label.B2B_Price_Report_Email_Subject);
        mail.setPlainTextBody(emailBody);

        mail.setEntityAttachments(new List<Id>{ contentVersionId });
        
        mail.setTargetObjectId(userDetails.ContactId);

        Messaging.SendEmailResult[] results = Messaging.sendEmail(
            new List<Messaging.SingleEmailMessage>{ mail }
        );
    }

    // ------------------ CONTENT VERSION ------------------

    private static Id createContentVersion(Blob fileBlob, Id reportId) {

        User userDetails = B2B_Util.getEffectiveAccountId();
        Network networkDetails = B2B_Util.getNetworkDetails();
        String todayStr = Datetime.now().format('yyyy_MM_dd');

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Price_Report_Export_' + todayStr;
        cv.PathOnClient = 'Price_Report_Export_' + todayStr + '.xlsx';
        cv.VersionData = fileBlob; 
        cv.NetworkId = networkDetails.Id;
        cv.FirstPublishLocationId = userDetails.AccountId;

        insert cv;
        return cv.Id;
    }

    private static ContentVersion getContentVersionById(Id contentVersionId) {

        if (contentVersionId == null) {
            return null;
        }

        return [
            SELECT ContentDocumentId, Title, FileExtension, VersionData
            FROM ContentVersion
            WHERE Id = :contentVersionId
            LIMIT 1
        ];
    }
}