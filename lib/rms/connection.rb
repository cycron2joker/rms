module Rms

  class Connection < Mechanize

    DEF_TIMEOUT     = 180
    DEF_AGENT       = 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)'
		DEF_MAX_HISTORY	= 1


    def initialize(auth)
      super
      @auth_parameters = auth
			self.read_timeout = DEF_TIMEOUT
			self.user_agent_alias = DEF_AGENT
			self.max_history = DEF_MAX_HISTORY
    end

    def Connection.auth_parameter(auth1_id ,aut1_pwd ,auth2_id ,auth2_pwd)
      {:AUTH1_ID   => auth1_id,
        :AUTH1_PWD => auth1_pwd,
        :AUTH2_ID  => auth2_id,
        :AUTH2_PWD => auth2_pwd}
    end

  end

end
