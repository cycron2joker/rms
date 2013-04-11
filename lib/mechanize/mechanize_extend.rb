class Mechanize::Page

  def rms_forms

    frms = super()
    if frms && !frms.empty?
      frms.each {|frm|

        # TODO implements...

      }   
    end
    frms
  end


end
