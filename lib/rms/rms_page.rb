# -*- coding: utf-8 -*-

module Rms

  module RmsPage

    RMS_ENC = 'euc-jp'

    # setup page encoding
    def set_enc
      if self.body.to_s.tosjis =~ /charset=(.*)\"/
        ec = $1
        if ec =~ /^[xX]\-(.*)/
          ec = $1
        end
        self.encoding = ec
      else
        self.encoding = RMS_ENC
      end
      self
    end

    # inject RmsPage module
    def RmsPage.rmsnize(page)
      page.extend RmsPage
      page.set_enc
      RmsForm.rmsnize(page)
      page
    end

  end

end




