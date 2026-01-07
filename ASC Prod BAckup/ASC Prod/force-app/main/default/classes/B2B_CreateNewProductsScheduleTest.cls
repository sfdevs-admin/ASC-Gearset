@IsTest
private class B2B_CreateNewProductsScheduleTest {
    
    @IsTest
    static void testBatchExecutionFromScheduler() {
        // Ensure that the batch class is executed when triggered by the scheduler
        
        Test.startTest();
        
        // Create an instance of the scheduler class
        B2B_CreateNewProductsSchedule schedulableClass = new B2B_CreateNewProductsSchedule();
        
        // Call the execute method to simulate the scheduling and execution of the batch
        schedulableClass.execute(null);
        
        // Verify that the batch job was queued
        List<AsyncApexJob> batchJobs = [SELECT Id, Status, JobType FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status = 'Queued'];
        System.assertEquals(1, batchJobs.size(), 'There should be 1 batch job queued.');
        
        Test.stopTest();
        
        // After Test.stopTest(), the batch job should have processed.
        List<AsyncApexJob> completedJobs = [SELECT Id, Status, JobType FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status = 'Completed'];
        System.assertEquals(1, completedJobs.size(), 'There should be 1 completed batch job after Test.stopTest().');
    }
}