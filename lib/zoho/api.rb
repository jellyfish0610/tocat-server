require 'rest_client'

class RedmineTocatApi

  def self.errors
    @e
  end

  def self.status
    @status
  end

  def self.get_transactions
    url, auth, app_owner = generate_url('get_transactions')
    params  = { :params => { "authtoken"    => auth,
                             'scope'        => 'creatorapi',
                             'zc_ownername' => app_owner,
                             'raw'          => true
    } }
    request = get(url, params)
    if request && !request.empty? && request != "{}"
      request = JSON.parse(request)
      unless request["Transaction"].empty?
        request["Transaction"]
      end
    end
  end

  protected


  def self.get(url, params)
    RestClient.get(url, params) { |response, request, result, &block|
      case response.code
        when 502
          @status = response.code
          @e      = "Please, check connection between Redmine And Tocat server."
          return nil
        when 401
          @status = response.code
          @e      = "Please, check you login and password in config."
          return nil
        when 500
          @status = response.code
          @e      = "Please, check log on you tocat server."
          return nil
        when 200
          @status = response.code
          response
        when 404
          @status = response.code
          @e      = "Object not found. Looks like TOCAT sever has no record for this object."
          return nil
        else
          @status = response.code
          response.return!(request, result, &block)
      end
    }
  end

  def self.set(url, params)
    RestClient.post(url, params) { |response, request, result, &block|
      case response.code
        when 502
          @status = response.code
          @e      = "Please, check connection between Redmine And Tocat server."
          return nil
        when 401
          @status = response.code
          @e      = "Please, check you login and password in config."
          return nil
        when 500
          @status = response.code
          @e      = "Please, check log on you tocat server."
          return nil
        when 200
          @status = response.code
          response
        when 404
          @status = response.code
          @e      = "Object not found. Looks like TOCAT sever has no record for this object."
          return nil
        else
          @status = response.code
          response.return!(request, result, &block)
      end
    }
  end

  def self.generate_url(action)
    server    = 'https://creator.zoho.com/api/'
    protocol  = 'json/'
    auth      = '8fa0b27a260be8a7fc5a980389867d25'
    app_name  = 'tocat'
    app_owner = 'verlgoff'
    case action
      when 'delete_issue_orders'
        #https://creator.zoho.com/api/verlgoff/json/tocat/form/IssueOrder/record/delete/
        return "#{server + app_owner}" + '/' + "#{protocol + app_name.downcase}/form/IssueOrder/record/delete/", auth
      when 'create_issue_order'
        #https://creator.zoho.com/api/verlgoff/json/tocat/form/IssueOrder/record/add/
        return "#{server + app_owner}" + '/' + "#{protocol + app_name.downcase}/form/IssueOrder/record/add/", auth
      when 'update_issue_order'
        #https://creator.zoho.com/api/verlgoff/json/tocat/form/IssueOrder/record/add/
        return "#{server + app_owner}" + '/' + "#{protocol + app_name.downcase}/form/IssueOrder/record/update/", auth
      when 'orders_for_issue'
        return "#{server + protocol + app_name.downcase}/view/IssueOrder_Report", auth, app_owner
      when 'issue'
        return "#{server + protocol + app_name.downcase}/view/Issue_Report", auth, app_owner
      when 'order'
        return "#{server + protocol + app_name.downcase}/view/Order_form_Report", auth, app_owner
      when 'new_issue'
        return "#{server + app_owner}" + '/' + "#{protocol + app_name.downcase}/form/Issue/record/add/", auth
      when 'update_issue'
        return "#{server + app_owner}" + '/' + "#{protocol + app_name.downcase}/form/Issue/record/update/", auth
      when 'set_group'
        #https://creator.zoho.com/api/json/tocat/view/Team_Report
        return "#{server + protocol + app_name.downcase}/view/Team_Report", auth, app_owner
      when 'get_transactions'
        #https://creator.zoho.com/api/json/tocat/view/Transation_Report
        return "#{server + protocol + app_name.downcase}/view/Transation_Report", auth, app_owner
      when 'get_user'
        #https://creator.zoho.com/api/json/tocat/view/User_Report
        return "#{server + protocol + app_name.downcase}/view/User_Report", auth, app_owner
      when 'get_account'
        #https://creator.zoho.com/api/json/tocat/view/Account_Report
        return "#{server + protocol + app_name.downcase}/view/Account_Report", auth, app_owner
      when 'new_order'
        return "#{server + app_owner}" + '/' + "#{protocol + app_name.downcase}/form/OrderEntity/record/add/", auth
      when 'create_transaction'
        return "#{server + app_owner}" + '/' + "#{protocol + app_name.downcase}/form/Transaction/record/add/", auth
      when 'sub_orders'
        return "#{server + protocol + app_name.downcase}/view/SubOrder_Report", auth, app_owner
    end
  end

  def self.authorize
    if User.current.manager? || User.current.admin?
      true
    else
      false
    end
  end

  LOGFILE = "#{Rails.root}/log/budget.log"

  def self.logger
    Logger.new(LOGFILE, 7, 2048000)
  end
  def self.salary_logger
    Logger.new("#{Rails.root}/log/salary.log", 7, 2048000)

  end
end