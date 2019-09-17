class InquiryMailer < ApplicationMailer
  default subject: 'Inquiry regarding Umaka Data'

  def inquiry
    @inquiry = params[:inquiry]

    mail from: @inquiry.email
  end
end
