class CompanyInfo
  class << self
    def dev_emails
      ENV['DEV_MAIL'].present? ? ENV['DEV_MAIL'].split(',') : %w[hmmshl@gmail.com]
    end

    def no_reply
      "Multi Magic Team <no-reply@gmail.com>"
    end
  end
end
