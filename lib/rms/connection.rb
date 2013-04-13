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

    VAL_MAINMENU_SUCCESS_URI = "https://mainmenu.rms.rakuten.co.jp/"

    URL_LOGOUT = "https://mainmenu.rms.rakuten.co.jp/?act=logout"

    URL_MAIN_MENU = VAL_MAINMENU_SUCCESS_URI


    attr_reader :last_page


    def initialize(auth1_id ,auth1_pwd ,auth2_id ,auth2_pwd)
      super()
      @auth_parameters = auth_parameter(auth1_id,
                                        auth1_pwd,
                                        auth2_id,
                                        auth2_pwd)

			self.read_timeout = DEF_TIMEOUT
			self.user_agent_alias = DEF_AGENT
			self.max_history = DEF_MAX_HISTORY

      @open_rms = false

      self
    end

    # login and move to rms mainmenu
    def open

      step = "r-login"

      begin 

        # R-login
#        login_page1 = get_rms_page(LOGIN_URL)
        login_page1 = get_rms_page(LOGIN_URL)
        form = login_page1.forms[0]
        form.field_with(:name => 'login_id').value = @auth_parameters[:AUTH1_ID]
        form.field_with(:name => 'passwd').value = @auth_parameters[:AUTH1_PWD]

        login_page2 = form.click_submit_button

        form = login_page2.forms[0]
        unless form.field_with(:name => 'action').value.to_s == VAL_R_LOGIN_SUCCESS
          raise LoginFailedError.new('R-Login failed.')
        end

        # Rakuten Member Login
        step = "rmember-login"
        form.field_with(:name => 'user_id').value = @auth_parameters[:AUTH2_ID]
        form.field_with(:name => 'user_passwd').value = @auth_parameters[:AUTH2_PWD]

        announce_page = form.click_submit_button
        form = announce_page.forms[0]
        unless form.field_with(:name => 'action').value.to_s == VAL_R_MEM_LOGIN_SUCCESS
          raise LoginFailedError.new('Raketen Member Login failed.')
        end

        step = "announce-page"

        notice_page = form.click_submit_button
        unless notice_page.uri.to_s.index(VAL_ANNOUNCE_SUCCESS_URI)
          raise LoginFailedError.new('Notice Page Move failed.')
        end

        step = "notice-page"
        main_menu_page = notice_page.forms[0].click_submit_button
        
        if main_menu_page.uri.to_s != VAL_MAINMENU_SUCCESS_URI
          raise LoginFailedError.new('Mainmenu Move failed.')
        end


        # single sign-on for logon rms sub-system
#      main_menu_html = @current_page.body.to_s.tosjis
#      lst_img_tag = main_menu_html.scan(/<img src=\"(https:\/\/[^\"]+)\"/i)
#      raise "parse failed for single sign-on" if lst_img_tag.empty?
#      lst_img_tag2 = []
#      lst_img_tag.select {|tag|
#        path = tag[0]
#        if is_single_signon_path(path)
#                                       @rms_session.get(path)
#                                       sleep(0.3)
#        end
#      }

        main_menu_page.search('img').each {|img|
          path = img.attributes['src'].to_s 
          if is_single_signon_path(path)
            get(path)
            sleep(0.3)
          end
        }

        @open_rms = true
        @last_page = main_menu_page
        self
      rescue LoginFailedError => err
        raise err
      rescue => other_err
        warn "error occured step:[#{step}]"
        raise other_err
      end
    end


    def open?
      @open_rms
    end

    # logout from rms.
    def close
      @open_rms = false
      get_rms_page(URL_LOGOUT)
    end

    # call  rms mainmenu
    def move_to_main_menu
      get_rms_page(URL_MAIN_MENU)
    end

    # page get and setup encoding.
    def get_rms_page(*params)
      page = RmsPage.rmsnize(get(*params))
      @last_page = page.set_enc
      page
    end

    # judge url of sigle sign-on
    def is_single_signon_path(path)
      path.index('login?') || path.index('/auth/?') ||
        path.index('m_login.cgi?') || path.index('RBLogin') ||
        path.index('entrance.cgi?')
    end

    # generate auth-parameter
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
