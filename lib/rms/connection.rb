# -*- coding: utf-8 -*-
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

    VAL_R_LOGIN_SUCCESS = "BizAuthUserAttest"
    VAL_R_MEM_LOGIN_SUCCESS = "BizAuthAnnounce"

    VAL_ANNOUNCE_SUCCESS_URI = "https://mainmenu.rms.rakuten.co.jp/?act=login&sp_id=1"


    WRD_R_LOGIN_SUCCESS = 'R-Login IDの認証を行いました。'.tosjis


    def initialize(auth1_id ,auth1_pwd ,auth2_id ,auth2_pwd)
      super()
      @auth_parameters = auth_parameter(auth1_id,
                                        auth1_pwd,
                                        auth2_id,
                                        auth2_pwd)

			self.read_timeout = DEF_TIMEOUT
			self.user_agent_alias = DEF_AGENT
			self.max_history = DEF_MAX_HISTORY
      self
    end

    # login and move to top menu
    def connect
      step = "r-login"


      # R-login
      login_page1 = get(LOGIN_URL)
      form = login_page1.forms[0]
      form.field_with(:name => 'login_id').value = @auth_parameters[:AUTH1_ID]
      form.field_with(:name => 'passwd').value = @auth_parameters[:AUTH1_PWD]


#<input type="hidden" name="action" value="BizAuthCustomerAttest">
#<input type="hidden" name="action" value="BizAuthUserAttest">

      login_page2 = set_enc(form.click_button)
			form = login_page2.forms[0]

			unless form.field_with(:name => 'action').value.to_s == VAL_R_LOGIN_SUCCESS
        raise LoginFailedError.new('R-Login failed.')
      end

#      unless login_page2.body.to_s.tosjis.index(WRD_R_LOGIN_SUCCESS)
#      end

      # Rakuten Member Login
      step = "rmember-login"
			form.field_with(:name => 'user_id').value = @auth_parameters[:AUTH2_ID]
			form.field_with(:name => 'user_passwd').value = @auth_parameters[:AUTH2_PWD]
			announce_page = set_enc(form.click_button)

      step = "announce-page"
			form = announce_page.forms[0]
			unless form.field_with(:name => 'action').value.to_s == VAL_R_MEM_LOGIN_SUCCESS
        raise LoginFailedError.new('Raketen Member Login failed.')
      end

			notice_page = set_enc(form.click_button)

      step = "notice-page"
			unless notice_page.uri.to_s.index(VAL_ANNOUNCE_SUCCESS_URI)
        raise LoginFailedError.new('Notice Page Move failed.')
			end

			notice_page

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




    def auth_parameter(auth1_id ,auth1_pwd ,auth2_id ,auth2_pwd)

      if !auth1_id || !auth1_id.is_a?(String) || auth1_id.strip == '' ||
          !auth1_pwd || !auth1_pwd.is_a?(String) || auth1_pwd.strip == '' ||
          !auth2_id || !auth2_id.is_a?(String) || auth2_pwd.strip == '' ||
          !auth2_pwd || !auth2_pwd.is_a?(String) || auth2_pwd.strip == ''
        raise "invalid auth_params"
      end

      {:AUTH1_ID   => auth1_id,
        :AUTH1_PWD => auth1_pwd,
        :AUTH2_ID  => auth2_id,
        :AUTH2_PWD => auth2_pwd}
    end




  end

end
