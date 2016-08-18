class ContactUs < ApplicationMailer
  
  SUBJECT = 'Inquiry regarding Umaka Data'
  
  def send_mail(inquiry)
    @inquiry = inquiry
    mail :subject => SUBJECT
  end
  
end
