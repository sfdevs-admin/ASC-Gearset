/**
 * @description This Job invokes the flow which syncs users between 
 *      the Contributor PS and Contributor Public Group.
 * @Author Atrium - nishant.surana@atrium.ai
 * @date May 2025
 */
global class SyncRDContributorsFlowInvoker implements Schedulable {

    private static String flowName = 'Sync_RD_Project_Contributors_PSA_to_RD_Contributors_PG';

    /**
     * @description Entry point for the scheduled job.
     * @param sc The context of the scheduled job.
     */
    global void execute(SchedulableContext sc) {
        invokeSyncRDContributorsFlow();
    }

    /**
     * @description Method to invokes the flow asynchronously.
     * @future (callout=false)
     * @throws Exception Logs any exceptions that occur during the flow invocation.
     */
    @future (callout=false) // Using @future for asynchronous execution 
    public static void invokeSyncRDContributorsFlow() {
        try {
            // Prepare input variables (if needed)
            Map<String, Object> flowInputs = new Map<String, Object>();

            // Start the flow asynchronously
            Flow.Interview.Sync_RD_Project_Contributors_PSA_to_RD_Contributors_PG flowInterview =
                new Flow.Interview.Sync_RD_Project_Contributors_PSA_to_RD_Contributors_PG(flowInputs);
            flowInterview.start();

            System.debug(LOGGINGLEVEL.INFO, '[' + flowName + '] invoked successfully.');

        } catch (Exception e) {
            System.debug(LOGGINGLEVEL.INFO, '[' + flowName + '] Error occurred on invoking flow. Error: ' + e.getMessage());
        }
    }
}