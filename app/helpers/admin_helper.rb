def check_admin_login    
    if session.has_key?('admin_login') && session['admin_login'].to_s == '1'
        true
    else
        false
    end
end