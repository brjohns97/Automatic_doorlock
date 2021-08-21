import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

class Gmailer:
    def __init__(self, sender_addr, sender_pass, receiver_addr = None, subject = None):
        self.sender_addr = sender_addr
        self.sender_pass = sender_pass
        self.receiver_addr = receiver_addr
        self.subject = subject
        
    def send_gmail(self, content, receiver_addr = None, subject = None):
        #vet some things
        if receiver_addr == None:
            receiver_addr = self.receiver_addr
        if subject == None:
            subject = self.subject

        # Make sure there is actually someone to send it to
        if receiver_addr==None:
            return False

        #Setup the MIME
        message = MIMEMultipart()
        message['From'] = self.sender_addr
        message['To'] = receiver_addr
        message['Subject'] = subject
        message.attach(MIMEText(content, 'plain'))

        session = smtplib.SMTP('smtp.gmail.com', 587) #use gmail with port
        session.starttls() #enable security
        session.login(self.sender_addr, self.sender_pass) #login with mail_id and password
        
        #The body and the attachments for the mail
        text = message.as_string()
        #Create SMTP session for sending the mail
        session.sendmail(self.sender_addr, receiver_addr, text)
        session.quit()
        return True

