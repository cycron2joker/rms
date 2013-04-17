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
      @debug_mode = nil

      self
    end

    def set_debug_mode_on
      @debug_mode_on = true
    end

    def set_debug_mode_off
      @debug_mode_on = false
    end

    def debug_mode?
      @debug_mode == true
    end

    # standard-out write messeage.
    def debug(msg)
      tm = Time.now.strftime("[%Y-%m-%d %H:%M:%S] ")
      if debug_mode?
        if msg
          puts "#{tm}#{(msg.is_a?(String) ? msg : msg.to_s)}"
        else
          puts "#{tm}nil"
        end
      end
    end

    # login and move to rms mainmenu
    def open

      step = "r-login"
      begin 

        # R-login
        debug "R-Login start"
        login_page1 = get_rms_page(LOGIN_URL)
        form = login_page1.forms[0]
        form.field_with(:name => 'login_id').value = @auth_parameters[:AUTH1_ID]
        form.field_with(:name => 'passwd').value = @auth_parameters[:AUTH1_PWD]

        debug "R-Login first auth execute."
        sleep(1)
        login_page2 = form.click_submit_button

        form = login_page2.forms[0]
        unless form.field_with(:name => 'action').value.to_s == VAL_R_LOGIN_SUCCESS
          raise LoginFailedError.new('R-Login failed.')
        end
        debug "R-Login first auth successed."

        # Rakuten Member Login
        step = "rmember-login"
        form.field_with(:name => 'user_id').value = @auth_parameters[:AUTH2_ID]
        form.field_with(:name => 'user_passwd').value = @auth_parameters[:AUTH2_PWD]

        debug "R-Member login second auth execute."
        sleep(1)
        announce_page = form.click_submit_button
        form = announce_page.forms[0]
        unless form.field_with(:name => 'action').value.to_s == VAL_R_MEM_LOGIN_SUCCESS
          raise LoginFailedError.new('Raketen Member Login failed.')
        end
        debug "R-Member second auth successed."

        step = "announce-page"
        sleep(1)
        notice_page = form.click_submit_button
        unless notice_page.uri.to_s.index(VAL_ANNOUNCE_SUCCESS_URI)
          raise LoginFailedError.new('Notice Page Move failed.')
        end
        debug "rms announce page passed."

        step = "notice-page"
        sleep(1)
        main_menu_page = notice_page.forms[0].click_submit_button
        
        if main_menu_page.uri.to_s != VAL_MAINMENU_SUCCESS_URI
          raise LoginFailedError.new('Mainmenu Move failed.')
        end

        debug "rms notice page passed, and main menu page called"
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

        debug "single sign-on start."
        main_menu_page.search('img').each {|img|
          path = img.attributes['src'].to_s 
          if is_single_signon_path(path)
            get(path)
            sleep(1)
          end
        }
        debug "single sign-on end."

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
      page = nil
      if ::Mechanize::VERSION =~ /^1¥.0/
        page = RmsPage.rmsnize(get(*params))
      else
        page = RmsPage.rmsnize(get(params[0]))
      end
      @last_page = page.set_enc
      page
    end

    # 
    def create_dynamic_form
      node = {}
      class << node
        def search(*args) 
          []
        end
      end
      node['method'] = 'POST'
      node['enctype'] = 'application/x-www-form-urlencoded'
      form = Mechanize::Form.new(node)
      form.extend RmsForm
      if block_given?
        yield form
      end
      return form
    end

    # direct submit form
    def direct_post(post_url ,form)
      form.action = post_url
      page = RmsPage.rmsnize(submit(form, nil, self.request_headers))
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
