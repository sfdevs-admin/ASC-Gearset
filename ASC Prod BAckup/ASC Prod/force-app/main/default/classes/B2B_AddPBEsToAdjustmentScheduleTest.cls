/**
 * @description       : 
 * @author            : Swati Chilap
 * @group             : 
 * @last modified on  : 09-29-2025
 * @last modified by  : Swati Chilap
**/
@IsTest
public class B2B_AddPBEsToAdjustmentScheduleTest {
    @IsTest
    static void testB2B_AddPBEsToAdjustmentSchedulerTest() {
        Test.startTest();
        B2B_AddPBEsToAdjustmentSchedule schedulableClass = new B2B_AddPBEsToAdjustmentSchedule();
        schedulableClass.execute(null);

        List<AsyncApexJob> batchJobs = [SELECT Id, Status, JobType FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status = 'Queued'];
        System.assertEquals(1, batchJobs.size(), 'There should be 1 batch job queued.');
        Test.stopTest();
    }
}