global class B2B_RemoveNewProductsSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Integer batchSize = 50;
        B2B_RemoveNewProductsBatch batch = new B2B_RemoveNewProductsBatch();
        Database.executeBatch(batch, batchSize);
    }
}