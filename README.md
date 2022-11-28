# Trivium Admissions Automations and Manual Processes

## Prep work prior to enrollment:

1. Create Term record(s) with enrollment and cutoff dates. Make sure to check the box “Include in Application” for any Terms you want available in the Formstack application term lookups.
2. Clear out the waitlist numbers on accounts. This can easily be done with an Account list view.
3. Create Class Offering records populated with the newly created term and adjust the capacity as necessary.
4. Confirm verbiage on application confirmation email
5. Update verbiage on Formstack forms if necessary.
6. Update Formstack merge documents and mappings as necessary.
7. Update email verbiage
    1. Application confirmation
    2. Returning family emails
8. Send out returning family emails

1. *Admissions start:* Families submit Application through the Formstack New Family Enrollment and Returning Family Enrollment forms
    1. New families apply through the hosted form. Waitlist numbers will be issued for those submitted past the cutoff.
    2. *Returning families have the Returning Enrollment URL link emailed to them*
    3. The family will receive confirmation emails for each Application.
2. *Trivium staff populates the Assigned Learning Center and the Charter for Assigned Learner Center* (renamed from TCS Learning Center) fields on the Household Account based on the First and Second choice learning centers
    1. *Assigned Learning Center is referenced by the student Application records and is used to generate Class Enrollments. This must be populated prior to generating enrollments or the process will not execute properly.*
3. *Automation: *Lottery process is run from the Term record to assign lottery numbers to new households (Lottery Eligible = checked).
    1. The checkbox Lottery Run gets checked to indicate the lottery has been run for that Term. 
4. *Trivium staff double checks the Applications dashboard Duplicate Applications component (at the bottom) to ensure that all duplicate applications for the same student in the current term have been resolved before generating the Class Enrollment records.*
5. *Automation: *Enrollment process is run from the Term record to create Class Enrollment records based on Applications
    1. Once capacity is reached for an offering, students will be enrolled in the online version of the course for their grade and next term.
    2. *This process will create duplicate records if run more than once for the same term. This means that all records for the term will need to be deleted before re-running.*
6. *Trivium staff makes manual adjustments to Class Enrollments to move students to the correct classes*
7. *Automation: *Clear Account Enrollment Data is run from the Term record to clear household existing enrollment data in anticipation of the new term’s enrollments
8. *Trivium staff double checks the Class Rostering dashboard after enrollment to spot any duplicate class enrollments that may have been generated.*
    1. If all duplicate applications have been resolved, this shouldn’t be an issue, but it never hurts to double check to ensure there weren’t any manual mistakes made. Batches with duplicates enrollments will fail when attempting to sync Contact and Account records, but this sync can just be re-run without issue after resolving duplicates.
9. *Automation: *Sync Contact and Account Enrollment Data is run from the Term record to write Class Enrollment data to student Contact and Household Account records
10. Run a Contacts with Class Enrollments report for the chosen enrollment term to get a list of all students that will receive invitations.
11. Add the Contact list in the report to a Campaign for that term.
12. Send out invitations via screen flow in the campaign for 3 TCS Learning Centers at a time. Wait at least an hour and then send the other 3.
13. Mid-year enrollments for the current and future terms will come in through the year. These can be handled in the same manner as the other applications.
    1. Individual invitations can be sent out using the “Merge Document” action selected from the upper right corner dropdown on the Contact record. However, Campaigns can also be used to bulk send invitations - *the Contacts with Class Enrollments report can be filtered by Created Date* to only pull in enrollments that were created past a cutoff date (but are also in the chosen term).
    2. *Class Enrollment records will need to be manually created, or uploaded using Data Loader. The class enrollment automation can NOT be run for mid year enrollments without creating duplicates for students already enrolled for that term.*

## Formstack

* _New Family Enrollment Form_
    * Creates new Household account, marked *Lottery Eligible*
        * When submitted past the new family cutoff date, the Account Waitlist Increment flow is launched to *assign a waitlist number to the account*
        * This is referenced by the Lottery Apex process to assign lottery numbers.
    * *First guardian created is assigned as primary contact* for the household account
        * *The field “What is your relationship to the student(s)?”* *on the Guardian record* is used in the flow Create HH Relationships from Student Contact
    * *The Email field on the first Guardian record created* (Household Account Primary Contact) *is duplicated to the “Primary Household Email”* field on the Contact and Account records *via a formula reference that updates automatically with changes*
    * *Creates a Contact for each Application*
        * Flow Create Contact when Submitted Via Formstack launches when the *checkbox* *“Submitted via Enrollment Form” is checked on the Application by the Formstack form*
        * Subsequently launches subflow Application Confirmation Email Subflow to send a confirmation email to the email address listed on the Household Guardian / Primary Contact.
    * *The Term lookup field references the List View “Terms for Applications”.* This view is filtered for Terms that have the checkbox “Include in Application” checked (manually maintained by Trivium staff)
    * The First and Second Choice Learning Center picklists were created in the Formstack form. Rules were then implemented to submit a lookup field value (record ID) through the form based on the chosen picklist value. This logic will need to be adjusted if the TCS Center list ever changes.
    * This form only populates the first and second choice learning centers on the household account. It is expected that the Trivium staff bulk-update the Assigned Learning Center field on Accounts using dataloader(.io) or account list views prior to creating Class Enrollments.
    * Mobile-friendly styling has been applied to this form. If a theme is set from the Formstack UI, without the aid of custom CSS, the mobile-friendly code may need to be re-added to the CSS after the theme has been configured. This is the same code for both forms.
        * #dvFastForms.ff-ui-dialog  {
                  position: fixed!important;
                  top: 0!important;
                  bottom:0!important;
                  height:60%!important;
                  width:90%!important;
                  }
            #ffLookupDialog  {
                  bottom:0!important;
                  height:90%!important;
                  }
* _Returning Family Enrollment Form_
    * Accessed via the Household Account field *“Returning Enrollment URL”.*
    * *The Term lookup field references the List View “Terms for Applications”.* This view is filtered for Terms that have the checkbox “Include in Application” checked (manually maintained by Trivium staff)
    * *The checkbox "Returning Student Enrolled via Formstack" on the Contact record is checked when "Is this student returning" = yes on the submitted form*, which fires the flow Create Application Record for Returning Student to create an application for each returning student.
        * Subsequently launches subflow Application Confirmation Email Subflow to send a confirmation email to the email address listed on the Household Guardian / Primary Contact.
        * *Lastly, “Returning Student Enrolled Via Formstack” is unchecked* in preparation for the next year’s application.
    * The same mobile-friendly styling has been applied to this form. See above note about changing the form theme.

## Flows

### Flows without Apex

* _Account Waitlist Increment_
    * Trigger: Account Create, “Lottery Eligible“ = checked
    * If an Account is created past the *Current Term’s New Family Cutoff Date,* the Household waitlist number is issued. This is calculated by finding the highest waitlist number currently populating households and incrementing by 1. *Waitlist numbers will need to be cleared out each year in order to ensure each new year’s waitlist starts at 1.* This can easily be done via an Account list view.
* _Application Confirmation Email Subflow_
    * Trigger: Record-triggered flows Create Contact for New Family Application, Create Application Record for Returning Student, and Create Application for Returning Family New Student
    * Sends a confirmation email to the *Primary Household Email* found on the student applicant’s Contact record in response to an Application record being created in CRM (like after a Formstack application submission). This is a reference to the *Household* *Primary Contact / Guardian’s preferred email address*.
    * *Outgoing email address is determined by the Automated Process User email address.* 
* _Application Received Past Cutoff Date_
    * Trigger: Application Created
    * Looks at the Term on the application to see if the application has been submitted after either of the new or returning family cutoff dates
    * If yes, it creates a notification for a selected user (bell icon in top right corner of SF)
    * *Currently Servio is selected to receive these notifications in Salesforce*
* _Create Contact from New Family Application_
    * Trigger: Application Create, “Submitted Via Enrollment Form” = checked
    *  Creates a Contact record for each Application created by the Formstack New Family Enrollment Form
    * Subsequently launches the flow Application Confirmation Email Subflow
* _Create Application Record for Returning Student_
    * Trigger: Contact Update, “Returning Student Enrolled via Formstack” = checked, after being unchecked, and “Is this student returning” = yes
    * Creates an Application record from info submitted onto student Contacts through the Formstack Returning Family Enrollment Form. 
    * Subsequently launches the flow Application Confirmation Email Subflow
* _Create Application for Returning Family New Student_
    * Trigger: Contact Create, “Is this student returning?” = “Brand New Student”
    * Creates an Application record for any students added to the Formstack Returning Family Enrollment Form
    * Subsequently launches the flow Application Confirmation Email Subflow
* _Create HH Relationships from Student Contact_
    * Trigger: Contact Create
    * If the created Contact is a student record type, and the Primary Contact (Guardian) on the account has the field “Relationship to Student” populated (entered in the Formstack New Family Enrollment Form), then a Relationship record will be created between the student and the Primary Contact for the household (which will be the first Guardian record created for the household)

### Flows with Apex actions

* See the Apex Processes section below for details.

* _Account Enrollment Data Clear_
    * Trigger: Button on Term record
    * Apex: Account Enrollment Data Clear
* _Contact Account Enrollment Sync_
    * Trigger: Button on Term record
    * Apex: Contact Account Enrollment Sync
* _Enrollment Process_
    * Trigger: Button on Term record
    * Apex: Enrollment Process
* _Lottery Process_
    * Trigger: Button on Term record
    * Apex: Lottery Process
* _Send PDF Invitations_
    * Trigger: Button on Campaign record
    * Apex: Send PDF Invitations

## Apex Processes

* _Lottery Process_
    * Launched by the screen flow Lottery Process from a Term record
    * This loops through all Household Accounts with the *Lottery Eligible checkbox checked* and randomly assigns a lottery number to each of them.
        * Sets Account fields:
            * “Lottery Term” - the Term from which the Flow launched
            * “Lottery Number” - randomly generated
            * “Lottery Eligible” - unchecked
        * Sets the launching Term field:
            * “Lottery Run“ - unchecked
    * If the lottery process needs to be re-run, just re-check the Lottery Eligible checkboxes on Household Accounts. This will re-write all of their lottery information during the next run.
* _Enrollment Process_
    * Launched by the screen flow Enrollment Process from a Term record
    * This loops through all Applications and creates Class Enrollment records for each. Enrollments for returning families are created first, and then enrollments for new families are created in order of their assigned lottery numbers.
    * When a Class Offering reaches capacity, students are then put into the Online version of that offering, for the same term and grade, and the *Class Enrollment checkbox “In Person Learning Not Available” is checked.*
    * This process is sensitive to duplicate Applications for the same student applicant in the same term. Make sure to merge or delete any duplicate apps before kicking off this process. Duplicate apps may lead to improper student enrollment. Duplicates can be identified at the bottom right of the Applications dashboard, the component labeled “Current Year Duplicate Apps’, on the Applications tab of the Trivium Admissions app homepage. *Make sure the dashboard is filtered by a specific term,* then click into the dashboard report to see all duplicate applications at the top of the list. If there are no duplicates, each applicant will just show 1 application for the filtered term.
    * This process can be repeated without consequence, however, *all class enrollments for the running term must be deleted before re-running the enrollment process,* otherwise duplicate enrollments will be created. Deleting records is easily accomplished using Salesforce Data Loader or 3rd party tool dataloader.io.
* _Account Enrollment Data Clear_
    * Launched by the screen flow Clear Account Enrollment Data from a Term record
    * Batch updates Account records to clear enrollment fields where the checkbox *“Currently Enrolled Family” is checked*
        * “Currently Enrolled Family”
        * “Enrolled Term“
    * Runs in background Apex jobs that may take several minutes to complete in entirety. 
    * This is in preparation for current term enrollment information to be later synced by the Apex process Contact Account Enrollment Sync (described below)
* _Contact Account Enrollment Sync_
    * Launched by the screen flow Contact Account Enrollment Sync from a Term record
    * Batch updates Account and Contact records to show enrollment information based on the Class Enrollment records associated to each student.
        * Sets Account fields:
            * “Currently Enrolled Family” - checked
            * “Enrolled Term” - the Term listed on the Class Enrollment
        * Sets the launching Term field:
            * “Class Enrollment“ - lookup to the Class Enrollment record
            * “Enrollment Grade” - grade listed on the class offering
    * This process is sensitive to duplicate Class Enrollments for the same student applicant (Contact) in the same term. A batch will fail if it tries to update the same Contact record twice in the same batch (due to duplicate enrollments), so make sure to merge or delete any duplicate records before kicking off this process.
    * Duplicates can be identified at the bottom of the Class Rostering dashboard, the component labeled “Duplicate Enrollments”, on the Class Enrollments tab of the Trivium Admissions app homepage. *Make sure the dashboard is filtered by a specific term,* then click into the dashboard report to see all duplicate enrollments at the top of the list. If there are no duplicates, each applicant will just show 1 enrollment for the filtered term. 
    * This process can be repeated indefinitely without consequence, so if there’s an error in a batch, it’s not a big deal. *In the event of a batch failure, just get rid of the duplicate(s) and re-run the process to get everything properly synced.*
* _Send PDF Invites_
    * Launched by the screen flow Send PDF Invitations from a Term record
    * This automation will send out batches of emails with attached PDF invitations to the household email address of each student campaign member added to a campaign via a *Class Enrollment Salesforce report.* 
    * The flow batches out the background processing jobs based on the Learning Center associated to the Class Enrollment records. This Learning Center also determines *which version of the invitation they receive - In-Person or Online.*
    * The number of invitations in a batch, and thus the total batch count, is determined by the Salesforce platform while the code is running. The calculations are based on how many computing resources are required for the whole job, and how many are available based on the platform use - generating and sending PDFs takes a lot of system resources, so a lot of batches have to be created to get everything sent out.
    * According to Salesforce platform limits, there cannot be more than 100 batches queued simultaneously. With the volume of invitations expected annually for Trivium - which is around the amount we at Servio used for testing - this limit will likely be hit if all invitations are attempted to send at once. This means that some portion of the invitations would fail to queue and you’d have to use reporting to see who received the document and who did not.
    * So, to avoid that messy situation, we have built this aid to send invitations by Learning Center to break up the batch jobs. We recommend sending out invitations for 3 learning centers at once, waiting an hour, and then sending for the other 3. It's likely the emails will take at least 30 minutes to all get processed and this will ensure that no platform limits will even be close to being hit. The flow will need to be re-launched for each Learning Center.
    * *The drop down list will exclude any centers that have already had invitations sent earlier in the same day. *This is to avoid sending the same invitations twice. This can be manually overridden if need be, just clear out the "Last Date Invitations Sent" field on the TCS Center account to add the Learning Center back into the picklist.

