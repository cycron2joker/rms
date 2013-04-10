module Rms

  class LoginFailedError < Exception
    attr_accessor :cause
  end

  class Connection < ::Mechanize

    DEF_TIMEOUT     = 180
    DEF_AGENT       = 'Windows IE 7'
    DEF_MAX_HISTORY	= 1

    DEF_ENCODING = 'euc-jp'

    LOGIN_URL = "https://glogin.rms.rakuten.co.jp/?sp_id=1"


    def initialize(auth)

      super()

      if !auth || !auth.is_a?(Hash) || auth.empty? ||
          !auth[:AUTH1_ID] || !auth[:AUTH1_ID].is_a?(String) ||
          auth[:AUTH1_ID].strip == '' ||
          !auth[:AUTH1_PWD] || !auth[:AUTH1_PWD].is_a?(String) ||
          auth[:AUTH1_PWD].strip == '' ||
          !auth[:AUTH2_ID] || !auth[:AUTH2_ID].is_a?(String) ||
          auth[:AUTH2_ID].strip == '' ||
          !auth[:AUTH2_PWD] || !auth[:AUTH2_PWD].is_a?(String) ||
          auth[:AUTH2_PWD].strip == ''
        raise "invalid auth_params"
      end

      @auth_parameters = auth

			self.read_timeout = DEF_TIMEOUT
			self.user_agent_alias = DEF_AGENT
			self.max_history = DEF_MAX_HISTORY

      self
    end

    def Connection.auth_parameter(auth1_id ,auth1_pwd ,auth2_id ,auth2_pwd)
      {:AUTH1_ID   => auth1_id,
        :AUTH1_PWD => auth1_pwd,
        :AUTH2_ID  => auth2_id,
        :AUTH2_PWD => auth2_pwd}
    end

    # login and mover to top menu
    def connect

      login_page = get(LOGIN_URL)

      # R-login
      form = login_page.forms[0]
      form.field_with(:name => 'login_id').value = @auth_parameters[:AUTH1_ID]
      form.field_with(:name => 'passwd').value = @auth_parameters[:AUTH1_PWD]

      page = set_enc(form.click_button)
			

    end

    def get(*params)
      set_enc(super(*params))
    end


    def set_enc(page)
			if page.body.to_s.tosjis =~ /charset=(.*)\"/
        ec = $1
        if ec =~ /^[xX]\-(.*)/
          ec = $1
        end
				page.encoding = ec
			else
				page.encoding = DEF_ENCODING
			end
      page
		end

  end

end
