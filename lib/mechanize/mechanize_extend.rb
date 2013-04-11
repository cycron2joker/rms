
# extend for rms operation
class Mechanize::Form

  def click_submit_button(button=buttons.first)
    wrap_rms_page(click_button(button))
  end

  def rms_submit(button=nil ,headers={})
    wrap_rms_page(submit(button=nil ,headers={}))
  end

  def wrap_rms_page(page)
    page.extend ::Rms::RmsPAge
    page.set_enc
  end

end
