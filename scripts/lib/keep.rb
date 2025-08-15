require 'googleauth'
require 'google/apis/keep_v1'

# making the Keep api more ruby-like

Google::Apis::KeepV1::ListContent.define_method(:<<) do |args|
  if args.is_a?(Google::Apis::KeepV1::ListItem)
    item = args
  elsif args.respond_to?(:to_s)
    text_content = Google::Apis::KeepV1::TextContent.new
    text_content.text = args.to_s

    item = Google::Apis::KeepV1::ListItem.new    
    item.text = text_content 
    item.checked = false
  end

  self.list_items ||= []
  self.list_items << item  
end

# these should have been defined in the api, but are not

module Google
  module Apis
    module KeepV1
      module Role
        RoleUnspecified = "ROLE_UNSPECIFIED"
        Owner = "OWNER"
        Writer = "WRITER"
      end
    end
  end
end

module Groceries
  Keep = Google::Apis::KeepV1

  # a minimal wrapper for the (minimal) google keep api 
  class List
    def initialize(authorizer, name="Groceries")
      @authorizer = authorizer
      @list_name = name
      @note = nil  # holds a reference to the Keep note
    end

    def get_items
      with_authorized_service do |s|
        response = s.list_notes
        return [] if response.notes.nil? # workspace user has no notes

        note = response.notes.find { |n| n.title == @list_name }
        items = []
        unless note.nil?
          @note = note

          # TODO validate that the note is actually a list
          items = note.body.list.list_items.inject([]) { |lst, item| lst << item.text.text} 
        end
        return items
      end
    end
    
    def save(items)
      with_authorized_service do |s|
        # delete the current note
        if not @note.nil?
          s.delete_note(@note.name) unless @note.nil?
          @note = nil
        end
      
        # for us, type will always be list
        create_note(type: :list, title: @list_name) do |n|
          items.collect { |item| n.body.list << item }
          @note = s.create_note(n)
        end
      end

      self
    end

    def share_with(email)
      # create a user representation
      u = Keep::User.new(email:email)

      # create a permission object
      p = Keep::Permission.new
      p.email = email
      p.role = Google::Apis::KeepV1::Role::Writer
      p.user = u
      
      # create permission request object
      pr = Keep::CreatePermissionRequest.new
      pr.parent ="#{@note.name}"
      pr.permission = p

      # create batch permission request object
      bpr = Keep::BatchCreatePermissionsRequest.new
      bpr.requests = [pr]

      with_authorized_service do |s|
        s.batch_create_permissions("#{@note.name}", bpr)
      end
    end

    private 

    # create_note serves as a reminder that we're actually creating a Keep not
    def create_note(**args)
      note = Keep::Note.new
      note.title = args[:title] unless args[:title].nil?
      note.body = Keep::Section.new
      case args[:type]
      when :list
        note.body.list = Keep::ListContent.new
      when :text
        note.body.text = Keep::TextContent.new
      end

      if block_given?
        yield note
      else
        return note
      end
    end

    def with_authorized_service 
      svc = Keep::KeepService.new
      svc.authorization = @authorizer
      yield svc
    end
  end

  module_function

  def user_credentials(**args)
      scope = [Keep::AUTH_KEEP, Keep::AUTH_KEEP_READONLY, 'https://www.googleapis.com/auth/userinfo.email']

      authorizer = Google::Auth::ServiceAccountCredentials.make_creds( 
        json_key_io: File.open(args[:api_key]),
        scope: scope       
      )
      authorizer.update!(sub: args[:for])
      authorizer.fetch_access_token!
      return authorizer
  end
end
