global class B2B_CreateNewProductsSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Integer batchSize = 50;
        B2B_CreateNewProductsBatch batch = new B2B_CreateNewProductsBatch();
        Database.executeBatch(batch, batchSize);
    }
}