@isTest private class CalculateEmailAttachmsSizeBatchTest {
    @isTest private static void testBatch(){
        EmailMessage em1 = new EmailMessage(HtmlBody = '<h1></h1>');
        insert em1;
        Attachment attchmt = new Attachment(                         
            ParentId = em1.Id,                         
            Body = Blob.valueOf('Test Body'),                         
            ContentType = 'application/pdf',                         
            Name = 'attachmentFilename.pdf'
        );
        insert attchmt;
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert cv;
		Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
		semail.setEntityAttachments(new ID[]{cv.id});
		semail.setSubject('CDL example');
		String[] sendTo = new String[]{'test@valuent.com'};
		semail.setToAddresses(sendTo);
		semail.setPlainTextBody('Please find the attached document details');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
        Test.startTest();
        Database.executeBatch(new CalculateEmailAttachmsSizeBatch(), 200);
        Test.stopTest();
        EmailMessage em1Processed = [SELECT Id, (SELECT Id, BodyLength from Attachments), Attachments_Size__c, Number_Of_Attachments__c, Record_Link__c
                                    FROM EmailMessage 
                                    WHERE Id =: em1.Id];
        System.assertEquals(1, em1Processed.Number_Of_Attachments__c);
        System.assertEquals(true, em1Processed.Attachments_Size__c > 0);
        System.assertNotEquals(null, em1Processed.Record_Link__c);
        EmailMessage em2Processed = [SELECT Id, (SELECT Id, BodyLength from Attachments), Attachments_Size__c, Number_Of_Attachments__c, Record_Link__c
                                    FROM EmailMessage 
                                    WHERE Subject = 'CDL example'];
        System.assertEquals(1, em2Processed.Number_Of_Attachments__c);
        System.assertEquals(true, em2Processed.Attachments_Size__c > 0);
        System.assertNotEquals(null, em2Processed.Record_Link__c);
    }
}