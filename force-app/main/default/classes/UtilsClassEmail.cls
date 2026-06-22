/**
 * @description       : Methods for building email
 * @author            : 
 * @group             : 
 * @last modified on  : 05-15-2024
 * @last modified by  : 
**/
public class UtilsClassEmail extends Utils {
    //Method that sends emails with CC
    public static void sendMail(String subject, String messageBody, String displayName, String receiver, String carbonCopy){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setSenderDisplayName(displayName);
        mail.setSubject(subject);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(messageBody);
        mail.setToAddresses(new String[]{ receiver });
        if (!String.isEmpty(carbonCopy)){
            mail.setCcAddresses(new String[]{ carbonCopy });
        }

        if (!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
        }
    }

    //Method that sends emails with CC and file attachment
    public static Void sendMailWithFile(Blob fileBody, String csvName, String subject, String messageBody, String displayName, String receiver, String carbonCopy){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        csvAttc.setFileName(csvName);
        csvAttc.setBody(fileBody);

        mail.setSenderDisplayName(displayName);
        mail.setSubject(subject);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(messageBody);
        mail.setToAddresses(new String[]{ receiver });
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{ csvAttc });
        if (!String.isEmpty(carbonCopy)){
            mail.setCcAddresses(new String[]{ carbonCopy });
        }

        if (!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
        }
    }

    //Method to send Email with HTML body
    public static Void sendMailHTML(String subject, String messageBody, String displayName, String receiver, String carbonCopy){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setSenderDisplayName(displayName);
        mail.setSubject(subject);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(messageBody);
        mail.setHtmlBody(messageBody);
        mail.setToAddresses(new String[]{ receiver });
        if (!String.isEmpty(carbonCopy))
            mail.setCcAddresses(new String[]{ carbonCopy });

        if (!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
        }
    }

    //Method to send Email with customTemplate with file Attachment
    public static Void sendMailCustomTemplate(Id customTemplate, Blob fileBody, String csvName, String displayName, String receiver, String carbonCopy){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        csvAttc.setFileName(csvName);
        csvAttc.setBody(fileBody);
        mail.setSenderDisplayName(displayName);
        mail.setTemplateId(customTemplate);
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        mail.setToAddresses(new String[]{ receiver });
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{ csvAttc });
        if (!String.isEmpty(carbonCopy))
            mail.setCcAddresses(new String[]{ carbonCopy });

        if (!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
        }
    }

    //Method to send Email with customTemplate
    public static Void sendMailCustomTemplateAnyCSV(Id customTemplate, String displayName, String receiver, String carbonCopy){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName(displayName);
        mail.setTemplateId(customTemplate);
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        mail.setToAddresses(new String[]{ receiver });

        if (!String.isEmpty(carbonCopy))
            mail.setCcAddresses(new String[]{ carbonCopy });

        if (!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
        }
    }
}