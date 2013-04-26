# -*- coding: utf-8 -*-

module Rms
  module RmsForm

    def click_submit_button(button=buttons.first)
      wrap_rms_page(click_button(button))
    end

    def rms_submit(button=nil ,headers={})
      wrap_rms_page(submit(button=nil ,headers={}))
    end

    def wrap_rms_page(page)
      RmsPage.rmsnize(page)
#      page.extend RmsPage
#      page.set_enc
    end

    def RmsForm.rmsnize(page)
      forms = page.forms
      if forms 
        forms.each {|form|
          form.extend RmsForm
        }
      end
      page
    end

  end
end
