@isTest(seeAllData=false)
public class SyncRDContributorsFlowInvokerTest {

    /**
     * @description Test method to verify the flow invocation logic.
     */
    @isTest
    static void testInvokeSyncRDContributorsFlow() {
        Profile sysAdminProfile = [Select Id from Profile where Name = 'System Administrator'];
        Profile stdUserProfile = [Select Id from Profile WHERE Name = 'Ascensus Standard User - Minimum Access'];

        User sysAdmin = TestDataFactory.createUser('systemAdmin@asc.com.test', 'System Admin', sysAdminProfile.Id, false);
        insert sysAdmin;
        // Create standard users
        User contributor1 = TestDataFactory.createUser('contributor1@ascensus.com', 'contributor1', stdUserProfile.Id, false);
        User contributor2 = TestDataFactory.createUser('contributor2@ascensus.com', 'contributor2', stdUserProfile.Id, false);
        User contributor3 = TestDataFactory.createUser('contributor3@ascensus.com', 'contributor3', stdUserProfile.Id, false);
        User contributor4 = TestDataFactory.createUser('contributor4@ascensus.com', 'contributor4', stdUserProfile.Id, false);
        
        List<User> users = new List<User>();
        users.add(contributor1);
        users.add(contributor2);
        users.add(contributor3);
        users.add(contributor4);
        insert users;
        System.debug(LOGGINGLEVEL.INFO, 'users: ' + users);
        
        // Assign the permission set 'RD_Project_Contributor_Permissions' to the first two users
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'RD_Project_Contributor_Permissions' LIMIT 1];
        System.assertNotEquals(null, ps, 'Permission set "RD_Project_Contributor_Permissions" must exist.');

        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        for (Integer i = 0; i < 2; i++) {
            psaList.add(new PermissionSetAssignment(
                AssigneeId = users[i].Id,
                PermissionSetId = ps.Id
            ));
        }
        insert psaList;

        // Add the remaining two users to the public group 'R_D_Contributors'
        Group publicGroup = [SELECT Id FROM Group WHERE DeveloperName = 'R_D_Contributors' AND Type = 'Regular' LIMIT 1];
        System.assertNotEquals(null, publicGroup, 'Public group "R_D_Contributors" must exist.');

        List<GroupMember> groupMembers = new List<GroupMember>();
        for (Integer i = 2; i < 4; i++) {
            groupMembers.add(new GroupMember(
                GroupId = publicGroup.Id,
                UserOrGroupId = users[i].Id
            ));
        }
        insert groupMembers;

        System.runAs(sysAdmin) {
            // Start a test context
            Test.startTest();

            // Call the method that in turn invokes the flow
            SyncRDContributorsFlowInvoker schInvoker = new SyncRDContributorsFlowInvoker();
            schInvoker.execute(null);

            // Stop the test context
            Test.stopTest();

            List<GroupMember> updatedGroupMembers = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :publicGroup.Id AND UserOrGroupId IN :users];
            System.assertEquals(2, updatedGroupMembers.size(), 'There should be 2 members in the public group.');
            System.debug(LOGGINGLEVEL.INFO, 'updatedGroupMembers.size(): ' + updatedGroupMembers.size());
            
            List<Id> expectedUserIds = new List<Id>{users[0].Id, users[1].Id};
            List<Id> actualUserIds = new List<Id>{updatedGroupMembers[0].UserOrGroupId, updatedGroupMembers[1].UserOrGroupId};
            expectedUserIds.sort();
            actualUserIds.sort();
            System.assertEquals(expectedUserIds, actualUserIds, 'The group members have not been updated correctly.');
        }
    }
}